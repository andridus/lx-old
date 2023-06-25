// Copyright (c) 2023 Helder de Sousa. All rights reserved/
// Use of this source code is governed by a MIT license
// that can be found in the LICENSE file
module parser

import os
import ast
import lexer
import token
import types
import table
import utils
import color

struct Parser {
	file_name  string
	build_path string
mut:
	module_name   string
	module_path   string
	requirements  []string
	tok           token.Token
	lexer         &lexer.Lexer
	program       &table.Program
	peek_tok      token.Token
	return_ti     types.TypeIdent
	inside_parens int
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
		stmts := parse_file(prog0.modules[modl].path, prog)
		prog0.modules[modl].put_stmts(stmts)
	}
}

fn parse_file(path string, prog &table.Program) []ast.Stmt {
	text := os.read_file(path) or { panic(err) }
	mut stmts := []ast.Stmt{}
	mut l := lexer.new(text)
	mut p := unsafe {
		Parser{
			build_path: '_build'
			lexer: l
			program: prog
			file_name: path
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

pub fn (mut p Parser) read_first_token() {
	p.next_token()
	p.next_token()
}

fn (mut p Parser) next_token() {
	p.tok = p.peek_tok
	p.peek_tok = p.lexer.generate_one_token()
	if p.tok.kind == .newline {
		p.next_token()
	}
}

fn (mut p Parser) check(expected token.Kind) {
	if p.tok.kind != expected {
		s := 'syntax error: unexpected `${p.tok.kind.str()}` , expecting `${expected.str()}`'
		p.error(s)
	}
	p.next_token()
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
			if p.tok.kind == .ident && p.peek_tok.kind == .assign {
				return p.var_decl()
			} else {
				return p.expr_stmt()
			}
		}
	}
}

fn (mut p Parser) block_expr(is_top_stmt bool) ast.Block {
	p.check(.key_do)
	mut stmts := []ast.Stmt{}
	for p.peek_tok.kind != .eof {
		if p.tok.kind == .key_end {
			break
		}
		stmts << p.stmt()
	}
	p.check(.key_end)
	return ast.Block{
		name: utils.filename_without_extension(p.file_name)
		stmts: stmts
		is_top_stmt: is_top_stmt
	}
}

fn (mut p Parser) module_decl() ast.Module {
	p.check(.key_defmodule)
	mut module_path_name := [p.tok.lit]
	p.check(.modl)

	for p.tok.kind == .dot {
		p.check(.dot)
		module_path_name << p.tok.lit
		p.check(.modl)
	}
	p.module_name = module_path_name.join('.')

	stmt := p.block_expr(false)

	return ast.Module{
		name: p.module_name
		stmt: stmt
	}
}

fn (mut p Parser) var_decl() ast.VarDecl {
	name := p.tok.lit
	p.read_first_token()
	expr, ti := p.expr(token.lowest_prec)
	if _ := p.program.table.find_var(name) {
		p.error('rebinding of `${name}`')
	}
	p.program.table.register_var(table.Var{
		name: name
		ti: ti
		is_mut: false
		expr: ast.ExprStmt{
			expr: expr
			ti: ti
		}
	})

	return ast.VarDecl{
		name: name
		expr: expr
		ti: ti
	}
}

fn (mut p Parser) expr_stmt() ast.ExprStmt {
	exp, ti := p.expr(0)
	return ast.ExprStmt{
		expr: exp
		ti: ti
	}
}

pub fn (mut p Parser) expr(precedence int) (ast.Expr, types.TypeIdent) {
	mut ti := types.void_ti
	mut node := ast.Expr(ast.EmptyExpr{})
	// Prefix
	match p.tok.kind {
		.atom {
			node, ti = p.atom_expr()
		}
		.ident {
			node, ti = p.ident_expr()
		}
		.key_keyword {
			node, ti = p.keyword_list_expr()
		}
		.str {
			if p.peek_tok.kind == .colon_space {
				node, ti = p.keyword_list_expr()
			} else {
				node, ti = p.string_expr()
			}
		}
		.integer {
			node, ti = p.parse_number_literal()
		}
		.float {
			node, ti = p.parse_number_literal()
		}
		.lpar {
			p.check(.lpar)
			p.inside_parens++
			node, ti = p.expr(0)
			p.check(.rpar)
			p.inside_parens--
		}
		.modl {
			node1, ti1 := p.call_from_module() or {
				p.warn('Error')
				exit(0)
				// p.warn('Module ${module_name(module_ref)} is orphan')
			}
			node = ast.Expr(node1)
			ti = ti1
		}
		else {
			p.error('expr(): bad token `${p.tok.str()}`')
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

fn (mut p Parser) string_expr() (ast.Expr, types.TypeIdent) {
	mut node := ast.StringLiteral{
		val: p.tok.lit
	}
	if p.peek_tok.kind != .hash {
		p.next_token()
		return node, types.string_ti
	}
	for p.tok.kind == .str {
		p.next_token()
		if p.tok.kind != .hash {
			continue
		}
		p.check(.hash)
		p.expr(0)
	}
	return node, types.string_ti
}

fn (mut p Parser) keyword_list_expr() (ast.Expr, types.TypeIdent) {
	mut node := ast.Expr(ast.EmptyExpr{})
	mut keyword_list := ast.KeywordList{}
	breakpoint := [token.Kind.rpar, .rsbr, .eof]
	for p.tok.kind !in breakpoint {
		keyword := p.tok.lit
		mut atom := false

		if p.tok.kind == .key_keyword {
			p.check(.key_keyword)
			atom = true
		} else if p.tok.kind == .str {
			p.check(.str)
			p.next_token()
		} else {
			println('${p.tok.kind} not a keyword')
			exit(0)
		}
		value := p.tok.lit
		typ := types.type_from_token(p.tok)

		keyword_list.put(keyword, value, typ, atom)
		p.next_token()
		if p.tok.kind != .comma && p.tok.kind in breakpoint {
		} else {
			p.check(.comma)
		}
	}
	node = keyword_list
	return node, types.void_ti
}

fn (mut p Parser) ident_expr() (ast.Expr, types.TypeIdent) {
	mut node := ast.Expr(ast.EmptyExpr{})

	node = ast.Ident{
		name: p.tok.lit
		tok_kind: p.tok.kind
	}
	var := p.program.table.find_var(p.tok.lit) or {
		p.error('undefined variable ${p.tok.lit}')
		// exit(0)
		table.Var{}
	}

	ti := var.ti
	p.next_token()

	return node, ti
}

fn (mut p Parser) atom_expr() (ast.Expr, types.TypeIdent) {
	mut node := ast.Expr(ast.EmptyExpr{})

	node = ast.Ident{
		name: p.tok.lit
		tok_kind: p.tok.kind
	}
	p.program.table.find_or_new_atom(p.tok.lit)
	p.next_token()

	return node, types.atom_ti
}

fn (mut p Parser) index_expr(left ast.Expr) (ast.Expr, types.TypeIdent) {
	p.next_token()
	println('start expr')
	index, _ := p.expr(0)
	println('end expr')
	p.check(.rsbr)
	println('got ]')
	ti := types.int_ti
	node := ast.Expr(ast.IndexExpr{
		left: left
		index: index
	})
	return node, ti
}

fn (mut p Parser) parse_number_literal() (ast.Expr, types.TypeIdent) {
	mut node := ast.Expr(ast.EmptyExpr{})
	mut ti := types.int_ti
	if p.tok.kind == .float {
		node = ast.Expr(ast.FloatLiteral{
			val: unsafe { p.tok.value.fval }
		})
		ti = types.float_ti
	} else {
		node = ast.Expr(ast.IntegerLiteral{
			val: unsafe { p.tok.value.ival }
		})
	}
	p.next_token()
	return node, ti
}

fn (mut p Parser) infix_expr(left ast.Expr) (ast.Expr, types.TypeIdent) {
	op := p.tok.kind
	op_precedence := p.tok.precedence()
	p.next_token()
	next_precedence := p.tok.precedence()
	right, mut ti := p.expr(next_precedence)
	if op.is_relational() {
		ti = types.bool_ti
	}
	expr := p.parse_ast_expr(left, op, op_precedence, right, p.inside_parens > 0)
	return expr, ti
}

//
fn (p Parser) parse_ast_expr_deep(left ast.Expr, op token.Kind, op_prec int, right ast.Expr) ast.Expr {
	meta := ast.Meta{
		line: p.tok.line_nr - 1
	}
	match right {
		ast.BinaryExpr {
			match right.left {
				ast.BinaryExpr {
					if right.is_inside_parens() {
						return ast_bin_expr(left, op, right, meta, op_prec)
					}
					if op_prec < right.op_precedence {
						return ast_bin_expr(left, op, right, meta, op_prec)
					} else {
						left0 := p.parse_ast_expr_deep(left, op, op_prec, right.left)
						return ast_bin_expr(left0, right.op, right.right, meta, right.op_precedence)
					}
				}
				else {
					if right.is_inside_parens() {
						return ast_bin_expr(left, op, right, meta, op_prec)
					}
					if op_prec < right.op_precedence {
						return ast_bin_expr(left, op, right, meta, op_prec)
					} else {
						left0 := ast_bin_expr(left, op, right.left, meta, op_prec)
						return ast_bin_expr(left0, right.op, right.right, meta, right.op_precedence)
					}
				}
			}
		}
		else {
			return ast_bin_expr(left, op, right, meta, op_prec)
		}
	}
}

fn (p Parser) parse_ast_expr(left ast.Expr, op token.Kind, op_prec int, right ast.Expr, inside_parens bool) ast.Expr {
	meta := ast.Meta{
		line: p.tok.line_nr - 1
		inside_parens: p.inside_parens
	}
	match right {
		ast.BinaryExpr {
			if right.is_inside_parens() {
				return ast_bin_expr(left, op, right, meta, op_prec)
			} else if op_prec < right.op_precedence {
				return ast_bin_expr(left, op, right, meta, op_prec)
			} else {
				left0 := p.parse_ast_expr_deep(left, op, op_prec, right.left)
				return ast_bin_expr(left0, right.op, right.right, meta, right.op_precedence)
			}
		}
		else {
			return ast_bin_expr(left, op, right, meta, op_prec)
		}
	}
}

fn ast_bin_expr(left ast.Expr, op token.Kind, right ast.Expr, meta ast.Meta, op_prec int) ast.Expr {
	return ast.Expr(ast.BinaryExpr{
		op: op
		op_precedence: op_prec
		left: left
		meta: meta
		right: right
	})
}

pub fn (p &Parser) error(s string) {
	// print_backtrace()
	println(color.fg(color.red, 0, 'ERROR: ${p.file_name}[${p.tok.line_nr},${p.tok.pos}]: ${s}'))
	println(p.lexer.get_code_between_line_breaks(color.red, p.tok.pos, 1, p.tok.line_nr))
}

pub fn (p &Parser) error_at_line(s string, line_nr int) {
	println(color.fg(color.red, 0, 'ERROR: ${p.file_name}:${line_nr}: ${s}'))
	println(p.lexer.get_code_between_line_breaks(color.red, p.tok.pos, 1, p.tok.line_nr))
}

pub fn (p &Parser) warn(s string) {
	println(color.fg(color.dark_yellow, 0, 'WARN: ${p.file_name}[${p.tok.line_nr},${p.tok.pos_inline}]: ${s}'))
	println(p.lexer.get_code_between_line_breaks(color.red, p.tok.pos, 1, p.tok.line_nr))
}

fn (mut p Parser) check_name() string {
	name := p.tok.lit
	p.check(.ident)
	return name
}

pub fn (mut p Parser) parse_block() []ast.Stmt {
	p.check(.key_do)
	mut stmts := []ast.Stmt{}

	if p.tok.kind != .key_do {
		for {
			stmts << p.stmt()
			// p.warn('after stmt(): tok=$p.tok.str()')
			if p.tok.kind in [.eof, .key_end] {
				break
			}
		}
	}
	p.check(.key_end)

	// println('nr exprs in block = $exprs.len')
	return stmts
}
