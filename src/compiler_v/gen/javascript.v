module gen

import strings
import compiler_v.ast
import term
import compiler_v.table

struct JsGen {
mut:
	out strings.Builder
}

pub fn js_gen(program ast.File, t &table.Table) string {
	mut g := JsGen{
		out: strings.new_builder(100)
	}
	for stmt in program.stmts {
		g.stmt(stmt)
		g.writeln('')
	}
	return g.out.str()
}

pub fn (g &JsGen) save() {}

pub fn (mut g JsGen) write(s string) {
	g.out.write_string(s)
}

pub fn (mut g JsGen) writeln(s string) {
	g.out.writeln(s)
}

fn (mut g JsGen) stmt(node ast.Stmt) {
	match node {
		ast.FnDecl {
			g.write('/** @return { ${node.ti.name} } **/\nfunction ${node.name}(')
			for arg in node.args {
				g.write(' /** @type { arg.ti.name } **/ ${arg.name}')
			}
			g.writeln(') { ')
			for stmt in node.stmts {
				g.stmt(stmt)
			}
			g.writeln('}')
		}
		ast.Return {
			g.write('return ')
			if node.exprs.len > 0 {
			} else {
				g.expr(node.exprs[0])
			}
			g.writeln(';')
		}
		ast.VarDecl {
			g.write('var /* ${node.ti.name} */ ${node.name} = ')
			g.expr(node.expr)
			g.writeln(';')
		}
		ast.ForStmt {
			g.write('while (')
			g.expr(node.cond)
			g.writeln(') {')
			for stmt in node.stmts {
				g.stmt(stmt)
			}
			g.writeln('}')
		}
		ast.StructDecl {
			// g.writeln('typedef struct {')
			// for field in node.fields {
			// g.writeln('\t$field.ti.name $field.name;')
			// }
			g.writeln('var ${node.name} = function() {};')
		}
		ast.ExprStmt {
			g.expr(node.expr)
			match node.expr {
				// no ; after an if expression
				ast.IfExpr {}
				else {
					g.writeln(';')
				}
			}
		}
		else {
			error('jsgen.stmt(): bad node')
		}
	}
}

fn (mut g JsGen) expr(node ast.Expr) {
	// println('cgen expr()')
	match node {
		ast.IntegerLiteral {
			g.write(node.val.str())
		}
		ast.FloatLiteral {
			g.write(node.val.str())
		}
		ast.UnaryExpr {
			g.expr(node.left)
			g.write(' ${node.op} ')
		}
		ast.StringLiteral {
			g.write('tos3("${node.val}")')
		}
		ast.BinaryExpr {
			g.expr(node.left)
			g.write(' ${node.op.str()} ')
			g.expr(node.right)
		}
		// `user := User{name: 'Bob'}`
		ast.StructInit {
			g.writeln('/*${node.ti.name}*/{')
			for i, field in node.fields {
				g.write('\t${field} : ')
				g.expr(node.exprs[i])
				g.writeln(', ')
			}
			g.write('}')
		}
		ast.CallExpr {
			g.write('${node.name}(')
			for i, expr in node.args {
				g.expr(expr)
				if i != node.args.len - 1 {
					g.write(', ')
				}
			}
			g.write(')')
		}
		ast.Ident {
			g.write('${node.name}')
		}
		ast.BoolLiteral {
			if node.val == true {
				g.write('true')
			} else {
				g.write('false')
			}
		}
		ast.IfExpr {
			g.write('if (')
			g.expr(node.cond)
			g.writeln(') {')
			for stmt in node.stmts {
				g.stmt(stmt)
			}
			g.writeln('}')
		}
		else {
			println(term.red('jsgen.expr(): bad node'))
		}
	}
}
