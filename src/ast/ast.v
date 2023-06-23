// Copyright (c) 2023 Helder de Sousa. All rights reserved/
// Use of this source code is governed by a MIT license
// that can be found in the LICENSE file

module ast

import types
import token

pub type Expr = ArrayInit
	| AssignExpr
	| BinaryExpr
	| BoolLiteral
	| CallExpr
	| EmptyExpr
	| FloatLiteral
	| Ident
	| IfExpr
	| IndexExpr
	| IntegerLiteral
	| KeywordList
	| MethodCallExpr
	| PostfixExpr
	| PrefixExpr
	| SelectorExpr
	| StringLiteral
	| StructInit
	| UnaryExpr

pub type Stmt = Block
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

pub struct ExprStmt {
pub:
	expr Expr
	ti   types.TypeIdent
}

pub struct Block {
pub:
	stmts       []Stmt
	ti          types.TypeIdent
	name        string
	args        []Arg
	is_top_stmt bool
}

pub struct EmptyExpr {}

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
	ti   types.TypeIdent
}

pub struct FloatLiteral {
pub:
	val  f32
	meta Meta
	ti   types.TypeIdent
}

pub struct StringLiteral {
pub:
	val  string
	meta Meta
	ti   types.TypeIdent
}

pub struct BoolLiteral {
pub:
	val  bool
	meta Meta
	ti   types.TypeIdent
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
	name        string
	path        string
	file_name   string
	stmt        Stmt
	is_top_stmt bool
	meta        Meta
	ti          types.TypeIdent
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
	meta   Meta
	ti     types.TypeIdent
}

pub struct StructInit {
pub:
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
	stmts    []Stmt
	ti       types.TypeIdent
	args     []Arg
	is_priv  bool
	receiver Field
	meta     Meta
}

pub struct CallExpr {
pub:
	name        string
	args        []Expr
	is_unknown  bool
	is_external bool
	module_path string
	module_name string
	tok         token.Token
	meta        Meta
	ti          types.TypeIdent
}

pub struct MethodCallExpr {
pub:
	expr       Expr
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
	expr Expr
	ti   types.TypeIdent
	meta Meta
}

pub struct File {
pub:
	input_path  string
	output_path string
	file_name   string
	stmts       []Stmt
}

pub struct Ident {
pub:
	name     string
	tok_kind token.Kind
	value    string
	meta     Meta
	ti       types.TypeIdent
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
	tok_kind   token.Kind
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
	line          int
	inside_parens int
}

pub fn (e BinaryExpr) is_inside_parens() bool {
	return e.meta.inside_parens > 0
}

fn (m Meta) str() string {
	return '[line: ${m.line}]'
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
// 			return ''
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
