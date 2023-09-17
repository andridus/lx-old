// Copyright (c) 2023 Helder de Sousa. All rights reserved/
// Use of this source code is governed by a MIT license
// that can be found in the LICENSE file
module ast

import compiler_v.types
import compiler_v.token
import strings

pub struct Node {
pub:
	atom  string
	meta  Meta
	kind  types.NodeKind
	nodes []Node
}

[unsafe]
pub fn (n Node) str() string {
	mut static ident_deep := 0
	tab := '${strings.repeat_string(' ', ident_deep)}'
	match n.kind {
		types.Tuple {
			mut str := []string{}
			for n0 in n.nodes {
				unsafe { str << n0.str() }
			}
			return '{' + str.join(', ') + '}'
		}
		types.Atomic, types.Atom {
			return ':${n.atom}'
		}
		types.List {
			mut s := ''
			if n.nodes.len > 1 {
				ident_deep += 2
				mut str := []string{}
				for n0 in n.nodes {
					unsafe { str << n0.str() }
				}
				s = '[\n${tab}${tab}' + str.join(',') + ']'
				ident_deep -= 2
			} else {
				mut str := []string{}
				for n0 in n.nodes {
					unsafe { str << n0.str() }
				}
				s = '[' + str.join(',') + ']'
			}
			return '${tab}${s}'
		}
		else {
			mut s := ''
			mut nw := ''
			if n.nodes.len > 1 {
				ident_deep += 2
				mut str := []string{}
				for n0 in n.nodes {
					unsafe { str << n0.str() }
				}
				s = '[\n${tab}${tab}' + str.join(',\n') + '\n${tab}${tab}]'
				ident_deep -= 2
				nw = '\n${tab}'
			} else {
				mut str := []string{}
				for n0 in n.nodes {
					unsafe { str << n0.str() }
				}
				s = '[' + str.join(',') + ']'
			}
			// ident_deep++
			return '{:${n.atom}, ${n.meta}, ${s}}${nw}'
		}
	}
}

pub type Expr = AssignExpr
	| Atom
	| BinaryExpr
	| BoolLiteral
	| CallEnum
	| CallExpr
	| CallField
	| CaseClauseExpr
	| CharlistLiteral
	| EmptyExpr
	| FloatLiteral
	| Ident
	| IfExpr
	| IntegerLiteral
	| KeywordList
	| MatchExpr
	| MatchVar
	| NilLiteral
	| NotExpr
	| PostfixExpr
	| PrefixExpr
	| StringConcatExpr
	| StringLiteral
	| StructField
	| StructInit
	| TupleLiteral
	| UnaryExpr
	| UnderscoreExpr

pub type Stmt = Block
	| CaseDecl
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
	is_used     bool
}

pub struct EnumDecl {
pub:
	name    string
	values  []string
	starts  int
	is_pub  bool
	size    int
	meta    Meta
	ti      types.TypeIdent
	is_used bool
}

pub struct ExprStmt {
pub:
	expr    Expr = EmptyExpr{}
	ti      types.TypeIdent
	is_used bool
}

pub struct EmptyExpr {
	ti      types.TypeIdent
	is_used bool
}

pub struct Keyword {
	idx     int
	key     string
	val     string
	typ     types.TypeIdent
	ti      types.TypeIdent
	atom    bool
	meta    Meta
	is_used bool
}

pub struct IntegerLiteral {
pub:
	val     int
	meta    Meta
	ti      types.TypeIdent = types.integer_ti
	is_used bool
}

pub struct NilLiteral {
pub:
	val     int
	meta    Meta
	ti      types.TypeIdent = types.nil_ti
	is_used bool
}

pub struct FloatLiteral {
pub:
	val     f32
	meta    Meta
	ti      types.TypeIdent = types.float_ti
	is_used bool
}

pub struct NotExpr {
pub:
	expr    Expr
	meta    Meta
	ti      types.TypeIdent
	is_used bool
}

pub struct UnderscoreExpr {
pub:
	name    string
	meta    Meta
	ti      types.TypeIdent
	is_used bool
}

pub struct StringLiteral {
pub:
	val     string
	meta    Meta
	ti      types.TypeIdent = types.string_ti
	is_used bool
}

pub struct CharlistLiteral {
pub:
	val     []u8
	meta    Meta
	ti      types.TypeIdent = types.charlist_ti
	is_used bool
}

pub struct TupleLiteral {
pub:
	values  []Expr
	meta    Meta
	ti      types.TypeIdent = types.tuple_ti
	is_used bool
}

pub struct BoolLiteral {
pub:
	val     bool
	meta    Meta
	ti      types.TypeIdent = types.bool_ti
	is_used bool
}

pub struct KeywordList {
mut:
	items   []Keyword
	meta    Meta
	ti      types.TypeIdent
	is_used bool
}

