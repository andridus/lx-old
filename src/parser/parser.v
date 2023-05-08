module parser

import ast
import lexer
import token

struct Parser {
mut:
	l              lexer.Lexer
	current_idx_tk u32
	current_token  token.Token
	peek_token     token.Token
}

fn new(l lexer.Lexer) Parser {
	mut p := Parser{
		l: l
	}
	p.next_token()
	p.next_token()
	return p
}

fn (mut p Parser) next_token() {
	p.current_token = p.peek_token
	p.peek_token = p.l.generate_one_token()
}

pub fn (mut p Parser) parse_program() ast.Program {
	mut program := ast.Program{}
	for p.current_token.typ != ._eof {
		statement := p.parse_statement()
		match statement {
			ast.ErrorStatement {
				program.is_error = true
				program.errors << statement.message
				return program
			}
			else {
				program.statements << statement
				program
			}
		}
	}
	return program
}

fn (mut p Parser) parse_statement() ast.Statement {
	mut stmt := []token.Token{}

	if p.expect(._atom) {
		stmt << p.current_token
		p.next_token()
		if p.expect(._assign) {
			stmt << p.current_token
			p.next_token()
			valid_tokens_expr, tokens_expr := p.expect_tokens_for_expression()
			if valid_tokens_expr {
				return p.parse_assign_statement(stmt, tokens_expr) or {
					return p.parse_error_statement(err.msg())
				}
			} else {
				ident := parse_identifier(stmt.first())
				return p.parse_error_statement('Invalid expression for assign the variable `${ident.get_value()}`')
			}
		} else {
			return p.parse_error_statement('Invalid Expression')
		}
	} else {
		return p.parse_error_statement('Invalid Expected Sintaxe')
	}
}

fn (mut p Parser) parse_error_statement(msg string) ast.Statement {
	p.next_token()
	return ast.ErrorStatement{
		message: msg
	}
}

fn (mut p Parser) parse_assign_statement(stmt []token.Token, tkens []token.Token) !ast.Statement {
	p.next_token()
	ident := parse_identifier(stmt.first())
	expr := parse_expression(tkens)!
	return ast.AssignStatement{
		ident: ident
		expr: expr
	}
}

fn (p Parser) expect(typ token.Typ) bool {
	return p.current_token.typ == typ
}

fn (p Parser) expect_tokens_for_expression() (bool, []token.Token) {
	mut tokens := []token.Token{}
	tokens << p.current_token
	return true, tokens
}

fn parse_expression(tokens []token.Token) !ast.Expr {
	if tokens.len >= 3 {
		return parse_expr_three(tokens[0], tokens[1], tokens[1..tokens.len])
	} else if tokens.len == 2 {
		return parse_expr_two(tokens[0], tokens[1])
	} else if tokens.len == 1 {
		return parse_expr_one(tokens[0])
	} else {
		return error('Expression invalid')
	}
}

// 1 + 2 + 5 + 6
// 1 + (2 + (5 + 6))
fn parse_expr_three(left token.Token, op token.Token, right []token.Token) ast.Expr {
	a, _ := ast.tokens_to_literal_type([[op], [left], right])
	return ast.Expr{
		ast: a
		dependencies: []
	}
}

fn parse_expr_two(op token.Token, right token.Token) ast.Expr {
	a, _ := ast.tokens_to_literal_type([[op], [right]])
	return ast.Expr{
		ast: a
		dependencies: []
	}
}

fn parse_expr_one(left token.Token) ast.Expr {
	a, _ := ast.tokens_to_literal_type([[left]])
	return ast.Expr{
		ast: a
		dependencies: []
	}
}

fn parse_identifier(tok token.Token) ast.Identifier {
	a, _ := ast.tokens_to_literal_type([[tok]])
	return ast.Identifier{
		ast: a
		value: tok.literal
	}
}
