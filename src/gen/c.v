module gen

import strings
import ast
// import term
import table
import os
// import types

struct CGen {
	program &ast.File
	table   &table.Table
mut:
	definitions strings.Builder
	out strings.Builder
}

pub fn c_gen(program ast.File, t table.Table) CGen {
	println('Start CGen')
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
				output_c := "$g.program.output_path/c"
				os.rmdir_all(output_c) or { println(error) }
				if !os.is_dir(output_c) {
					os.mkdir(output_c) or { println(error) }
				}
				os.write_file('${output_c}/${filename}.c', g.out.str()) or {
					println(err.msg())
				}
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
fn (mut g CGen) stmt(node ast.Stmt) {
	match node {
		ast.Module {
			mut exports := []string{}
			for _, fns in g.table.fns {
				exports << '${fns.name}/${fns.args.len}'
			}
			g.writeln('// module \'${node.name}\'.ex transpiled to c lang.')
			g.stmt(node.stmt)
		}
		else {}
	}
}