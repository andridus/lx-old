// Copyright (c) 2023 Helder de Sousa. All rights reserved/
// Use of this source code is governed by a MIT license
// that can be found in the LICENSE file

module ast

import compiler_v.types
import compiler_v.token

pub type Expr = AssignExpr
	| Atom
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
	| IntegerLiteral
	| KeywordList
	| NilLiteral
	| PostfixExpr
	| PrefixExpr
	| StringLiteral
	| StructInit
	| TupleLiteral
	| UnaryExpr

pub type Stmt = Block
	| EnumDecl
	| ExprStmt
	| FnDecl
	| ForStmt
	| Import
	| Module
	| StructDecl
	| VarDecl

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
	ti   types.TypeIdent = types.integer_ti
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

pub struct Atom {
pub:
	name     string
	tok_kind token.Kind
	value    string
	meta     Meta
	ti       types.TypeIdent = types.atom_ti
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

pub struct AssignExpr {
pub:
	left Expr
	val  Expr
	op   token.Kind
	meta Meta
	ti   types.TypeIdent
}

pub struct Meta {
pub:
	ti            types.TypeIdent
	line          int
	inside_parens int
}
