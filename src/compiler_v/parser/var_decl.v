// Copyright (c) 2023 Helder de Sousa. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.
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
	existent_var := p.program.table.find_var(name, p.context) or {
		table.Var{
			name: name
			ti: ti
			expr: p.node_default()
		}
		// p.error('rebinding of `${name}`')
	}
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
		} else {
			if existent_var.is_valid {
				ti = existent_var.expr.meta.ti
			} else {
				ti = ti1
			}
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

	p.program.table.register_var(table.Var{
		...existent_var
		is_valid: true
		ti: ti
		expr: node
	})
	p.compiler_options = []
	p.in_var_expr = false
	meta.put_ti(ti)
	return p.node_assign(meta, name, node)
}
