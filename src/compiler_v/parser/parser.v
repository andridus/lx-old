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
import compiler_v.utils
import compiler_v.color

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

pub fn (mut p Parser) read_first_token() {
	p.next_token()
	p.next_token()
}

fn (mut p Parser) next_token() {
	p.tok = p.peek_tok
	p.peek_tok = p.lexer.generate_one_token()
	if p.tok.kind == .newline || p.tok.kind == .line_comment {
		p.next_token()
	}
}

fn (mut p Parser) peek_next_token(num int) token.Token {
	mut num0 := num
	pos := p.lexer.pos
	lines := p.lexer.lines
	pos_inline := p.lexer.pos_inline
	mut peek_tok := p.lexer.generate_one_token()
	for num0 - 1 > 0 {
		peek_tok = p.lexer.generate_one_token()
		for peek_tok.kind == .newline || peek_tok.kind == .line_comment {
			peek_tok = p.lexer.generate_one_token()
		}
		num0--
	}

	p.lexer.pos = pos
	p.lexer.lines = lines
	p.lexer.pos_inline = pos_inline
	return peek_tok
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
		.key_alias {
			mut module_name := []token.Token{}
			p.check(.key_alias)
			module_name << p.tok
			p.check(.modl)
			for p.tok.kind == .dot {
				p.check(.dot)
				if p.tok.kind == .modl {
					module_name << p.tok
					p.check(.modl)
				}
			}
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
		.charlist {
			node, ti = p.charlist_expr()
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

fn (mut p Parser) charlist_expr() (ast.Expr, types.TypeIdent) {
	mut node := ast.CharlistLiteral{
		val: p.tok.lit.bytes()
	}
	if p.peek_tok.kind != .hash {
		p.next_token()
		return node, types.charlist_ti
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
	p.error_pos_in = p.tok.lit.len

	node = ast.Ident{
		name: p.tok.lit
		tok_kind: p.tok.kind
	}
	if p.peek_tok.kind == .lpar {
		node0, ti0 := p.call_from_module(.ident) or {
			p.log('ERROR', err.msg(), p.tok.lit)
			exit(0)
		}
		return node0, ti0
	} else {
		p.error_pos_out = p.tok.lit.len
		var := p.program.table.find_var(p.tok.lit) or {
			p.log_d('ERROR', 'undefined variable `${p.tok.lit}`', '', '', p.tok.lit)
			table.Var{}
		}
		mut ti := var.ti
		p.next_token()
		if p.tok.kind == .dot {
			p.check(.dot)
			if p.tok.kind == .ident {
				expr := var.expr.expr
				match expr {
					ast.StructInit {
						idx, _ := p.program.table.find_type_name(expr.ti)
						type_ := p.program.table.types[idx]
						if type_ is types.Struct {
							mut flds := []string{}
							for f in type_.fields {
								flds << f.name
							}

							if p.tok.lit in flds {
								fld0 := p.tok.lit
								mut idx0 := -1
								for i0 := 0; i0 < expr.fields.len; i0++ {
									if expr.fields[i0] == fld0 {
										idx0 = i0
									}
								}
								if idx0 >= 0 {
									node = expr.exprs[idx0]
									ti = ast.get_ti(node)
									p.next_token()
								} else {
									println('Error on find field')
									exit(0)
								}
							} else {
								p.error_pos_out = p.tok.lit.len
								p.log_d('ERROR', 'The field `${p.tok.lit}` not exists in struct `${expr.ti}`. Try one of ${flds}',
									'', '', p.tok.lit)
							}
						}
					}
					else {
						p.error_pos_out = p.tok.lit.len
						p.log_d('ERROR', 'token `${p.tok.lit}` unacceptable after struct ',
							'', '', p.tok.lit)
					}
				}
			} else {
				p.error_pos_out = p.tok.lit.len
				p.log_d('ERROR', 'token `${p.tok.lit}` unacceptable after struct ', '',
					'', p.tok.lit)
			}
		}

		return node, ti
	}
}

fn (mut p Parser) atom_expr() (ast.Expr, types.TypeIdent) {
	mut node := ast.Expr(ast.EmptyExpr{})

	node = ast.Ident{
		name: p.tok.lit
		tok_kind: p.tok.kind
	}
	if p.peek_tok.kind == .dot {
		a, b := p.call_from_module(.atom) or {
			println(err.msg())
			exit(0)
		}
		return a, b
	} else {
		p.check(.atom)
		p.program.table.find_or_new_atom(p.tok.lit)
		p.next_token()
	}
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
fn (mut p Parser) parse_ast_expr_deep(left ast.Expr, op token.Kind, op_prec int, right ast.Expr) ast.Expr {
	meta := ast.Meta{
		line: p.tok.line_nr - 1
	}
	match right {
		ast.BinaryExpr {
			match right.left {
				ast.BinaryExpr {
					if right.is_inside_parens() {
						return p.ast_bin_expr(left, op, right, meta, op_prec)
					}
					if op_prec < right.op_precedence {
						return p.ast_bin_expr(left, op, right, meta, op_prec)
					} else {
						left0 := p.parse_ast_expr_deep(left, op, op_prec, right.left)
						return p.ast_bin_expr(left0, right.op, right.right, meta, right.op_precedence)
					}
				}
				else {
					if right.is_inside_parens() {
						return p.ast_bin_expr(left, op, right, meta, op_prec)
					}
					if op_prec < right.op_precedence {
						return p.ast_bin_expr(left, op, right, meta, op_prec)
					} else {
						left0 := p.ast_bin_expr(left, op, right.left, meta, op_prec)
						return p.ast_bin_expr(left0, right.op, right.right, meta, right.op_precedence)
					}
				}
			}
		}
		else {
			return p.ast_bin_expr(left, op, right, meta, op_prec)
		}
	}
}

fn (mut p Parser) parse_ast_expr(left ast.Expr, op token.Kind, op_prec int, right ast.Expr, inside_parens bool) ast.Expr {
	meta := ast.Meta{
		line: p.tok.line_nr - 1
		inside_parens: p.inside_parens
	}
	match right {
		ast.BinaryExpr {
			if right.is_inside_parens() {
				return p.ast_bin_expr(left, op, right, meta, op_prec)
			} else if op_prec < right.op_precedence {
				return p.ast_bin_expr(left, op, right, meta, op_prec)
			} else {
				left0 := p.parse_ast_expr_deep(left, op, op_prec, right.left)
				return p.ast_bin_expr(left0, right.op, right.right, meta, right.op_precedence)
			}
		}
		else {
			return p.ast_bin_expr(left, op, right, meta, op_prec)
		}
	}
}

fn (mut p Parser) ast_bin_expr(left ast.Expr, op token.Kind, right ast.Expr, meta ast.Meta, op_prec int) ast.Expr {
	ti := types.get_default_type(op)
	println('${op}: op')
	println('op:${ti}')
	a := ast.Expr(ast.BinaryExpr{
		op: op
		op_precedence: op_prec
		left: left
		meta: ast.Meta{
			...meta
			ti: ti
		}
		right: right
		ti: ti
	})
	match left {
		ast.Ident {
			// try locate var
			var := p.program.table.find_var(left.name) or {
				println('not found var')
				exit(1)
			}
			if var.ti.kind == .void {
				p.program.table.update_var_ti(var, ti)
			}
		}
		else {}
	}
	match right {
		ast.Ident {
			// try locate var
			var := p.program.table.find_var(right.name) or {
				println('not found var')
				exit(1)
			}
			if var.ti.kind == .void {
				p.program.table.update_var_ti(var, ti)
			}
		}
		else {}
	}
	return a
}

pub fn (mut p Parser) log(type_error string, message string, s string) {
	p.log_d(type_error, message, '', '', s)
}

pub fn (mut p Parser) log_d(type_error string, message string, description string, url string, s string) {
	p.error_pos_in, p.error_pos_out = p.lexer.get_in_out(p.error_pos_in, p.error_pos_out,
		s)
	match type_error {
		'ERROR' {
			p.error_d(message, description, url)
		}
		'WARN' {
			p.warn_d(message, description, url)
		}
		else {
			panic(message)
		}
	}
}

pub fn (p &Parser) error(s string) {
	p.error_d(s, '', '')
}

pub fn (p &Parser) error_d(s string, desc string, url string) {
	// print_backtrace()
	mut description := ''
	if desc.len > 0 {
		description += desc
	}
	if url.len > 0 {
		description += '\nView more: ${url}\n'
	}
	println(color.fg(color.red, 0, 'ERROR: ${p.file_name}[${p.tok.line_nr},${p.error_pos_in}]:\n${s}'))
	print(color.fg(color.dark_gray, 3, description))
	println(p.lexer.get_code_between_line_breaks(color.red, p.tok.pos, p.error_pos_in,
		p.error_pos_out, 1, p.tok.line_nr))
	exit(0)
}

pub fn (p &Parser) error_at_line(s string, line_nr int) {
	num := p.tok.lit.len + 2
	println(color.fg(color.red, 0, 'ERROR: ${p.file_name}:${line_nr}: ${s}'))
	println(p.lexer.get_code_between_line_breaks(color.red, p.tok.pos, p.tok.pos_inline - num,
		p.tok.pos_inline, 1, p.tok.line_nr))
}

pub fn (p &Parser) warn(s string) {
	p.warn_d(s, '', '')
}

pub fn (p &Parser) warn_d(s string, desc string, url string) {
	mut description := ''
	if desc.len > 0 {
		description += desc
	}
	if url.len > 0 {
		description += '\nView more: ${url}\n'
	}
	println(color.fg(color.dark_yellow, 0, 'WARN: ${p.file_name}[${p.tok.line_nr},${p.error_pos_in}]:\n${s}'))
	print(color.fg(color.dark_gray, 3, description))
	println(p.lexer.get_code_between_line_breaks(color.red, p.tok.pos, p.error_pos_in,
		p.error_pos_out, 1, p.tok.line_nr))
}

fn (mut p Parser) get_mdl_name() string {
	if p.tok.kind == .modl {
		mut module_toks := [p.tok.lit]
		p.check(.modl)
		for p.tok.kind == .dot {
			p.check(.dot)
			if p.tok.kind == .modl {
				module_toks << p.tok.lit
			}
		}
		return module_toks.join('.').replace('.', '_').to_lower()
	} else {
		return ''
	}
}

fn (mut p Parser) check_name_or_mdl() string {
	mut name := ''
	if p.tok.kind == .ident {
		name = p.tok.lit
		p.check(.ident)
	} else if p.tok.kind == .modl {
		module_name := module_name0([])
		println(module_name)
		p.check(.ident)
	}

	return name
}

fn (mut p Parser) check_name() string {
	name := p.tok.lit
	p.check(.ident)
	return name
}

fn (mut p Parser) check_atom() string {
	name := p.tok.lit
	p.check(.atom)
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

fn (mut p Parser) check_modl_name() string {
	mut name := ''
	if p.tok.kind == .modl {
		name = p.tok.lit
		p.check(.modl)
	}
	if p.tok.kind == .lsbr {
		if name != '' {
			name = '${p.current_module}.${name}'
		} else {
			name = p.current_module
		}
	}
	return name.replace('.', '_').to_lower()
}
