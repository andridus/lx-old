module ast

// import token

interface Node {
	token_literal() string
}

interface Statement {
	Node
	statement_node()
	get_ident() Identifier
	get_expr() Expression
	get_ex_ast() string
}

interface Expression {
	Node
	expression_node() LiteralType
}

pub struct Program {
pub mut:
	statements []Statement
	is_error   bool
	errors     []string
}

fn (p Program) token_literal() string {
	if p.statements.len > 0 {
		return p.statements[0].token_literal()
	} else {
		return ''
	}
}

pub struct AssignStatement {
	ident Identifier
	expr  Expression
	pos   []int
	line  []int
}

pub fn (stmt AssignStatement) get_ident() Identifier {
	return stmt.ident
}

pub fn (stmt AssignStatement) get_expr() Expression {
	return stmt.expr
}

pub fn (stmt AssignStatement) get_ex_ast() string {
	left_node := stmt.get_ident().expression_node()
	right_node := stmt.get_expr().expression_node()
	return parse_to_ex('=', left_node, right_node)
}

fn (stmt AssignStatement) statement_node() {}

fn (stmt AssignStatement) token_literal() string {
	return 'ok'
}

pub struct ErrorStatement {
pub:
	message string
	pos     []int
	line    []int
}

pub fn (stmt ErrorStatement) get_ident() Identifier {
	return Identifier{
		value: '_'
	}
}

pub fn (stmt ErrorStatement) get_expr() Expression {
	return Expr{
		ast: Nil{}
	}
}

pub fn (stmt ErrorStatement) get_ex_ast() string {
	return '{}'
}

fn (stmt ErrorStatement) statement_node() {}

fn (stmt ErrorStatement) token_literal() string {
	return 'ok'
}

pub struct Identifier {
	ast   LiteralType
	value string
}

pub fn (id Identifier) get_value() string {
	return id.value
}

pub fn (stmt Identifier) expression_node() LiteralType {
	return stmt.ast
}

fn (id Identifier) token_literal() string {
	return 'id.ast.get_value()'
}

// {atom, metadata, args}
// {atom, metadata, [
// 	{atom, metadata, args},
// 	{atom, metadata, args}
// ]}
pub struct Expr {
	ast          LiteralType //[][]token.Token
	dependencies []Identifier
}

pub fn (stmt Expr) expression_node() LiteralType {
	return stmt.ast
}

fn (stmt Expr) token_literal() string {
	return 'ok'
}

fn (stmt Expr) reduce_to_literal() {
}
