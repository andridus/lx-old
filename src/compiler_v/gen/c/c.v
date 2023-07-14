module c

import strings
import compiler_v.ast
import compiler_v.table
import compiler_v.types
import os

struct CGen {
	program &table.Program
mut:
	definitions strings.Builder
	out_main    strings.Builder
	out_modules map[string]strings.Builder
	last_return bool
	in_var_decl bool
	var_count   int
	var_name    string
	var_ti      types.TypeIdent
	fn_agg      map[string][]ast.FnDecl
	fn_main     string
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
	mut deps := g.program.c_dependencies.clone()
	deps << 'tcclib'
	// deps << "stdarg"
	deps << 'string'
	mut deps_inserted := []string{}
	for dep in deps {
		if deps_inserted.contains(dep) {
			continue
		}
		deps_inserted << dep
		dep0 := stdlib(dep) or {
			println(err.msg())
			exit(0)
		}
		if dep0 != '' {
			bin << '#include ${dep0}\n'.bytes()
		}
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
			g.mount_fns(modl)
			g.mount_main()
		}
		ast.Block {
			g.writeln(modl, '// -------- --------')
			for stmt in node.stmts {
				g.stmt(modl, stmt)
			}
		}
		ast.StructDecl {
			g.writeln(modl, 'typedef struct  {')
			for field in node.fields {
				g.writeln(modl, '\t${parse_field(field)};')
			}
			g.writeln(modl, '} ${node.name};')
		}
		ast.EnumDecl {
			g.writeln(modl, 'typedef enum  {')
			mut i := 0
			for val in node.values {
				if i == 0 {
					g.writeln(modl, '\t${node.name}_${val.to_upper()}=1,')
				} else {
					g.writeln(modl, '\t${node.name}_${val.to_upper()},')
				}
				i++
			}
			g.writeln(modl, '} ${node.name};')
		}
		ast.FnDecl {
			g.fn_agg[node.name] << node
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
		ast.VarDecl {
			g.in_var_decl = true
			g.var_name = node.name
			g.var_ti = node.ti
			g.expr(modl, node.expr)
		}
		else {
			println(node)
		}
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
			g.expr(modl, node.left)
			g.write(modl, node.op.str())
			g.expr(modl, node.right)
		}
		// `user := User{name: 'Bob'}`
		ast.StructInit {
			mut var := 'a'
			if g.in_var_decl {
				var = g.var_name
				if node.ti != g.var_ti {
					panic('error type ident wrong')
				}
			}
			// println(node)
			g.writeln(modl, '\t${node.name} ${var};')
			for i, field in node.fields {
				g.write(modl, '\t${var}.${field} = ')
				g.expr(modl, node.exprs[i])
				g.writeln(modl, '; ')
			}
			if g.last_return {
				g.writeln(modl, '\treturn ${var}; ')
			}
		}
		ast.CallEnum {
			if g.in_var_decl {
				println(g.var_ti)
				g.write(modl, '${g.var_ti} ${g.var_name} = ')
				g.writeln(modl, '${node.name}_${node.value.to_upper()};')
			} else {
				g.writeln(modl, '${node.name}_${node.value.to_upper()}')
			}
		}
		ast.CallExpr {
			module_name := node.module_name.replace('.', '_')
			if node.is_external {
				if !node.is_c_module {
					g.write(modl, '${module_name}_')
				}
			}
			g.write(modl, '${node.name}(')
			name_fun_raw := '${module_name.replace('_', '.')}.${node.name}'
			fns0 := g.program.table.fns[name_fun_raw]
			arity_idx := fns0.idx_arity_by_args[node.arity]
			mut arity_len := 0
			if arity_idx < fns0.arities.len && fns0.arities.len != 0 {
				arity_len = fns0.arities[arity_idx].args.len
			} else {
				arity_len = 0
			}
			// println()
			if node.is_external {
				if !node.is_c_module {
					if arity_len == 0 {
						g.write(modl, "${arity_len},\"${node.arity}\"")
					} else {
						g.write(modl, "${arity_len},\"${node.arity}\",")
					}
				}
			}

			for i, expr in node.args {
				// arity_idx := fns0.idx_arity_by_args[expr.arity]
				// arity := fns0.arities[arity_idx]
				// println(arity)
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
			// println('modl: ${modl}, node: ${node}')
		}
	}
}

fn is_defer_return(kind types.Kind) bool {
	return match kind {
		.struct_ { true }
		else { false }
	}
}

fn (mut g CGen) mount_fns(modl string) {
	for _, fns in g.fn_agg {
		g.write_fns(modl, fns)
	}
}

fn (mut g CGen) write_fns(modl string, arr []ast.FnDecl) {
	module0 := g.program.modules[modl]
	module_name := module0.name.replace('.', '_')
	if arr.len > 0 {
		node := arr[0]
		name_fun_raw := '${module_name.replace('_', '.')}.${node.name}'
		fns0 := g.program.table.fns[name_fun_raw]
		if !fns0.is_valid {
			return
		}
		g.writeln(modl, 'void *${module_name}_${node.name}(int arity, char *types, ...){')
		for a in arr {
			arity_idx := fns0.idx_arity_by_args[a.arity]
			arity := fns0.arities[arity_idx]
			g.write_fn(modl, a, arity_idx, arity, fns0.arities.len)
		}
		g.writeln(modl, '}')
	}
}

fn (mut g CGen) write_fn(modl string, node ast.FnDecl, arity_idx int, arity table.FnArity, total_arities int) {
	module0 := g.program.modules[modl]
	if module0.is_main && node.name == 'main' {
		module_name := module0.name.replace('.', '_')
		g.fn_main = '${module_name}_${node.name}'
	}
	mut total := node.stmts.len
	mut current := 0
	if total_arities > 0 {
		g.writeln(modl, 'if(arity == ${arity.args.len} && strcmp(types, "${node.arity}") == 0){')
	} else {
		g.writeln(modl, 'if(arity == 0) {')
	}
	g.writeln(modl, '\tva_list args;')
	g.writeln(modl, '\tva_start(args, types);')
	for arg0 in node.args {
		var_name := '${arg0.name}'
		// type0 := parse_type_ti(arg0.ti)
		// arg1 := parse_arg(arg0, var_name)
		arg1 := parse_arg_simple_pointer(arg0, var_name)
		type0 := parse_arg_simple_pointer_no_arg(arg0)

		g.writeln(modl, '\t${arg1} = va_arg(args, ${type0});')
	}
	g.writeln(modl, '\tva_end(args);')
	for stmt in node.stmts {
		if current + 1 == total && node.ti.kind == .void {
			g.stmt(modl, stmt)
			g.writeln(modl, '\treturn NULL;')
		} else if current + 1 == total && node.ti.kind != .void {
			g.last_return = true
			if !is_defer_return(node.ti.kind) {
				g.write(modl, '\treturn ')
			}
			g.stmt(modl, stmt)
		} else {
			g.stmt(modl, stmt)
		}
		current++
	}
	g.writeln(modl, '}')
}

fn (mut g CGen) mount_main() {
	if g.fn_main.len > 0 {
		g.out_main.writeln('int main(int argc, char *argv[]) {')
		g.out_main.writeln(" ${g.fn_main}(0, \"0_\");")
		g.out_main.writeln('return 0;')
		g.out_main.writeln('}')
	}
}
