module parser

import compiler_v.ast
import compiler_v.token
import compiler_v.types
import compiler_v.table

fn (mut p Parser) parse_ast_expr_deep(left ast.Expr, op token.Kind, op_prec int, right ast.Expr) ast.Expr {
	meta := ast.Meta{
		line: p.tok.line_nr - 1
	}
	match right {
		ast.BinaryExpr {
			match right.left {
				ast.BinaryExpr {
					if right.is_inside_parens() {
						return p.ast_bin_expr(left, op, right, meta, op_prec)
					}
					if op_prec < right.op_precedence {
						return p.ast_bin_expr(left, op, right, meta, op_prec)
					} else {
						left0 := p.parse_ast_expr_deep(left, op, op_prec, right.left)
						return p.ast_bin_expr(left0, right.op, right.right, meta, right.op_precedence)
					}
				}
				else {
					if right.is_inside_parens() {
						return p.ast_bin_expr(left, op, right, meta, op_prec)
					}
					if op_prec < right.op_precedence {
						return p.ast_bin_expr(left, op, right, meta, op_prec)
					} else {
						left0 := p.ast_bin_expr(left, op, right.left, meta, op_prec)
						return p.ast_bin_expr(left0, right.op, right.right, meta, right.op_precedence)
					}
				}
			}
		}
		else {
			return p.ast_bin_expr(left, op, right, meta, op_prec)
		}
	}
}

fn (mut p Parser) parse_ast_expr(left ast.Expr, op token.Kind, op_prec int, right ast.Expr, inside_parens bool) ast.Expr {
	meta := ast.Meta{
		line: p.tok.line_nr - 1
		inside_parens: p.inside_parens
	}
	match right {
		ast.BinaryExpr {
			if right.is_inside_parens() {
				return p.ast_bin_expr(left, op, right, meta, op_prec)
			} else if op_prec < right.op_precedence {
				return p.ast_bin_expr(left, op, right, meta, op_prec)
			} else {
				left0 := p.parse_ast_expr_deep(left, op, op_prec, right.left)
				return p.ast_bin_expr(left0, right.op, right.right, meta, right.op_precedence)
			}
		}
		else {
			return p.ast_bin_expr(left, op, right, meta, op_prec)
		}
	}
}

fn (mut p Parser) ast_bin_expr(left ast.Expr, op token.Kind, right ast.Expr, meta ast.Meta, op_prec int) ast.Expr {
	mut ti := types.get_default_type(op)
	mut left0 := left
	mut right0 := right
	if ast.is_need_to_promote(left, right) {
		left0 = ast.maybe_promote_integer_to_float(left, right)
		right0 = ast.maybe_promote_integer_to_float(right, left)
		ti = ast.get_ti(left0)
	} else {
		if ti.kind == .integer_ && ast.get_ti(left0).kind == .float_ {
			ti = ast.get_ti(left0)
		}
	}
	a := ast.Expr(ast.BinaryExpr{
		op: op
		op_precedence: op_prec
		left: left0
		meta: ast.Meta{
			...meta
			ti: ti
		}
		right: right0
		ti: ti
		is_used: p.in_var_expr
	})
	if left0 is ast.Ident {
		c := left0 as ast.Ident
		// try locate var
		var := p.program.table.find_var(c.name, p.context) or {
			println('not found var')
			exit(1)
		}
		if var.ti.kind == .void_ {
			p.program.table.update_var_ti(var, ti)
		}
	}
	if right0 is ast.Ident {
		c := left0 as ast.Ident
		// try locate var
		var := p.program.table.find_var(c.name, p.context) or {
			println('not found var')
			exit(1)
		}
		if var.ti.kind == .void_ {
			p.program.table.update_var_ti(var, ti)
		}
	}
	return a
}
