module parser

import compiler_v.ast
import compiler_v.token
import compiler_v.types
import compiler_v.table

// fn (mut p Parser) expr_stmt() ast.Node {
// 	node := p.expr(0)
// 	return node
// }

pub fn (mut p Parser) parse_block() ast.Node {
	meta := p.meta()
	if p.inside_ifcase > 0 && p.tok.kind != .key_do {
	} else {
		p.check(.key_do)
	}

	mut stmts := []ast.Node{}

	if p.tok.kind != .key_end {
		for {
			stmts << p.stmt()

			// p.warn('after stmt(): tok=$p.tok.str()')
			if p.tok.kind in [.eof, .key_end] {
				break
			}
			if p.inside_ifcase > 0 && p.tok.kind == .key_else {
				break
			}
		}
	}

	if p.tok.kind == .key_end {
		p.check(.key_end)
	}
	if stmts.len == 1 {
		return p.node_list(meta, [p.node_tuple(meta, [p.node_atomic('do'), stmts[0]])])
	} else {
		// println('nr exprs in block = $exprs.len')
		return p.node(meta, 'do', stmts)
	}
}

fn (mut p Parser) parse_nil_literal() (ast.Expr, types.TypeIdent) {
	node := ast.Expr(ast.NilLiteral{
		is_used: p.in_var_expr
	})
	p.next_token()
	return node, types.nil_ti
}

fn (mut p Parser) parse_number_literal() ast.Node {
	mut meta := p.meta()
	mut node := p.node_default()
	if p.tok.kind == .float {
		node = unsafe { p.node_float(mut meta, p.tok.value.fval) }
	} else {
		node = unsafe { p.node_integer(mut meta, p.tok.value.ival) }
	}
	p.next_token()
	return node
}

fn (mut p Parser) infix_expr(left ast.Node) ast.Node {
	mut meta := p.meta()
	op := p.tok.lit
	op_precedence := ast.precedence(op)
	p.next_token()
	next_precedence := ast.precedence(p.tok.lit)
	right := p.expr_node(next_precedence)
	// if op.is_relational() {
	// 	ti = types.bool_ti
	// }
	node := p.parse_operations(mut meta, left, op, op_precedence, right, p.inside_parens > 0)
	return node
}

fn (mut p Parser) not_expr() (ast.Expr, types.TypeIdent) {
	p.check(.bang)
	expr, ti := p.expr(0)
	node := ast.Expr(ast.NotExpr{
		expr: expr
		ti: ti
		is_used: p.in_var_expr
	})

	return node, ti
}

fn (mut p Parser) underscore_expr() (ast.Expr, types.TypeIdent) {
	p.check(.underscore)
	ti := types.void_ti
	mut name := ''
	if p.tok.kind == .ident {
		name = p.tok.lit
		p.check(.ident)
	}

	node := ast.Expr(ast.UnderscoreExpr{
		name: name
		is_used: p.in_var_expr
	})

	return node, ti
}

fn (mut p Parser) parse_boolean() (ast.Expr, types.TypeIdent) {
	mut node := ast.Expr(ast.EmptyExpr{})
	ti := types.bool_ti
	if p.tok.kind == .key_true {
		node = ast.Expr(ast.BoolLiteral{
			val: true
			is_used: p.in_var_expr
		})
	} else if p.tok.kind == .key_false {
		node = ast.Expr(ast.BoolLiteral{
			val: false
			is_used: p.in_var_expr
		})
	}
	p.next_token()
	return node, ti
}

fn (mut p Parser) atom_expr() ast.Node {
	mut meta := p.meta()
	mut node := p.node_atom(mut meta, p.tok.lit)
	// if p.peek_tok.kind == .dot {
	// 	a, b := p.call_from_module(.atom) or {
	// 		println(err.msg())
	// 		exit(0)
	// 	}
	// 	return a, b
	// } else {
	// node = ast.Atom{
	// 	name: p.tok.lit
	// 	val: p.tok.lit
	// 	tok_kind: p.tok.kind
	// 	is_used: p.in_var_expr
	// }
	p.program.table.find_or_new_atom(p.tok.lit)
	p.check(.atom)
	// }

	return node
}

