module parser

import compiler_v.ast
import compiler_v.token
import compiler_v.types
import compiler_v.table

fn (mut p Parser) var_decl() ast.Node {
	mut meta := p.meta()
	p.in_var_expr = true
	name := p.tok.lit
	mut ti := types.void_ti
	mut node := p.node_default()
	if p.peek_tok.kind == .typedef {
		mut ti1 := types.void_ti
		p.next_token()
		p.next_token()
		ti1 = p.parse_ti()
		p.next_token()
		node = p.expr_node(token.lowest_prec)
		if CompilerOptions.ensure_left_type in p.compiler_options {
			ti = ti1
		}
		if ti.kind != ti1.kind {
			println('Var type not accept functions returns!')
			exit(1)
		}
	} else {
		p.read_first_token()
		node = p.expr_node(token.lowest_prec)
		ti = node.meta.ti
	}
	if _ := p.program.table.find_var(name, p.context) {
		p.error('rebinding of `${name}`')
	}
	p.program.table.register_var(table.Var{
		name: name
		ti: ti
		is_mut: false
		// expr: ast.ExprStmt{
		// 	expr: expr
		// 	ti: ti
		// }
	})
	p.compiler_options = []
	p.in_var_expr = false
	meta.put_ti(ti)
	return p.node_assign(meta, name, node)
	// {
	// 	name: name
	// 	expr: expr
	// 	ti: ti
	// }
}
