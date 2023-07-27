module parser

import compiler_v.ast

fn (mut p Parser) pattern_matching() ast.Stmt {
	p.error_pos_in = p.tok.pos - p.tok.lit.len
	if p.tok.kind == .ident {
		return p.var_decl()
	}
	left, left_ti := p.expr(0)
	p.error_pos_out = p.peek_tok.pos
	p.next_token()
	right, right_ti := p.expr(0)
	if ast.is_literal_from_expr(left) {
		if left_ti != right_ti {
			p.log_d('ERROR', 'The `${left_ti.str()}` type in the expression on the left does not match the `${right_ti.str()}` on the right.',
				'', '', '')
			exit(0)
		}
		return ast.ExprStmt{
			expr: ast.MatchExpr{
				left: left
				right: right
				left_ti: left_ti
				right_ti: right_ti
			}
			ti: left_ti
		}
	}
	p.error_pos_out = p.tok.pos
	p.error('Don`t match these expressions!')
	exit(0)
}
