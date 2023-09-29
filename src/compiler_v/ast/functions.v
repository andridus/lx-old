// Copyright (c) 2023 Helder de Sousa. All rights reserved/
// Use of this source code is governed by a MIT license
// that can be found in the LICENSE file

module ast

import compiler_v.types

// pub fn (c CaseClauseExpr) is_underscore() bool {
// 	return match c.expr {
// 		UnderscoreExpr { true }
// 		else { false }
// 	}
// }

// pub fn (mut kw KeywordList) put(ident string, value string, typ types.TypeIdent, atom bool) {
// 	kw.items << Keyword{
// 		idx: kw.items.len + 1
// 		key: ident
// 		val: value
// 		typ: typ
// 		atom: atom
// 	}
// }

pub fn maybe_promote_integer_to_float(expr_a Node, expr_b Node) Node {
	if expr_a.kind is Integer && expr_b.kind is Float {
		value := expr_a.left as int
		return Node{
			left: f64(value)
			meta: Meta{
				ti: types.float_ti
				line: expr_a.meta.line
				inside_parens: expr_a.meta.inside_parens
			}
			kind: NodeKind(Float{})
		}
	} else {
		return expr_a
	}
}

pub fn is_need_to_promote(expr_a Node, expr_b Node) bool {
	if (expr_a.kind is Integer && expr_b.kind is Float)
		|| (expr_b.kind is Integer && expr_a.kind is Float) {
		return true
	} else {
		return false
	}
}
