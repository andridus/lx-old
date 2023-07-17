module parser

import compiler_v.ast
import compiler_v.types
import compiler_v.table

fn (mut p Parser) ident_expr() (ast.Expr, types.TypeIdent) {
	mut idents := [p.tok.lit]
	mut node := ast.Expr(ast.EmptyExpr{})

	p.error_pos_in = p.tok.lit.len

	node = ast.Ident{
		name: p.tok.lit
		tok_kind: p.tok.kind
	}
	if p.peek_tok.kind == .lpar {
		node0, ti0 := p.call_from_module(.ident) or {
			p.log('ERROR', err.msg(), p.tok.lit)
			exit(0)
		}
		return node0, ti0
	} else {
		p.error_pos_out = p.tok.lit.len
		var := p.program.table.find_var(p.tok.lit) or {
			p.log_d('ERROR', 'undefined variable `${p.tok.lit}`', '', '', p.tok.lit)
			table.Var{}
		}
		mut ti := var.ti
		p.next_token()
		if p.tok.kind == .dot {
			p.check(.dot)
			if p.tok.kind == .ident {
				expr := var.expr.expr
				type0 := var.type_

				match expr {
					ast.StructInit {
						idx, _ := p.program.table.find_type_name(expr.ti)
						type_ := p.program.table.types[idx]
						if type_ is types.Struct {
							mut flds := []string{}
							for f in type_.fields {
								flds << f.name
							}

							if p.tok.lit in flds {
								fld0 := p.tok.lit
								mut idx0 := -1
								for i0 := 0; i0 < expr.fields.len; i0++ {
									if expr.fields[i0] == fld0 {
										idx0 = i0
									}
								}
								if idx0 >= 0 {
									node = expr.exprs[idx0]
									ti = ast.get_ti(node)
									p.next_token()
								} else {
									println('Error on find field')
									exit(0)
								}
							} else {
								p.error_pos_out = p.tok.lit.len
								p.log_d('ERROR', 'The field `${p.tok.lit}` not exists in struct `${expr.ti}`. Try one of ${flds}',
									'', '', p.tok.lit)
							}
						}
					}
					else {
						match type0 {
							types.Struct {
								mut flds := []string{}
								mut is_field := false
								field_name := p.tok.lit
								for f in type0.fields {
									if field_name == f.name {
										is_field = true
										ti = f.ti
									}
									flds << f.name
								}
								if is_field == false {
									p.error_pos_out = p.tok.lit.len
									p.log_d('ERROR', 'The field `${p.tok.lit}` not exists in struct `${type0.name}`. Try one of ${flds}',
										'', '', p.tok.lit)
								}
								p.check(.ident)
								node = ast.Expr(ast.CallField{
									name: field_name
									parent_path: idents
									ti: ti
								})
								//  fld0 := p.tok.lit
								// mut idx0 := -1
								// for i0 := 0; i0 < expr.fields.len; i0++ {
								// 	if expr.fields[i0] == fld0 {
								// 		idx0 = i0
								// 	}
								// }
								// if idx0 >= 0 {
								// 	node = expr.exprs[idx0]
								// 	ti = ast.get_ti(node)
								// 	p.next_token()
								// } else {
								// 	println('Error on find field')
								// 	exit(0)
								// }
							}
							else {
								p.error_pos_out = p.tok.lit.len
								p.log_d('ERROR', 'token `${p.tok.lit}` unacceptable after struct ',
									'', '', p.tok.lit)
							}
						}
					}
				}
			} else {
				p.error_pos_out = p.tok.lit.len
				p.log_d('ERROR', 'token `${p.tok.lit}` unacceptable after struct ', '',
					'', p.tok.lit)
			}
		}

		return node, ti
	}
}
