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
import term

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
			lexer: l
			table: t
		}
	}
	p.read_first_token()
	return p.top_stmt()
}
pub fn parse_file(path string, t &table.Table) ast.File {
	println('Parsing file ... "${path}" ')
	text := os.read_file(path) or { panic(err)}
	mut stmts := []ast.Stmt{}
	mut l := lexer.new(text)
	mut p := unsafe {
		Parser {
			lexer: l
			table: t
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
	return ast.File{
		stmts: stmts
	}
}
pub fn (mut p Parser) read_first_token() {
	// need to call next() twice to get peek token and current token
	p.next_token()
	p.next_token()
}
fn (mut p Parser) next_token() {
	p.tok = p.peek_tok
	p.peek_tok = p.lexer.generate_one_token()
	if p.tok.kind  == .newline {
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

		 .key_defmodule {
		 	return p.module_decl()
		 }
		// .key_import {
		// 	return p.import_stmt()
		// }
		// .key_pub {
		// 	match p.peek_tok.kind {
		// 		.key_fn {
		// 			return p.fn_decl()
		// 		}
		// 		.key_struct, .key_union, .key_interface {
		// 			return p.struct_decl()
		// 		}
		// 		else {
		// 			p.error('wrong pub keyword usage')
		// 			return ast.Stmt{}
		// 		}
		// }
		// 	// .key_const {
		// 	// return p.const_decl()
		// 	// }
		// 	// .key_enum {
		// 	// return p.enum_decl()
		// 	// }
		// 	// .key_type {
		// 	// return p.type_decl()
		// 	// }
		// }
		// .key_fn {
		// 	return p.fn_decl()
		// }
		// .key_struct {
		// 	return p.struct_decl()
		// }
		.lsbr {
			p.next_token()
			p.check(.name)
			p.check(.rsbr)
			return ast.Module{}
		}
		else {
			return p.expr_stmt()
			// p.error('`$p.tok.kind` and $p.tok.lit bad top level statement')
			// return ast.Module{} // silence C warning
			// exit(0)
		}
	}
}

fn (mut p Parser) module_decl() ast.Module {
	p.check(.key_defmodule)
	p.check(.modl)
	p.check(.key_do)
	p.expr(0)
	p.check(.key_end)
	return ast.Module{}
}

fn (mut p Parser) expr_stmt() ast.ExprStmt {
	exp, ti := p.expr(0)
	return ast.ExprStmt{ expr: exp, ti: ti}
}
pub fn (mut p Parser) expr(precedence int)  (ast.Expr, types.TypeIdent) {
	mut ti := types.void_ti
	mut node := ast.Expr(ast.EmptyExpr{})
	// Prefix
	match p.tok.kind {
		// .name {
		// 	node,ti = p.name_expr()
		// }
		// .str {
		// 	node,ti = p.string_expr()
		// }
		// -1, -a etc
		// .minus, .amp {
		// 	node,ti = p.prefix_expr()
		// }
		// .amp {
		// p.next()
		// }
		// .key_true, .key_false {
		// 	node = ast.BoolLiteral{
		// 		val: p.tok.kind == .key_true
		// 	}
		// 	ti = types.bool_ti
		// 	p.next_token()
		// }
		.integer {
			node, ti = p.parse_number_literal()
		}
		.float {
			node, ti = p.parse_number_literal()
		}
		.lpar {
			p.check(.lpar)
			node,ti = p.expr(0)
			p.check(.rpar)
		}
		// .key_if {
		// 	node,ti = p.if_expr()
		// }
		// .lsbr {
		// 	node,ti = p.array_init()
		// }

		else {
			p.error('expr(): bad token `$p.tok.str()`')
		}
	}

	// Infix
	for precedence < p.tok.precedence() {
		// if p.tok.kind.is_assign() {
		// 	node = p.assign_expr(node)
		// }
		// else if p.tok.kind == .dot {
		// 	node,ti = p.dot_expr(node, ti)
		// }
		// else if p.tok.kind == .lsbr {
		// 	node,ti = p.index_expr(node)
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
		}
		else {
			return node, ti
		}
	}
	return node, ti
}
fn (mut p Parser) index_expr(left ast.Expr) (ast.Expr,types.TypeIdent) {
	// println('index expr$p.tok.str() line=$p.tok.line_nr')
	p.next_token()
	println('start expr')
	index,_ := p.expr(0)
	println('end expr')
	p.check(.rsbr)
	println('got ]')
	ti := types.int_ti
	node := ast.Expr(ast.IndexExpr{
		left: left
		index: index
	})
	return node,ti
}
fn (mut p Parser) parse_number_literal() (ast.Expr, types.TypeIdent) {
	mut node := ast.Expr(ast.EmptyExpr{})
	mut ti := types.int_ti
	if p.tok.kind == .float {
		node = ast.Expr(ast.FloatLiteral{
			val: unsafe {p.tok.value.fval}
		})
		 ti = types.float_ti
	}
	else {
		node = ast.Expr(ast.IntegerLiteral{
			val: unsafe { p.tok.value.ival }
		})
	}
	p.next_token()
	return node, ti
}
// pub fn (mut p Parser) stmt() ast.Stmt {
// 	match p.tok.kind {
// 		.key_mut {
// 			return p.var_decl()
// 		}
// 		// .key_for {
// 		// 	return p.for_statement()
// 		// }
// 		// .key_return {
// 		// 	return p.return_stmt()
// 		// }
// 		else {
// 			// `x := ...`
// 			if p.tok.kind == .name && p.peek_tok.kind == .decl_assign {
// 				return p.var_decl()
// 			}
// 			expr, ti := p.expr(0)
// 			return ast.ExprStmt{
// 				expr: expr
// 				ti: ti
// 			}
// 		}
// 	}
// }

// fn (mut p Parser) var_decl() ast.VarDecl {
// 	is_mut := p.tok.kind == .key_mut // || p.prev_tok == .key_for
// 	// is_static := p.tok.kind == .key_static
// 	if p.tok.kind == .key_mut {
// 		p.check(.key_mut)
// 		// p.fspace()
// 	}
// 	if p.tok.kind == .key_static {
// 		p.check(.key_static)
// 		// p.fspace()
// 	}
// 	name := p.tok.lit
// 	p.read_first_token()
// 	expr, ti := p.expr(token.lowest_prec)
// 	if _ := p.table.find_var(name) {
// 		p.error('redefinition of `${name}`')
// 	}
// 	p.table.register_var(table.Var{
// 		name: name
// 		ti: ti
// 		is_mut: is_mut
// 	})
// 	// println(p.table.names)
// 	// println('added var `$name` with type $t.name')
// 	return ast.VarDecl{
// 		name: name
// 		expr: expr // p.expr(token.lowest_prec)
// 		ti: ti
// 	}
// }

fn (mut p Parser) infix_expr(left ast.Expr) (ast.Expr, types.TypeIdent) {
	op := p.tok.kind
	// mut typ := p.
	// println('infix op=$op.str()')
	op_precedence := p.tok.precedence()
	p.next_token()
	precedence := p.tok.precedence()
	// precedence = p.peek_tok.precedence()
	right, mut ti := p.expr(precedence)
	if op.is_relational() {
		ti = types.bool_ti
	}
	mut expr := ast.Expr(ast.BinaryExpr{
				op: op
				op_precedence: op_precedence
				left: left
				right: right
			})

	match right {
		ast.BinaryExpr {
			if right.op_precedence < op_precedence {

				expr = ast.Expr(ast.BinaryExpr{
						op: right.op
						op_precedence: op_precedence
						left: ast.Expr(ast.BinaryExpr{
							op: op
							op_precedence: right.op_precedence
							left: left
							right: right.left
						})
						right: right.right
					})
			}
		}
		else {

		}
	}
	return expr, ti
}
pub fn (p &Parser) error(s string) {
	// print_backtrace()
	println(term.bold(term.red('$p.file_name:$p.tok.line_nr: $s')))
	exit(1)
}

pub fn (p &Parser) error_at_line(s string, line_nr int) {
	println(term.bold(term.red('$p.file_name:$line_nr: $s')))
	exit(1)
}

pub fn (p &Parser) warn(s string) {
	println(term.blue('$p.file_name:$p.tok.line_nr: $s'))
}