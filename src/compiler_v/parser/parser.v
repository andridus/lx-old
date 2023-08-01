// Copyright (c) 2023 Helder de Sousa. All rights reserved/
// Use of this source code is governed by a MIT license
// that can be found in the LICENSE file
module parser

import os
import compiler_v.ast
import compiler_v.lexer
import compiler_v.token
import compiler_v.types
import compiler_v.table

struct Parser {
	file_name  string
	build_path string
mut:
	module_name      string
	module_path      string
	requirements     []string
	tok              token.Token
	lexer            &lexer.Lexer
	program          &table.Program
	peek_tok         token.Token
	return_ti        types.TypeIdent
	current_module   string
	error_pos_inline int
	error_pos_in     int
	error_pos_out    int
	inside_parens    int
	inside_ifcase    int
	compiler_options []CompilerOptions = [.empty]
}

enum CompilerOptions {
	empty
	disable_type_match
	ensure_left_type // ensure the left type over right type
}

pub fn parse_stmt(text string, prog &table.Program) ast.Stmt {
	l := lexer.new(text)
	mut p := unsafe {
		Parser{
			build_path: '_build'
			lexer: l
			program: prog
		}
	}
	p.read_first_token()
	return p.stmt()
}

pub fn parse_files(prog &table.Program) {
	mut prog0 := unsafe { prog }
	for modl in prog0.compile_order {
		if modl.starts_with('@') {
			mut core_module := prog0.core_modules[modl.trim_left('@')]
			stmts := parse_file(core_module, prog)
			core_module.put_stmts(stmts)
			prog0.modules[modl] = core_module
			// prog0.modules[modl].put_stmts(stmts)
		} else {
			stmts := parse_file(prog0.modules[modl], prog)

			prog0.modules[modl].put_stmts(stmts)
		}
	}
}

fn parse_file(modl table.Module, prog &table.Program) []ast.Stmt {
	text := os.read_file(modl.path) or { panic(err) }
	mut stmts := []ast.Stmt{}
	mut l := lexer.new(text)
	mut p := unsafe {
		Parser{
			build_path: '_build'
			lexer: l
			program: prog
			current_module: modl.name
			file_name: modl.path
		}
	}
	p.read_first_token()
	for {
		if p.tok.kind == .eof {
			break
		}
		stmts << p.top_stmt()
	}
	return stmts
}

pub fn (mut p Parser) top_stmt() ast.Stmt {
	match p.tok.kind {
		.line_comment {
			p.next_token()
			return p.top_stmt()
		}
		.key_defmodule {
			return p.module_decl()
		}
		// .modl {
		// 	return p.call_expr()
		// }
		.lsbr {
			p.next_token()
			p.check(.ident)
			p.check(.rsbr)
			return ast.Module{}
		}
		.key_do {
			return p.block_expr(true)
		}
		else {
			return p.expr_stmt()
		}
	}
}

pub fn (mut p Parser) stmt() ast.Stmt {
	match p.tok.kind {
		.line_comment {
			p.next_token()
			return p.stmt()
		}
		.atom {
			if p.peek_tok.kind != .newline {
				return p.expr_stmt()
			} else {
				match p.tok.lit {
					'COMPILER__disable_type_match__' {
						p.compiler_options << .disable_type_match
					}
					'COMPILER__ensure_left_type__' {
						p.compiler_options << .ensure_left_type
					}
					else {
						return p.expr_stmt()
					}
				}
				p.next_token()
				return p.stmt()
			}
		}
		.key_alias {
			mut module_name := []string{}
			p.check(.key_alias)
			module_name << p.tok.lit
			p.check(.modl)
			for p.tok.kind == .dot {
				p.check(.dot)
				if p.tok.kind == .modl {
					module_name << p.tok.lit
					p.check(.modl)
				}
			}
			module_name_0 := module_name.join('.')
			last := module_name.reverse().first()
			p.program.table.register_alias(last, module_name_0)
			return p.stmt()
		}
		.key_defstruct, .key_defstructp {
			return p.defstruct_decl()
		}
		.key_defenum, .key_defenump {
			return p.defenum_decl()
		}
		.key_def, .key_defp {
			return p.def_decl()
		}
		.lsbr {
			p.next_token()
			p.check(.ident)
			p.check(.rsbr)
			return ast.Module{}
		}
		else {
			if p.peek_tok.kind in [.assign, .typedef] {
				return p.pattern_matching()
			} else {
				return p.expr_stmt()
			}
		}
	}
}

pub fn (mut p Parser) expr(precedence int) (ast.Expr, types.TypeIdent) {
	mut ti := types.void_ti
	mut node := ast.Expr(ast.EmptyExpr{})
	// Prefix
	match p.tok.kind {
		.mod {
			if p.peek_tok.kind == .modl {
				node1, ti1 := p.defstruct_init()
				node = ast.Expr(node1)
				ti = ti1
			} else {
				p.next_token()
				node, ti = p.expr(0)
			}
		}
		.atom {
			node, ti = p.atom_expr()
		}
		.ident {
			if p.peek_tok.kind == .string_concat {
				node, ti = p.string_concat_expr()
			} else {
				node, ti = p.ident_expr()
			}
		}
		.key_nil {
			node, ti = p.parse_nil_literal()
		}
		.key_keyword {
			node, ti = p.keyword_list_expr()
		}
		.key_if {
			node, ti = p.if_expr()
		}
		.multistring {
			node, ti = p.string_expr()
		}
		.str {
			if p.peek_tok.kind == .string_concat {
				node, ti = p.string_concat_expr()
			} else if p.peek_tok.kind == .colon_space {
				node, ti = p.keyword_list_expr()
			} else {
				node, ti = p.string_expr()
			}
		}
		.key_true, .key_false {
			node, ti = p.parse_boolean()
		}
		.integer {
			node, ti = p.parse_number_literal()
		}
		.float {
			node, ti = p.parse_number_literal()
		}
		.charlist {
			node, ti = p.charlist_expr()
		}
		.lcbr {
			node, ti = p.tuple_expr()
		}
		.lpar {
			p.check(.lpar)
			p.inside_parens++
			node, ti = p.expr(0)
			p.check(.rpar)
			p.inside_parens--
		}
		.modl {
			mut num := 1
			mut nt := p.peek_next_token(num)
			if p.tok.kind == .modl {
				for nt.kind == .dot {
					num++
					nt = p.peek_next_token(num)
					if nt.kind == .modl {
						num++
						nt = p.peek_next_token(num)
					} else {
						break
					}
				}
				num++
			}
			nt = p.peek_next_token(num)

			if nt.kind == .arrob {
				node1, ti1 := p.call_enum() or {
					p.warn('Error')
					exit(0)
				}
				node = ast.Expr(node1)
				ti = ti1
			} else {
				node1, ti1 := p.call_from_module(.modl) or {
					p.warn('Error')
					exit(0)
				}
				ti = ti1
				node = ast.Expr(node1)
			}
		}
		else {
			p.error_pos_in = p.tok.lit.len
			p.error_pos_out = p.lexer.pos_inline
			p.log_d('ERROR', 'Bad token `${p.tok.str()}`', '', '', p.tok.lit)
			exit(0)
		}
	}

	// Infix
	for precedence < p.tok.precedence() {
		if p.tok.kind.is_infix() {
			node, ti = p.infix_expr(node)
			return node, ti
		}
		// Postfix
		else if p.tok.kind in [.inc, .dec] {
			node = ast.PostfixExpr{
				op: p.tok.kind
				expr: node
			}
			p.next_token()
			return node, ti
		} else {
			return node, ti
		}
	}
	return node, ti
}
