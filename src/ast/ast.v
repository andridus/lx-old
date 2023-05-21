// Copyright (c) 2023 Helder de Sousa. All rights reserved/
// Use of this source code is governed by a MIT license
// that can be found in the LICENSE file

module ast

import types
import token

pub type Expr = EmptyExpr
	|	ArrayInit
	| AssignExpr
	| BinaryExpr
	| BoolLiteral
	| CallExpr
	| FloatLiteral
	| Ident
	| IfExpr
	| IndexExpr
	| IntegerLiteral
	| MethodCallExpr
	| PostfixExpr
	| PrefixExpr
	| SelectorExpr
	| StringLiteral
	| StructInit
	| UnaryExpr

pub type Stmt = ExprStmt
	| FnDecl
	| ForCStmt
	| ForInStmt
	| ForStmt
	| Block
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
	stmts []Stmt
	ti   types.TypeIdent
	name string
	args []Arg
	is_top_stmt bool
}

pub struct EmptyExpr {}

pub struct IntegerLiteral {
pub:
	val int
}

pub struct FloatLiteral {
pub:
	val f32
}

pub struct StringLiteral {
pub:
	val string
}

pub struct BoolLiteral {
pub:
	val bool
}

pub struct SelectorExpr {
pub:
	expr  Expr
	field string
}

pub struct Module {
pub:
	name string
	path string
	file_name string
	stmt Stmt
	is_top_stmt bool
}

pub struct Field {
pub:
	name string
	ti   types.TypeIdent
}

pub struct StructDecl {
pub:
	name   string
	fields []Field
	is_pub bool
}

pub struct StructInit {
pub:
	ti     types.TypeIdent
	fields []string
	exprs  []Expr
}

pub struct Import {
pub:
	mods map[string]string
}

pub struct Arg {
pub:
	ti   types.TypeIdent
	name string
}

pub struct FnDecl {
pub:
	name     string
	stmts    []Stmt
	ti       types.TypeIdent
	args     []Arg
	is_priv   bool
	receiver Field
}

pub struct CallExpr {
pub:
	name       string
	args       []Expr
	is_unknown bool
	tok        token.Token
}

pub struct MethodCallExpr {
pub:
	expr       Expr
	name       string
	args       []Expr
	is_unknown bool
	tok        token.Token
}

pub struct Return {
pub:
	exprs []Expr
}

pub struct VarDecl {
pub:
	name string
	expr Expr
	ti   types.TypeIdent
}

pub struct File {
pub:
  input_path string
	output_path string
	file_name string
	stmts []Stmt
}

pub struct Ident {
pub:
	name     string
	tok_kind token.Kind
	value    string
}

pub struct BinaryExpr {
pub:
	op    token.Kind
	op_precedence int
	left  Expr
	right Expr
}

pub struct UnaryExpr {
pub:
	op   token.Kind
	left Expr
}

pub struct PostfixExpr {
pub:
	op   token.Kind
	expr Expr
}

pub struct PrefixExpr {
pub:
	op    token.Kind
	right Expr
}

pub struct IndexExpr {
pub:
	left  Expr
	index Expr
}

pub struct IfExpr {
pub:
	tok_kind   token.Kind
	cond       Expr
	stmts      []Stmt
	else_stmts []Stmt
	ti         types.TypeIdent
	left       Expr
}

pub struct ForStmt {
pub:
	cond  Expr
	stmts []Stmt
}

pub struct ForInStmt {
pub:
	var   string
	cond  Expr
	stmts []Stmt
}

pub struct ForCStmt {
pub:
	init  Stmt // i := 0;
	cond  Expr // i < 10;
	inc   Stmt // i++;
	stmts []Stmt
}

pub struct ReturnStmt {
	tok_kind token.Kind // or pos
	results  []Expr
}

pub struct AssignExpr {
pub:
	left Expr
	val  Expr
	op   token.Kind
}

pub struct ArrayInit {
pub:
	exprs []Expr
	ti    types.TypeIdent
}

pub fn (x Expr) str() string {
	match x {
		BinaryExpr {
			return '(${x.left.str()} ${x.op.str()} ${x.right.str()})'
		}
		UnaryExpr {
			return x.left.str() + x.op.str()
		}
		IntegerLiteral {
			return x.val.str()
		}
		Ident {
			return x.name
		}
		else {
			return ''
		}
	}
}

pub fn (node Stmt) str() string {
	match node {
		VarDecl {
			return node.name + ' = ' + node.expr.str()
		}
		ExprStmt {
			return node.expr.str()
		}
		FnDecl {
			return 'fn ${node.name}() { ${node.stmts.len} stmts }'
		}
		Block {
			return node.str()
		}
		else {
			return '[unhandled stmt str]'
		}
	}
}
