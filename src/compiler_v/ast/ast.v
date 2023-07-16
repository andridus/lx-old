// Copyright (c) 2023 Helder de Sousa. All rights reserved/
// Use of this source code is governed by a MIT license
// that can be found in the LICENSE file

module ast

import compiler_v.types
import compiler_v.token

pub type Expr = ArrayInit
	| AssignExpr
	| BinaryExpr
	| BoolLiteral
	| CallEnum
	| CallExpr
	| CallField
	| CharlistLiteral
	| EmptyExpr
	| FloatLiteral
	| Ident
	| IfExpr
	| IndexExpr
	| IntegerLiteral
	| KeywordList
	| MethodCallExpr
	| NilLiteral
	| PostfixExpr
	| PrefixExpr
	| SelectorExpr
	| StringLiteral
	| StructInit
	| TupleLiteral
	| UnaryExpr

pub type Stmt = Block
	| EnumDecl
	| ExprStmt
	| FnDecl
	| ForCStmt
	| ForInStmt
	| ForStmt
	| Import
	| Module
	| Return
	| StructDecl
	| VarDecl

fn (expr Expr) msg() string {
	return 'OK'
}

pub struct Block {
pub:
	stmts       []Stmt
	ti          types.TypeIdent
	name        string
	args        []Arg
	is_top_stmt bool
}

pub struct EnumDecl {
pub:
	name   string
	values []string
	starts int
	is_pub bool
	size   int
	meta   Meta
	ti     types.TypeIdent
}

pub struct ExprStmt {
pub:
	expr Expr = EmptyExpr{}
	ti   types.TypeIdent
}

pub struct EmptyExpr {
	ti types.TypeIdent
}

pub struct Keyword {
	idx   int
	key   string
	value string
	typ   types.TypeIdent
	ti    types.TypeIdent
	atom  bool
	meta  Meta
}

pub struct IntegerLiteral {
pub:
	val  int
	meta Meta
	ti   types.TypeIdent = types.int_ti
}

pub struct NilLiteral {
pub:
	val  int
	meta Meta
	ti   types.TypeIdent = types.nil_ti
}

pub struct FloatLiteral {
pub:
	val  f32
	meta Meta
	ti   types.TypeIdent = types.float_ti
}

pub struct StringLiteral {
pub:
	val  string
	meta Meta
	ti   types.TypeIdent = types.string_ti
}

pub struct CharlistLiteral {
pub:
	val  []u8
	meta Meta
	ti   types.TypeIdent = types.charlist_ti
}

pub struct TupleLiteral {
pub:
	values []Expr
	meta   Meta
	ti     types.TypeIdent = types.tuple_ti
}

pub struct BoolLiteral {
pub:
	val  bool
	meta Meta
	ti   types.TypeIdent = types.bool_ti
}

pub struct KeywordList {
mut:
	items []Keyword
	meta  Meta
	ti    types.TypeIdent
}

pub struct SelectorExpr {
pub:
	expr  Expr
	field string
	meta  Meta
	ti    types.TypeIdent
}

pub struct Module {
pub:
	name             string
	stmt             Stmt
	is_parent_module bool
	meta             Meta
	ti               types.TypeIdent
}

pub struct Field {
pub:
	name string
	ti   types.TypeIdent
	meta Meta
}

pub struct StructDecl {
pub:
	name   string
	fields []Field
	is_pub bool
	size   int
	meta   Meta
	ti     types.TypeIdent
}

pub struct StructInit {
pub:
	name   string
	ti     types.TypeIdent
	fields []string
	exprs  []Expr
	meta   Meta
}

pub struct Import {
pub:
	mods map[string]string
	meta Meta
	ti   types.TypeIdent
}

pub struct Arg {
pub:
	ti   types.TypeIdent
	name string
	meta Meta
}

pub struct FnDecl {
pub:
	name     string
	arity    string
	stmts    []Stmt
	ti       types.TypeIdent
	args     []Arg
	is_priv  bool
	receiver Field
	meta     Meta
}

pub struct CallEnum {
pub:
	name        string
	value       string
	is_unknown  bool
	is_external bool
	module_path string
	module_name string
	meta        Meta
	ti          types.TypeIdent
}

pub struct CallField {
pub:
	name        string
	parent_path []string
	value       string
	meta        Meta
	ti          types.TypeIdent
}

pub struct CallExpr {
pub:
	name        string
	arity       string
	args        []Expr
	is_unknown  bool
	is_external bool
	is_c_module bool
	module_path string
	module_name string
	tok         token.Token
	meta        Meta
	ti          types.TypeIdent
}

pub struct MethodCallExpr {
pub:
	expr       Expr = EmptyExpr{}
	name       string
	args       []Expr
	is_unknown bool
	tok        token.Token
	meta       Meta
	ti         types.TypeIdent
}

