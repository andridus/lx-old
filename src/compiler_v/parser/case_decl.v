module parser

import compiler_v.ast
import compiler_v.types

fn (mut p Parser) case_decl() ast.CaseDecl {
	p.in_var_expr = true
	ref := p.add_context('case')
	name := p.tok.lit
	p.check(.key_case)
	mut clauses := []ast.CaseClauseExpr{}
	mut exprs := []ast.Expr{}
	mut expr_ti := types.void_ti
	mut first_clause := true
	mut first_expr := true
	mut eval, mut cl_ti := p.expr(0)

	p.check(.key_do)
	for p.tok.kind != .key_end {
		p.error_pos_in = p.tok.pos - p.tok.lit.len
		p.inside_clause = true
		p.inside_clause_eval = eval
		mut cl, ti0 := p.case_clause(cl_ti, true)
		p.inside_clause = false
		if ti0 != cl_ti {
			if first_clause {
				cl_ti = ti0
			} else {
				p.error_pos_out = p.tok.pos
				p.log_d('ERROR', ' Clauses should be the same type of `${cl_ti}`, instead `${ti0}`',
					'', '', p.tok.lit)
			}
		}
		first_clause = false
		clauses << cl

		p.check(.right_arrow)
		mut ex, ti1 := p.case_expr()
		if ti1 != expr_ti {
			if first_expr {
				expr_ti = ti1
			} else if ex is ast.UnderscoreExpr {
				// ignore if is underscore and update ti
				un := ex as ast.UnderscoreExpr
				ex = ast.UnderscoreExpr{
					...un
					ti: expr_ti
				}
			} else {
				p.error_pos_out = p.tok.pos
				p.log_d('ERROR', ' Returned expressions should be the same type of `${expr_ti}`, instead `${ti1}`',
					'', '', p.tok.lit)
			}
		}
		first_expr = false
		exprs << ex
	}
	p.check(.key_end)

	p.context.delete(0)
	p.drop_context()
	return ast.CaseDecl{
		name: name
		ref: ref
		eval: eval
		clauses: clauses
		exprs: exprs
		ti: expr_ti
	}
}

pub fn (mut p Parser) case_clause(ti0 types.TypeIdent, accept_or bool) (ast.CaseClauseExpr, types.TypeIdent) {
	mut expr := ast.Expr(ast.EmptyExpr{})
	mut or_expr := []ast.Expr{}
	mut guard := ast.Expr(ast.EmptyExpr{})
	mut ti := types.void_ti
	expr, ti = p.expr(0)
	if expr is ast.UnderscoreExpr {
		// ignore if is underscore and update ti
		un := expr as ast.UnderscoreExpr
		ti = ti0
		expr = ast.UnderscoreExpr{
			...un
			ti: ti0
		}
	}
	for p.tok.kind == .pipe {
		p.check(.pipe)
		or_expr0, _ := p.case_clause(ti0, false)
		or_expr << or_expr0
	}
	if p.tok.kind == .key_when {
		p.check(.key_when)
		guard, _ = p.expr(0)
	}
	if p.tok.kind == .comma {
		p.check(.comma)
		guard, _ = p.expr(0)
	}

	// evaluate guards
	//
	return ast.CaseClauseExpr{
		expr: expr
		or_expr: or_expr
		guard: guard
		ti: ti
	}, ti
}

pub fn (mut p Parser) case_expr() (ast.Expr, types.TypeIdent) {
	expr, ti := p.expr(0)
	return expr, ti
}
