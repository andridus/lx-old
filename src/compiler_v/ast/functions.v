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
		CallExpr { a.ti }
		CallEnum { a.ti }
		CallField { a.ti }
		CharlistLiteral { a.ti }
		TupleLiteral { a.ti }
		NilLiteral { a.ti }
		EmptyExpr { a.ti }
		FloatLiteral { a.ti }
		Ident { a.ti }
		IfExpr { a.ti }
		IntegerLiteral { a.ti }
		KeywordList { a.ti }
		PostfixExpr { a.ti }
		PrefixExpr { a.ti }
		StringLiteral { a.ti }
		StructInit { a.ti }
		UnaryExpr { a.ti }
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
