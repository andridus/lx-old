module ast

import compiler_v.types
import compiler_v.token

fn (expr Expr) msg() string {
	return 'OK'
}

pub fn (i Ident) is_pointer() bool {
	return i.is_pointer == true
}

pub fn (mut i Ident) set_pointer() {
	i.is_pointer = true
}

pub fn (mut i Ident) unset_pointer() {
	i.is_pointer = false
}

pub fn get_ti(a Expr) types.TypeIdent {
	return match a {
		AssignExpr { a.ti }
		BinaryExpr { a.ti }
		BoolLiteral { a.ti }
		NotExpr { a.ti }
		CallExpr { a.ti }
		CallEnum { a.ti }
		CallField { a.ti }
		CharlistLiteral { a.ti }
		TupleLiteral { a.ti }
		MatchExpr { a.left_ti }
		NilLiteral { a.ti }
		EmptyExpr { a.ti }
		FloatLiteral { a.ti }
		Ident { a.ti }
		Atom { a.ti }
		IfExpr { a.ti }
		IntegerLiteral { a.ti }
		KeywordList { a.ti }
		PostfixExpr { a.ti }
		PrefixExpr { a.ti }
		StringLiteral { a.ti }
		StringConcatExpr { a.ti }
		StructInit { a.ti }
		UnaryExpr { a.ti }
	}
}

pub fn get_is_used(a Expr) bool {
	return match a {
		AssignExpr { a.is_used }
		BinaryExpr { a.is_used }
		BoolLiteral { a.is_used }
		NotExpr { a.is_used }
		CallExpr { a.is_used }
		CallEnum { a.is_used }
		CallField { a.is_used }
		CharlistLiteral { a.is_used }
		TupleLiteral { a.is_used }
		MatchExpr { a.is_used }
		NilLiteral { a.is_used }
		EmptyExpr { a.is_used }
		FloatLiteral { a.is_used }
		Ident { a.is_used }
		Atom { a.is_used }
		IfExpr { a.is_used }
		IntegerLiteral { a.is_used }
		KeywordList { a.is_used }
		PostfixExpr { a.is_used }
		PrefixExpr { a.is_used }
		StringLiteral { a.is_used }
		StringConcatExpr { a.is_used }
		StructInit { a.is_used }
		UnaryExpr { a.is_used }
	}
}

pub fn (e BinaryExpr) is_inside_parens() bool {
	return e.meta.inside_parens > 0
}

fn (m Meta) str() string {
	return '[line: ${m.line}, type: ${m.ti} ]'
}

pub fn (mut kw KeywordList) put(ident string, value string, typ types.TypeIdent, atom bool) {
	kw.items << Keyword{
		idx: kw.items.len + 1
		key: ident
		value: value
		typ: typ
		atom: atom
	}
}

pub fn type_from_token(tok token.Token) types.TypeIdent {
	return match tok.kind {
		.integer { types.integer_ti }
		.float { types.float_ti }
		.str { types.string_ti }
		else { types.void_ti }
	}
}

pub fn is_literal_from_expr(expr Expr) bool {
	return match expr {
		BoolLiteral, CharlistLiteral, FloatLiteral, IntegerLiteral, NilLiteral, StringLiteral,
		StructInit, TupleLiteral {
			true
		}
		else {
			false
		}
	}
}

pub fn is_literal_from_stmt(stmt Stmt) bool {
	return match stmt {
		ExprStmt { is_literal_from_expr(stmt.expr) }
		else { false }
	}
}

pub fn maybe_promote_integer_to_float(expr_a Expr, expr_b Expr) Expr {
	if expr_a is IntegerLiteral && expr_b is FloatLiteral {
		c := expr_a as IntegerLiteral
		return Expr(FloatLiteral{
			val: c.val
		})
	} else {
		return expr_a
	}
}

pub fn is_need_to_promote(expr_a Expr, expr_b Expr) bool {
	if (expr_a is IntegerLiteral && expr_b is FloatLiteral)
		|| (expr_b is IntegerLiteral && expr_a is FloatLiteral) {
		return true
	} else {
		return false
	}
}