pub struct Module {
pub:
	name             string
	stmt             Stmt
	is_parent_module bool
	meta             Meta
	ti               types.TypeIdent
	is_used          bool
}

pub struct Field {
pub:
	name    string
	ti      types.TypeIdent = types.void_ti
	meta    Meta
	is_used bool
}

pub struct StructDecl {
pub:
	name    string
	fields  []Field
	is_pub  bool
	size    int
	meta    Meta
	ti      types.TypeIdent
	is_used bool
}

pub struct StructInit {
pub:
	name    string
	ti      types.TypeIdent
	fields  []string
	exprs   []Expr
	meta    Meta
	is_used bool
}

pub struct StructField {
pub:
	struct_name string
	var_name    string
	name        string
	ti          types.TypeIdent
	expr        Expr
	meta        Meta
	is_used     bool
}

pub struct Import {
pub:
	mods    map[string]string
	meta    Meta
	ti      types.TypeIdent
	is_used bool
}

pub struct Arg {
pub:
	ti      types.TypeIdent
	name    string
	meta    Meta
	is_used bool
}

pub struct FnDecl {
pub:
	name       string
	arity      string
	stmts      []Stmt
	ti         types.TypeIdent
	args       []Arg
	is_private bool
	receiver   Field
	meta       Meta
	is_used    bool
}

pub struct CallEnum {
pub:
	name        string
	val         string
	is_unknown  bool
	is_external bool
	module_path string
	module_name string
	meta        Meta
	ti          types.TypeIdent
	is_used     bool
}

pub struct CallField {
pub:
	name        string
	parent_path []string
	val         string
	meta        Meta
	ti          types.TypeIdent
	is_used     bool
}

pub struct CallExpr {
pub:
	name        string
	arity       string
	args        []Expr
	is_unknown  bool
	is_external bool
	is_c_module bool
	is_v_module bool
	module_path string
	module_name string
	tok         token.Token
	meta        Meta
	ti          types.TypeIdent
	is_used     bool
}

pub struct VarDecl {
pub:
	name    string
	expr    Expr = EmptyExpr{}
	ti      types.TypeIdent
	meta    Meta
	is_used bool
}

pub struct MatchVar {
pub:
	name    string
	expr    Expr = EmptyExpr{}
	ti      types.TypeIdent
	meta    Meta
	is_used bool
}

pub struct CaseDecl {
pub:
	name    string
	ref     string
	eval    Expr = EmptyExpr{}
	clauses []CaseClauseExpr
	exprs   []Expr

	ti      types.TypeIdent
	meta    Meta
	is_used bool
}

pub struct CaseClauseExpr {
pub:
	expr    Expr
	or_expr []Expr
	guard   Expr
	meta    Meta
	ti      types.TypeIdent
	is_used bool
}

pub struct MatchExpr {
pub:
	left     Expr
	right    Expr
	meta     Meta
	left_ti  types.TypeIdent
	right_ti types.TypeIdent
	is_used  bool
}

pub struct File {
pub:
	input_path  string
	output_path string
	file_name   string
	stmts       []Stmt
	ti          types.TypeIdent
	is_used     bool
}

pub struct Ident {
pub:
	name     string
	tok_kind token.Kind
	val      string
	meta     Meta
	ti       types.TypeIdent
	is_used  bool
mut:
	is_pointer bool
}

pub struct Atom {
pub:
	name     string
	tok_kind token.Kind
	val      string
	meta     Meta
	ti       types.TypeIdent = types.atom_ti
	is_used  bool
}

pub struct StringConcatExpr {
pub:
	left    Expr
	right   Expr
	meta    Meta
	ti      types.TypeIdent = types.string_ti
	is_used bool
}

pub struct BinaryExpr {
pub:
	op            token.Kind
	op_precedence int
	left          Expr
	right         Expr
	meta          Meta
	ti            types.TypeIdent
	is_used       bool
}

pub struct UnaryExpr {
pub:
	op      token.Kind
	left    Expr
	meta    Meta
	ti      types.TypeIdent
	is_used bool
}

pub struct PostfixExpr {
pub:
	op      token.Kind
	expr    Expr
	meta    Meta
	ti      types.TypeIdent
	is_used bool
}

pub struct PrefixExpr {
pub:
	op      token.Kind
	right   Expr
	meta    Meta
	ti      types.TypeIdent
	is_used bool
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
	is_used    bool
}

pub struct ForStmt {
pub:
	cond    Expr
	stmts   []Stmt
	meta    Meta
	ti      types.TypeIdent
	is_used bool
}

pub struct AssignExpr {
pub:
	left    Expr
	val     Expr
	op      token.Kind
	meta    Meta
	ti      types.TypeIdent
	is_used bool
}

pub struct Meta {
pub mut:
	ti            types.TypeIdent
	line          int
	inside_parens int
}

pub fn (mut m Meta) put_ti(ti types.TypeIdent) {
	m.ti = ti
}
