module parser

import compiler_v.ast

fn (mut p Parser) pattern_matching() ast.Node {
	p.error_pos_in = p.tok.pos - p.tok.lit.len
	if p.tok.kind == .ident {
		return p.var_decl()
	}
	left := p.expr_node(0)
	left_ti := left.meta.ti
	p.error_pos_out = p.peek_tok.pos
	p.next_token()
	right := p.expr_node(0)
	right_ti := right.meta.ti
	if left.kind.is_literal() {
		if left_ti != right_ti {
			p.log_d('ERROR', 'The `${left_ti.str()}` type in the expression on the left does not match the `${right_ti.str()}` on the right.',
				'', '', '')
			exit(0)
		}
		return p.node_default()
		// ast.ExprStmt{
		// 	expr: ast.MatchExpr{
		// 		left: left
		// 		right: right
		// 		left_ti: left_ti
		// 		right_ti: right_ti
		// 		is_used: p.in_var_expr
		// 	}
		// 	ti: left_ti
		// }
	}
	p.error_pos_out = p.tok.pos
	p.error('Don`t match these expressions!')
	exit(1)
}
