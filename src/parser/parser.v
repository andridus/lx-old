// Copyright (c) 2023 Helder de Sousa. All rights reserved/
// Use of this source code is governed by a MIT license
// that can be found in the LICENSE file

module parser

import ast
import lexer
import token
import types
import table

struct Parser {
	file_name string
mut:
	tok       token.Token
	lexer     &lexer.Lexer
	table     &table.Table
	peek_tok  token.Token
	return_ti types.TypeIdent
}

pub fn parse_stmt(text string, t &table.Table) ast.Stmt {
	l := lexer.new(text)
	mut p := unsafe {
		Parser{
			lexer: &l
			table: t
		}
	}
	p.init_parse_fns()
	p.read_first_token()
	return p.stmt()
}

pub fn (p &Parser) init_parse_fns() {
	// p.prefix_parse_fns = make(100, 100, sizeof(PrefixParseFn))
	// p.prefix_parse_fns[token.Kind.name] = parse_name
	println('')
}

pub fn (mut p Parser) read_first_token() {
	// need to call next() twice to get peek token and current token
	p.next_token()
	p.next_token()
}

fn (mut p Parser) next_token() {
	p.tok = p.peek_tok
	p.peek_tok = p.lexer.generate_one_token()
}

pub fn (mut p Parser) stmt() ast.Stmt {
	match p.tok.kind {
		.key_mut {
			return p.var_decl()
		}
		// .key_for {
		// 	return p.for_statement()
		// }
		// .key_return {
		// 	return p.return_stmt()
		// }
		else {
			// `x := ...`
			if p.tok.kind == .name && p.peek_tok.kind == .decl_assign {
				return p.var_decl()
			}
			expr, ti := p.expr(0)
			return ast.ExprStmt{
				expr: expr
				ti: ti
			}
		}
	}
}

fn (mut p Parser) var_decl() ast.VarDecl {
	is_mut := p.tok.kind == .key_mut // || p.prev_tok == .key_for
	// is_static := p.tok.kind == .key_static
	if p.tok.kind == .key_mut {
		p.check(.key_mut)
		// p.fspace()
	}
	if p.tok.kind == .key_static {
		p.check(.key_static)
		// p.fspace()
	}
	name := p.tok.lit
	p.read_first_token()
	expr, ti := p.expr(token.lowest_prec)
	if _ := p.table.find_var(name) {
		p.error('redefinition of `${name}`')
	}
	p.table.register_var(table.Var{
		name: name
		ti: ti
		is_mut: is_mut
	})
	// println(p.table.names)
	// println('added var `$name` with type $t.name')
	return ast.VarDecl{
		name: name
		expr: expr // p.expr(token.lowest_prec)
		ti: ti
	}
}
