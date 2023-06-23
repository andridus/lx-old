module gen

import strings
import ast
import table
import os

struct CGen {
	program &ast.File
	table   &table.Table
mut:
	definitions strings.Builder
	out         strings.Builder
}

pub fn c_gen(program ast.File, t table.Table) CGen {
	mut g := CGen{
		program: &program
		table: &t
		out: strings.new_builder(100)
	}
	for stmt in program.stmts {
		g.stmt(stmt)
	}
	return g
}

pub fn (mut g CGen) ast() string {
	return g.out.str()
}

pub fn (mut g CGen) save() {
	for stmt in g.program.stmts {
		match stmt {
			ast.Module {
				filename := stmt.name.to_lower().replace('.', '_')
				output_c := '${g.program.output_path}/c'
				os.rmdir_all(output_c) or { println(error) }
				if !os.is_dir(output_c) {
					os.mkdir(output_c) or { println(error) }
				}
				os.write_file('${output_c}/${filename}.c', g.out.str()) or { println(err.msg()) }
			}
			else {}
		}
	}
}

pub fn (mut g CGen) write(s string) {
	g.out.write_string(s)
}

pub fn (mut g CGen) writeln(s string) {
	g.out.writeln(s)
}

fn (mut g CGen) endln() {
	g.writeln(';')
}

fn (mut g CGen) stmt(node ast.Stmt) {
	match node {
		ast.Module {
			mut exports := []string{}
			for _, fns in g.table.fns {
				exports << '${fns.name}/${fns.args.len}'
			}
			g.writeln('// module \'${node.name}\'.ex transpiled to c')
			g.writeln('#include <stdio.h>\n')
			g.stmt(node.stmt)
		}
		ast.Block {
			if node.is_top_stmt {
				g.writeln('Some definitions about before start module scope')
				mut current := 0
				for stmt in node.stmts {
					if current > 0 {
						g.writeln('')
					}
					g.stmt(stmt)
					current++
				}
			} else {
				for stmt in node.stmts {
					g.stmt(stmt)
				}
			}
		}
		ast.FnDecl {
			mut total := node.args.len
			mut current := 0
			g.write('${node.ti} a$$${node.name}(')
			///
			current = 0
			for current < total {
				g.write('${node.args[current].name.capitalize()}')
				current++
				if current < total {
					g.write(', ')
				}
			}
			g.writeln(') {')

			total = node.stmts.len
			current = 0
			for stmt in node.stmts {
				if current > 0 {
					g.write('          ')
				}
				if current + 1 == total {
					g.write('return ')
					g.stmt(stmt)
				} else {
					g.stmt(stmt)
				}
				current++
			}
			g.writeln('}')
		}
		ast.ExprStmt {
			g.expr(node.expr)
			match node.expr {
				// no ; after an if expression
				ast.IfExpr {}
				else {
					g.endln()
				}
			}
		}
		else {}
	}
}

fn (mut g CGen) expr(node ast.Expr) {
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
			g.write("\"${node.val}\"")
		}
		ast.BinaryExpr {
			g.write('{op, ${node.meta.line}, \'${node.op.str()}\', ')
			g.expr(node.left)
			g.write(', ')
			g.expr(node.right)
			g.write('}')
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
			if node.is_external {
				g.write('${node.module_path}$$')
			}
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
			g.expr(node.cond)
			g.writeln(') {')
			for stmt in node.stmts {
				g.stmt(stmt)
			}
			g.writeln('}')
		}
		ast.EmptyExpr {}
		else {
			println(node)
		}
	}
}