fn (mut p Parser) if_expr() (ast.Expr, types.TypeIdent) {
	mut else_stmts := ast.Node{}
	p.check(.key_if)
	p.inside_ifcase++
	cond, ti := p.expr(0)
	// stmts := p.parse_block()
	if p.tok.kind == .key_else {
		p.check(.key_else)
		else_stmts = p.parse_block()
	}
	p.inside_ifcase--
	node := ast.IfExpr{
		cond: cond
		// stmts: stmts
		// else_stmts: else_stmts
		ti: ti
		is_used: p.in_var_expr
	}
	return node, node.ti
}

fn (mut p Parser) string_expr() ast.Node {
	mut meta := p.meta()

	mut node := p.node_string(mut meta, p.tok.lit)
	if p.peek_tok.kind != .hash {
		// TODO: interpolate string
		p.next_token()
		return node
	}
	for p.tok.kind == .str {
		p.next_token()
		if p.tok.kind != .hash {
			continue
		}
		p.check(.hash)
		p.expr(0)
	}
	return node
}

fn (mut p Parser) string_concat_expr() (ast.Expr, types.TypeIdent) {
	mut left := ast.Expr(ast.EmptyExpr{})
	mut left_ti := types.void_ti
	// if p.tok.kind == .str {
	// 	left, left_ti = p.string_expr()
	// } else if p.tok.kind == .ident {
	// 	left, left_ti = p.ident_expr()
	// }
	if left_ti.kind != .string_ {
		println('${left} is not a string type')
		exit(0)
	}
	// left, left_ti := p.expr(0)
	p.check(.string_concat)
	right, right_ti := p.expr(0)
	if right_ti.kind != .string_ {
		println('${right} is not a string type')
		exit(0)
	}
	return ast.Expr(ast.StringConcatExpr{
		left: left
		right: right
		is_used: p.in_var_expr
	}), types.string_ti
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

fn (mut p Parser) tuple_expr() (ast.Expr, types.TypeIdent) {
	p.check(.lcbr)
	node0, _ := p.expr(0)
	mut values := [node0]
	for p.tok.kind == .comma {
		p.check(.comma)
		node1, _ := p.expr(0)
		values << node1
	}
	p.check(.rcbr)

	node := ast.TupleLiteral{
		values: values
	}
	return node, node.ti
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
		typ := types.ti_from_token(p.tok)

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

fn (mut p Parser) block_expr(is_top_stmt bool) ast.Node {
	p.check(.key_do)
	meta := p.meta()
	mut stmts := []ast.Node{}
	for p.peek_tok.kind != .eof {
		if p.tok.kind == .key_end {
			break
		}
		stmts << p.stmt()
	}
	p.check(.key_end)
	// return ast.Block{
	// 	name: filename_without_extension(p.file_name)
	// 	stmts: stmts
	// 	is_top_stmt: is_top_stmt
	// 	is_used: p.in_var_expr
	// }
	if stmts.len == 0 {
		return p.node_list(meta, []ast.Node{})
	} else if stmts.len == 1 {
		return p.node_list(meta, [
			p.node_tuple(meta, [
				p.node_atomic('do'),
				stmts[0],
			]),
		])
	} else {
		return p.node_list(p.meta(), [
			p.node_tuple(meta, [
				p.node_atomic('do'),
				p.node(meta, '__block__', stmts),
			]),
		])
	}

	// return p.node("defmodule", [
	// 	p.node("__aliases__", [
	// 		p.node_atomic(p.module_name)
	// 	])
	// 	p.node_tuple([
	// 		p.node("do", []),
	// 		block
	// 	])
	// ])
}

fn (mut p Parser) module_decl() ast.Node {
	meta := p.meta()
	p.tok_inline = p.tok.line_nr
	p.check(.key_defmodule)
	mut module_path_name := [p.tok.lit]
	p.check(.modl)

	for p.tok.kind == .dot {
		p.check(.dot)
		module_path_name << p.tok.lit
		p.check(.modl)
	}
	p.module_name = module_path_name.join('.')

	block := p.block_expr(false)
	return p.node(meta, 'defmodule', [
		p.node(meta, '__aliases__', [
			p.node_atomic(p.module_name),
		]),
		block,
	])
}