pub struct Return {
pub:
	exprs []Expr
	meta  Meta
	ti    types.TypeIdent
}

pub struct VarDecl {
pub:
	name string
	expr Expr = EmptyExpr{}
	ti   types.TypeIdent
	meta Meta
}

pub struct File {
pub:
	input_path  string
	output_path string
	file_name   string
	stmts       []Stmt
	ti          types.TypeIdent
}

pub struct Ident {
pub:
	name     string
	tok_kind token.Kind
	value    string
	meta     Meta
	ti       types.TypeIdent
mut:
	is_pointer bool
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

pub struct BinaryExpr {
pub:
	op            token.Kind
	op_precedence int
	left          Expr
	right         Expr
	meta          Meta
	ti            types.TypeIdent
}

pub struct UnaryExpr {
pub:
	op   token.Kind
	left Expr
	meta Meta
	ti   types.TypeIdent
}

pub struct PostfixExpr {
pub:
	op   token.Kind
	expr Expr
	meta Meta
	ti   types.TypeIdent
}

pub struct PrefixExpr {
pub:
	op    token.Kind
	right Expr
	meta  Meta
	ti    types.TypeIdent
}

pub struct IndexExpr {
pub:
	left  Expr
	index Expr
	meta  Meta
	ti    types.TypeIdent
}

pub struct IfExpr {
pub:
	tok_kind   token.Kind = .key_if
	cond       Expr
	stmts      []Stmt
	else_stmts []Stmt
	ti         types.TypeIdent
	left       Expr
	meta       Meta
}

pub struct ForStmt {
pub:
	cond  Expr
	stmts []Stmt
	meta  Meta
	ti    types.TypeIdent
}

pub struct ForInStmt {
pub:
	var   string
	cond  Expr
	stmts []Stmt
	meta  Meta
	ti    types.TypeIdent
}

pub struct ForCStmt {
pub:
	init  Stmt // i := 0;
	cond  Expr // i < 10;
	inc   Stmt // i++;
	stmts []Stmt
	meta  Meta
	ti    types.TypeIdent
}

pub struct ReturnStmt {
	tok_kind token.Kind // or pos
	results  []Expr
	meta     Meta
	ti       types.TypeIdent
}

pub struct AssignExpr {
pub:
	left Expr
	val  Expr
	op   token.Kind
	meta Meta
	ti   types.TypeIdent
}

pub struct ArrayInit {
pub:
	exprs []Expr
	ti    types.TypeIdent
	meta  Meta
}

pub struct Meta {
pub:
	ti            types.TypeIdent
	line          int
	inside_parens int
}

pub fn get_ti(a Expr) types.TypeIdent {
	return match a {
		ArrayInit { a.ti }
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
		IndexExpr { a.ti }
		IntegerLiteral { a.ti }
		KeywordList { a.ti }
		MethodCallExpr { a.ti }
		PostfixExpr { a.ti }
		PrefixExpr { a.ti }
		SelectorExpr { a.ti }
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

// pub fn (x Expr) str() string {
// 	match x {
// 		BinaryExpr {
// 			return '{:${x.op.str()}, ${x.meta}, [${x.left.str()}, ${x.right.str()}]}'
// 		}
// 		UnaryExpr {
// 			return x.left.str() + x.op.str()
// 		}
// 		IntegerLiteral {
// 			return x.val.str()
// 		}
// 		StringLiteral {
// 			return "\"${x.val.str()}\""
// 		}
// 		CharlistLiteral {
// 			return '\'${x.val.bytestr()}\''
// 		}
// 		StructInit {
// 			return x.name
// 		}
// 		Ident {
// 			return x.name
// 		}
// 		KeywordList {
// 			mut st := []string{}
// 			for i in x.items {
// 				if !i.atom && i.key.contains_u8(32) {
// 					st << '"${i.key}": ${i.value}'
// 				} else {
// 					st << '${i.key}:  ${i.value}'
// 				}
// 			}
// 			return '[' + st.join(', ') + ']'
// 		}
// 		else {
// 			return '-'
// 		}
// 	}
// }

// pub fn (node Stmt) str() string {
// 	match node {
// 		VarDecl {
// 			return node.name + ' = ' + node.expr.str()
// 		}
// 		ExprStmt {
// 			return node.expr.str()
// 		}
// 		FnDecl {
// 			return 'fn ${node.name}() { ${node.stmts.len} stmts }'
// 		}
// 		Block {
// 			return node.str()
// 		}
// 		else {
// 			return '[unhandled stmt str]'
// 		}
// 	}
// }

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
		.integer { types.int_ti }
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
