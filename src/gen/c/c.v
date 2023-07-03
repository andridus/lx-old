module c

import strings
import ast
import table
import os

struct CGen {
	program &table.Program
mut:
	definitions strings.Builder
	out_main    strings.Builder
	out_modules map[string]strings.Builder
}

pub fn gen(prog table.Program) CGen {
	mut outm := map[string]strings.Builder{}
	for o in prog.compile_order {
		outm[o] = strings.new_builder(100)
	}

	mut g := CGen{
		program: &prog
		out_main: strings.new_builder(100)
		out_modules: outm
	}

	for modl in prog.compile_order {
		// println(prog.modules[modl].stmts)
		for stmt in prog.modules[modl].stmts {
			g.stmt(modl, stmt)
		}
	}
	return g
}

pub fn (mut g CGen) main_function() string {
	return g.out_main.str()
}

pub fn (mut g CGen) save() !string {
	mut bin := []u8{}
	mut order := g.program.compile_order.clone()
	/// include std functions
	bin << '// Include standard functions\n'.bytes()
	for dep in g.program.c_dependencies {
		dep0 := stdlib(dep) or {
			println(err.msg())
			exit(0)
		}
		bin << '#include ${dep0}\n'.bytes()
	}
	//
	order.reverse()
	for modl in order {
		bin << g.out_modules[modl]
	}
	bin << g.out_main
	filepath := '${g.program.build_folder}/main.c'
	os.write_file(filepath, bin.bytestr())!
	return filepath
}

pub fn (mut g CGen) write(modl string, s string) {
	g.out_modules[modl].write_string(s)
}

pub fn (mut g CGen) writeln(modl string, s string) {
	g.out_modules[modl].writeln(s)
}

fn (mut g CGen) endln(modl string) {
	g.writeln(modl, ';')
}

fn (mut g CGen) stmt(modl string, node ast.Stmt) {
	match node {
		ast.Module {
			module0 := g.program.modules[modl]
			g.writeln(modl, '// MODULE \'${module0.name}\'.ex')
			g.stmt(modl, node.stmt)
		}
		ast.Block {
			g.writeln(modl, '// -------- --------')
			for stmt in node.stmts {
				g.stmt(modl, stmt)
			}
		}
		ast.FnDecl {
			module0 := g.program.modules[modl]
			mut total := node.args.len
			mut current := 0

			if module0.is_main && node.name == 'main' {
				g.gen_main_function(module0, node)
			}
			g.write(modl, '${parse_type(node.ti.kind)} ${module0.name}_${node.name}(')
			for current < total {
				curr := node.args[current]
				str := parse_arg(curr)
				g.write(modl, str)
				current++
				if current < total {
					g.write(modl, ', ')
				}
			}
			g.writeln(modl, ') {')

			total = node.stmts.len
			current = 0
			for stmt in node.stmts {
				if current + 1 == total && node.ti.kind != .void {
					g.write(modl, 'return ')
					g.stmt(modl, stmt)
				} else {
					g.stmt(modl, stmt)
				}
				current++
			}
			g.writeln(modl, '}')
		}
		ast.ExprStmt {
			g.expr(modl, node.expr)
			match node.expr {
				// no ; after an if expression
				ast.IfExpr {}
				else {
					g.endln(modl)
				}
			}
		}
		else {}
	}
}

fn (mut g CGen) expr(modl string, node ast.Expr) {
	// println('cgen expr()')
	match node {
		ast.IntegerLiteral {
			g.write(modl, node.val.str())
		}
		ast.FloatLiteral {
			g.write(modl, node.val.str())
		}
		ast.UnaryExpr {
			g.expr(modl, node.left)
			g.write(modl, ' ${node.op} ')
		}
		ast.StringLiteral {
			g.write(modl, "\"${node.val}\"")
		}
		ast.CharlistLiteral {
			g.write(modl, '${node.val}')
		}
		ast.BinaryExpr {
			g.write(modl, '{op, ${node.meta.line}, \'${node.op.str()}\', ')
			g.expr(modl, node.left)
			g.write(modl, ', ')
			g.expr(modl, node.right)
			g.write(modl, '}')
		}
		// `user := User{name: 'Bob'}`
		ast.StructInit {
			g.writeln(modl, '/*${node.ti.name}*/{')
			for i, field in node.fields {
				g.write(modl, '\t${field} : ')
				g.expr(modl, node.exprs[i])
				g.writeln(modl, ', ')
			}
			g.write(modl, '}')
		}
		ast.CallExpr {
			if node.is_external {
				if !node.is_c_module {
					g.write(modl, '${node.module_name}_')
				}
			}
			g.write(modl, '${node.name}(')
			for i, expr in node.args {
				g.expr(modl, expr)
				if i != node.args.len - 1 {
					g.write(modl, ', ')
				}
			}
			g.write(modl, ')')
		}
		ast.Ident {
			g.write(modl, node.name)
		}
		ast.BoolLiteral {
			if node.val == true {
				g.write(modl, '{atom, ${node.meta.line}, true}')
			} else {
				g.write(modl, '{atom, ${node.meta.line}, false}')
			}
		}
		ast.IfExpr {
			g.write(modl, 'if (')
			g.expr(modl, node.cond)
			g.writeln(modl, ') {')
			for stmt in node.stmts {
				g.stmt(modl, stmt)
			}
			g.writeln(modl, '}')
		}
		ast.EmptyExpr {}
		else {
			println('modl: ${modl}, node: ${node}')
		}
	}
}

fn (mut g CGen) gen_main_function(mod table.Module, fun ast.FnDecl) {
	g.out_main.writeln('int main(int argc, char *argv[]) {')
	g.out_main.writeln(' ${mod.name}_${fun.name}();')
	g.out_main.writeln('return 0;')
	g.out_main.writeln('}')
}
