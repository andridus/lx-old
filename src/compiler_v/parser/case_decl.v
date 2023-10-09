// Copyright (c) 2023 Helder de Sousa. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.
module parser

import compiler_v.ast
import compiler_v.types

fn (mut p Parser) case_decl() ast.Node {
	meta := p.meta()
	// p.in_var_expr = true
	ref := p.add_context('case')
	name := p.tok.lit
	p.check(.key_case)
	mut clauses := []ast.Node{}
	mut exprs := []ast.Node{}
	mut expr_ti := types.void_ti
	mut first_clause := true
	mut first_expr := true
	mut eval_node := p.expr_node(0)

	p.check(.key_do)
	for p.tok.kind != .key_end {
		// meta0 := p.meta()
		p.inside_clause = true
		p.inside_clause_eval = eval_node
		mut clause_node := p.case_clause(eval_node.meta.ti, true)
		p.inside_clause = false
		if clause_node.meta.ti != eval_node.meta.ti {
			if first_clause {
				// put the clause  ti from eval node
			} else {
				p.log_d('ERROR', ' Clauses should be the same type of `${clause_node.meta.ti}`, instead `${eval_node.meta.ti}`',
					'', '', p.tok.lit)
			}
		}
		first_clause = false
		clauses << clause_node

		p.check(.right_arrow)
		mut expr_node := p.expr_node(0)
		if expr_node.meta.ti != expr_ti {
			if first_expr {
				expr_ti = expr_node.meta.ti
			} else {
				p.error_pos_out = p.tok.pos
				p.log_d('ERROR', ' Returned expressions should be the same type of `${expr_ti}`, instead `${expr_node.meta.ti}`',
					'', '', p.tok.lit)
			}
		}
		first_expr = false
		exprs << expr_node
	}
	p.check(.key_end)

	p.context.delete(0)
	p.drop_context()
	return p.node_case(meta, ast.Case{
		name: name
		ref: ref
		eval: eval_node
		clauses: clauses
		exprs: exprs
		ti: expr_ti
	})
}

pub fn (mut p Parser) case_clause(ti0 types.TypeIdent, accept_or bool) ast.Node {
	mut or_expr := []ast.Node{}
	mut expr := p.expr_node(0)
	if expr.kind is ast.Underscore {
		// ignore if is underscore and update ti
		expr.meta.put_ti(ti0)
	}

	if p.tok.kind == .key_when {
		p.check(.key_when)
		guard := p.expr_node(0)
		expr = p.node(expr.meta, 'when', [expr, guard])
	}
	if p.tok.kind == .comma {
		p.check(.comma)
		guard := p.expr_node(0)
		expr = p.node(expr.meta, 'when', [expr, guard])
	}

	for p.tok.kind == .pipe {
		p.check(.pipe)
		or_expr << expr
		or_expr0 := p.case_clause(ti0, false)
		or_expr << or_expr0
	}
	if or_expr.len > 0 {
		expr = p.node(expr.meta, '|', or_expr)
	}

	return expr
}
