// Copyright (c) 2023 Helder de Sousa. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.
module parser

import compiler_v.ast
import compiler_v.table

fn (mut p Parser) ident_expr() ast.Node {
	ident := p.tok.lit
	// mut idents := [ident]
	mut meta := p.meta()
	p.error_pos_in = p.tok.lit.len
	if p.peek_tok.kind == .lpar {
		node1 := p.call_from_module_node(.ident) or {
			p.log('ERROR', err.msg(), p.tok.lit)
			exit(1)
		}
		return node1
		// } else if p.inside_clause {
		// 	p.error_pos_out = p.tok.lit.len
		// 	mut ti := types.void_ti
		// 	if p.inside_clause_eval is ast.Ident {
		// 		l := p.inside_clause_eval as ast.Ident
		// 		var := p.program.table.find_var(l.name, p.context) or {
		// 			p.log_d('ERROR', 'undefined variable `${l.name}`', '', '', p.tok.lit)
		// 			table.Var{}
		// 		}
		// 		ti = var.ti
		// 		p.program.table.register_var(table.Var{
		// 			...var
		// 			name: p.tok.lit
		// 			context: p.context
		// 		})
		// 	}
		// 	a := expr0 as ast.Ident
		// 	node = ast.Expr(ast.Ident{
		// 		...a
		// 		ti: ti
		// 	})
		// 	p.next_token()
		// 	return node, a.ti
	} else {
		p.error_pos_out = p.tok.lit.len
		var := p.program.table.find_var(p.tok.lit, p.context) or {
			p.log_d('ERROR', 'undefined variable `${p.tok.lit}`', '', '', p.tok.lit)
			table.Var{}
		}
		mut ti := var.ti
		p.next_token()

		/// get from struct flow
		if p.tok.kind == .dot {
			p.check(.dot)
			match var.expr.kind {
				ast.Struct {
					stct := var.expr.kind as ast.Struct
					field_name := p.tok.lit

					// check if field exists, shoudl be a tuple
					if stct.fields[field_name].kind is ast.Tuple {
						p.check(.ident)
						fld := stct.exprs[field_name]
						meta.put_ti(fld.meta.ti)
						return p.node(meta, '.', [
							p.node_var(meta, ident, []),
							p.node_atomic(field_name),
						])
					} else {
						p.error_pos_out = field_name.len
						p.log_d('ERROR', 'The field `${field_name}` not exists in struct `${stct.name}`. Try one of ${stct.fields.keys()}',
							'', '', field_name)
					}
				}
				else {}
			}
		}
		// 	if p.tok.kind == .ident {
		// 		expr := var.expr.expr
		// 		type0 := var.type_

		// 		match expr {
		// 			ast.StructInit {
		// 				idx, struct_name := p.program.table.find_type_name(expr.ti)
		// 				type_ := p.program.table.types[idx]
		// 				if type_ is types.Struct {
		// 					mut flds := []string{}
		// 					for f in type_.fields {
		// 						flds << f.name
		// 					}

		// 					if p.tok.lit in flds {
		// 						fld0 := p.tok.lit
		// 						mut idx0 := -1
		// 						for i0 := 0; i0 < expr.fields.len; i0++ {
		// 							if expr.fields[i0] == fld0 {
		// 								idx0 = i0
		// 							}
		// 						}
		// 						if idx0 >= 0 {
		// 							node = ast.StructField{
		// 								var_name: expr0.name
		// 								struct_name: struct_name
		// 								name: expr.fields[idx0]
		// 								expr: expr.exprs[idx0]
		// 								ti: ast.get_ti(expr.exprs[idx0])
		// 							}
		// 							ti = ast.get_ti(node)
		// 							p.next_token()
		// 						} else {
		// 							println('Error on find field')
		// 							exit(1)
		// 						}
		// 					} else {
		// 						p.error_pos_out = p.tok.lit.len
		// 						p.log_d('ERROR', 'The field `${p.tok.lit}` not exists in struct `${expr.ti}`. Try one of ${flds}',
		// 							'', '', p.tok.lit)
		// 					}
		// 				}
		// 			}
		// 			else {
		// 				match type0 {
		// 					types.Struct {
		// 						mut flds := []string{}
		// 						mut is_field := false
		// 						field_name := p.tok.lit
		// 						for f in type0.fields {
		// 							if field_name == f.name {
		// 								is_field = true
		// 								ti = f.ti
		// 							}
		// 							flds << f.name
		// 						}
		// 						if is_field == false {
		// 							p.error_pos_out = p.tok.lit.len
		// 							p.log_d('ERROR', 'The field `${p.tok.lit}` not exists in struct `${type0.name}`. Try one of ${flds}',
		// 								'', '', p.tok.lit)
		// 						}
		// 						p.check(.ident)
		// 						node = ast.Expr(ast.CallField{
		// 							name: field_name
		// 							parent_path: idents
		// 							ti: ti
		// 						})
		// 						//  fld0 := p.tok.lit
		// 						// mut idx0 := -1
		// 						// for i0 := 0; i0 < expr.fields.len; i0++ {
		// 						// 	if expr.fields[i0] == fld0 {
		// 						// 		idx0 = i0
		// 						// 	}
		// 						// }
		// 						// if idx0 >= 0 {
		// 						// 	node = expr.exprs[idx0]
		// 						// 	ti = ast.get_ti(node)
		// 						// 	p.next_token()
		// 						// } else {
		// 						// 	println('Error on find field')
		// 						// 	exit(1)
		// 						// }
		// 					}
		// 					else {
		// 						p.error_pos_out = p.tok.lit.len
		// 						p.log_d('ERROR', 'token `${p.tok.lit}` unacceptable after struct ',
		// 							'', '', p.tok.lit)
		// 					}
		// 				}
		// 			}
		// 		}
		// 	} else {
		// 		p.error_pos_out = p.tok.lit.len
		// 		p.log_d('ERROR', 'token `${p.tok.lit}` unacceptable after struct ', '',
		// 			'', p.tok.lit)
		// 	}
		// } else {
		// if is only ident
		// a := expr0 as ast.Ident
		// node = ast.Expr(ast.Ident{
		// 	...a
		// 	ti: ti
		// })
		// }
		meta.put_ti(ti)
		return p.node_var(meta, ident, [])
	}
}
