module gen

import strings
import compiler_v.ast
import term
import compiler_v.table
import os
import types

struct ErlGen {
	program &ast.File
	table   &table.Table
mut:
	out strings.Builder
}

pub fn erl_gen(program ast.File, t table.Table) ErlGen {
	mut g := ErlGen{
		program: &program
		table: &t
		out: strings.new_builder(100)
	}
	for stmt in program.stmts {
		g.stmt(stmt, false)
	}
	return g
}

pub fn (mut g ErlGen) ast() string {
	return g.out.str()
}

pub fn (mut g ErlGen) save() {
	for stmt in g.program.stmts {
		match stmt {
			ast.Module {
				os.rmdir_all(g.program.output_path) or { println(error) }
				if !os.is_dir(g.program.output_path) {
					os.mkdir(g.program.output_path) or { println(error) }
				}
				os.write_file('${g.program.output_path}/${stmt.name}.erl', g.out.str()) or {
					println(error)
				}
			}
			else {}
		}
	}
}

pub fn (mut g ErlGen) write(s string) {
	g.out.write_string(s)
}

pub fn (mut g ErlGen) writeln(s string) {
	g.out.writeln(s)
}

fn (mut g ErlGen) stmt(node ast.Stmt, same_expr bool) {
	match node {
		ast.Module {
			mut exports := []string{}
			for _, fns in g.table.fns {
				exports << '${fns.name}/${fns.args.len}'
			}
			g.writeln('-module(\'${node.name}\').')
			g.writeln('-export([${exports.join(',')}]).')
			g.stmt(node.stmt, false)
		}
		ast.Block {
			if node.is_top_stmt {
				g.writeln('-module(${node.name}).')
				g.writeln('-export([main/0]).')
				g.write('main() -> ')

				mut total := node.stmts.len
				mut current := 0
				for stmt in node.stmts {
					if current > 0 {
						g.write('          ')
					}
					if current + 1 == total {
						g.stmt(stmt, false)
					} else {
						g.stmt(stmt, true)
					}
					current++
				}
			} else {
				for stmt in node.stmts {
					g.stmt(stmt, true)
				}
			}
		}
		ast.FnDecl {
			mut total := node.args.len
			mut current := 0
			// print types
			if node.ti != types.void_ti {
				g.write('\n-spec ${node.name}(')
				for current < total {
					g.write('${node.args[current].ti}()')

					current++
					if current < total {
						g.write(', ')
					}
				}
				g.write(') -> ')
				g.write('${node.ti}()')
				g.endln(false)
			}
			g.write('${node.name}(')
			///
			current = 0
			for current < total {
				g.write('${node.args[current].name.capitalize()}')
				current++
				if current < total {
					g.write(', ')
				}
			}
			g.write(') -> ')

			total = node.stmts.len
			current = 0
			for stmt in node.stmts {
				if current > 0 {
					g.write('          ')
				}
				if current + 1 == total {
					g.stmt(stmt, false)
				} else {
					g.stmt(stmt, true)
				}
				current++
			}
		}
		ast.Return {
			g.write('return ')
			if node.exprs.len > 0 {
			} else {
				g.expr(node.exprs[0], same_expr)
			}
			g.endln(same_expr)
		}
		ast.VarDecl {
			g.write('{match, ${node.meta.line}, {var, ${node.meta.line}, \'${node.name.capitalize()}\'}, ')
			g.expr(node.expr, same_expr)
			g.write('}')
		}
		ast.ForStmt {
			g.write('while (')
			g.expr(node.cond, same_expr)
			g.writeln(') {')
			for stmt in node.stmts {
				g.stmt(stmt, same_expr)
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
			g.expr(node.expr, same_expr)
			match node.expr {
				// no ; after an if expression
				ast.IfExpr {}
				else {
					g.endln(same_expr)
				}
			}
		}
		else {
			error('erlgen.stmt(): bad node')
		}
	}
}

fn (mut g ErlGen) endln(same_expr bool) {
	if same_expr {
		g.writeln('')
	} else {
		g.writeln('')
	}
}

fn (mut g ErlGen) expr(node ast.Expr, same_expr bool) {
	// println('cgen expr()')
	match node {
		ast.IntegerLiteral {
			g.write('{integer, ${node.meta.line}, ${node.val.str()}}')
		}
		ast.FloatLiteral {
			g.write('{float, ${node.meta.line}, ${node.val}}')
		}
		ast.UnaryExpr {
			g.expr(node.left, same_expr)
			g.write(' ${node.op} ')
		}
		ast.StringLiteral {
			g.write('{string, ${node.meta.line}, "${node.val}"}')
		}
		ast.BinaryExpr {
			g.write('{op, ${node.meta.line}, \'${node.op.str()}\', ')
			g.expr(node.left, same_expr)
			g.write(', ')
			g.expr(node.right, same_expr)
			g.write('}')
		}
		// `user := User{name: 'Bob'}`
		ast.StructInit {
			g.writeln('/*${node.ti.name}*/{')
			for i, field in node.fields {
				g.write('\t${field} : ')
				g.expr(node.exprs[i], same_expr)
				g.writeln(', ')
			}
			g.write('}')
		}
		ast.CallExpr {
			g.write('${node.name}(')
			for i, expr in node.args {
				g.expr(expr, same_expr)
				if i != node.args.len - 1 {
					g.write(', ')
				}
			}
			g.write(')')
		}
		ast.Ident {
			g.write('{var, ${node.meta.line}, \'${node.name.capitalize()}\'}')
		}
		ast.BoolLiteral {
			if node.val == true {
				g.write('{atom, ${node.meta.line}, true}')
			} else {
				g.write('{atom, ${node.meta.line}, false}')
			}
		}
		ast.IfExpr {
			g.write('if (')
			g.expr(node.cond, same_expr)
			g.writeln(') {')
			for stmt in node.stmts {
				g.stmt(stmt, same_expr)
			}
			g.writeln('}')
		}
		else {
			println(term.red('jsgen.expr(): bad node'))
		}
	}
}
