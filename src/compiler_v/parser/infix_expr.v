// Copyright (c) 2023 Helder de Sousa. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.
module parser

import compiler_v.ast
import compiler_v.types
// import compiler_v.table

fn (mut p Parser) parse_operations_deep(mut meta ast.Meta, left ast.Node, op string, op_prec int, right ast.Node) ast.Node {
	if right.kind is ast.FunctionCaller {
		if right.nodes[0].kind is ast.FunctionCaller {
			if right.is_inside_parens() {
				return p.node_infix(mut meta, left, op, right)
			}
			if op_prec < ast.precedence(right.left.atomic_str()) {
				return p.node_infix(mut meta, left, op, right)
			} else {
				left0 := p.parse_operations_deep(mut meta, left, op, op_prec, right.nodes[0])
				return p.node_infix(mut meta, left0, right.left.atomic_str(), right.nodes[1])
			}
		} else {
			if right.is_inside_parens() {
				return p.node_infix(mut meta, left, op, right)
			}
			if op_prec < ast.precedence(right.left.atomic_str()) {
				return p.node_infix(mut meta, left, op, right)
			} else {
				left0 := p.parse_operations(mut meta, left, op, ast.precedence(op), right.nodes[0],
					false)
				return p.node_infix(mut meta, left0, right.left.atomic_str(), right.nodes[1])
			}
		}
	} else {
		return p.parse_operations(mut meta, left, op, op_prec, right, false)
	}
}

fn (mut p Parser) parse_operations(mut meta ast.Meta, left ast.Node, op string, op_prec int, right ast.Node, inside_parens bool) ast.Node {
	return if right.kind is ast.FunctionCaller {
		if right.is_inside_parens() {
			p.node_infix(mut meta, left, op, right)
		} else if op_prec < ast.precedence(right.left.atomic_str()) {
			p.node_infix(mut meta, left, op, right)
		} else {
			left0 := p.parse_operations_deep(mut meta, left, op, op_prec, right.nodes[0])
			p.node_infix(mut meta, left0, right.left.atomic_str(), right.nodes[1])
		}
	} else {
		p.node_infix(mut meta, left, op, right)
	}
}

fn (mut p Parser) node_infix(mut meta ast.Meta, left ast.Node, op string, right ast.Node) ast.Node {
	mut ti := types.get_default_type(op, left.meta.ti)

	mut left0, mut right0 := p.maybe_update_two_nodes_with_ti(left, right, ti)
	if ast.is_need_to_promote(left, right) {
		left0 = ast.maybe_promote_integer_to_float(left, right)
		right0 = ast.maybe_promote_integer_to_float(right, left)

		ti = left0.get_ti()
	} else {
		if ti.kind == .integer_ && left0.get_ti().kind == .float_ {
			ti = left0.get_ti()
		}
	}
	if ti.kind == .integer_ && left0.meta.ti.kind in [.integer_, .float_] {
		meta.put_ti(left0.meta.ti)
	} else {
		meta.put_ti(ti)
	}
	a := p.node_function_caller(meta, op, [left0, right0], ast.FunctionCaller{
		infix: true
		arity: [left.get_ti().kind.str(), left.get_ti().kind.str()]
	})

	return a
}
