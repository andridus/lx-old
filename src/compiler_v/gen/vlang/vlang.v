module vlang

import strings
import compiler_v.ast
import compiler_v.table
import compiler_v.types
import os

struct VGen {
	program &table.Program
mut:
	definitions          strings.Builder
	out_main             strings.Builder
	out_modules          map[string]strings.Builder
	out_function         strings.Builder
	out_expr             strings.Builder
	out_exprs            map[string]string
	out_expr_type        map[string][]string
	in_var_decl          bool
	in_function_decl     bool
	in_binary_exp        bool
	in_expr_decl         bool
	in_ident_c           bool
	is_last_statement    bool
	last_argument        string
	parent_deep          int
	var_count            int
	var_name             string
	var_ti               types.TypeIdent
	local_vars_binding   map[string]string
	local_vars_binding_t map[string]string
	local_vars           map[string][]string
	local_vars_t         map[string][]string
	fn_agg               map[string][]ast.FnDecl
	fn_main              string
	fn_main_ti           types.TypeIdent
}

pub fn gen(prog table.Program) VGen {
	mut outm := map[string]strings.Builder{}
	for o in prog.compile_order {
		outm[o] = strings.new_builder(100)
	}

	mut g := VGen{
		program: &prog
		out_main: strings.new_builder(100)
		out_function: strings.new_builder(100)
		out_expr: strings.new_builder(100)
		out_modules: outm
	}

	for modl in prog.compile_order {
		for stmt in prog.modules[modl].stmts {
			g.stmt(modl, stmt)
		}
	}
	return g
}

pub fn (mut g VGen) main_function() string {
	return g.out_main.str()
}

pub fn (mut g VGen) save() !string {
	mut bin := []u8{}
	mut order := g.program.compile_order.clone()
	/// include std functions
	bin << '// Include standard functions\n'.bytes()
	mut deps := g.program.c_dependencies.clone()
	// deps << 'tcclib'
	// deps << 'stdlib'
	// deps << 'stdio'
	// deps << 'stdarg'

	// // deps << "stdarg"
	// deps << 'string'
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
	// own libs
	bin << 'type AnyType = int | string | bool | f64 | Atom | Nil\n'.bytes()
	bin << "fn (t AnyType) str() string {
		return match t {
			int {
				r := t as int
				'\$r'
			}
			f64 {
				r := t as f64
				'\$r'
			}
			bool {
				r := t as bool
				'\$r'
			}
			string {
				r := t as string
				'\$r'
			}
			else {
				'undefined'
			}
		}
	}\n".bytes()
	bin << 'fn lx_to_int(value AnyType) int {
		return match value {
			int { value}
			bool {
				r := value as bool
				if r { 1 } else { 0 }
			}
			else {
				eprintln("to_int: invalid conversion")
				exit(0)
			}
		}
	}\n'.bytes()
	bin << 'fn lx_to_string(value AnyType) string {
		return match value {
			Atom { value.val }
			string { value }
			else {
				eprintln("to_string: invalid conversion")
				exit(0)
			}
		}
	}\n'.bytes()
	bin << 'fn lx_to_f64(value AnyType) int {
		return match value {
			int { value}
			f64 { value}
			bool {
				r := value as bool
				if r { 1 } else { 0 }
			}
			else {
				eprintln("\033[31m**(RuntimeError::InvalidConversion)\033[0m to_f64 conversion")
				exit(0)
			}
		}
	}\n'.bytes()
	bin << "
	fn lx_match(left AnyType, right AnyType) AnyType {
		if typeof(left).name == typeof(right).name {
			if left == right {
				return left
			} else {
				 eprintln('\033[31m**(RuntimeError::MatchError)\033[0m The left expression \033[97m`\$left`\033[0m doesn`t match with right expression \033[97m`\$right`\033[0m !')
				 exit(0)
				 }
		} else {
			panic('broken')
		}
	}\n".bytes()
	bin << 'struct Nil {}\n'.bytes()
	bin << 'struct Atom {\n\tval string\n  ref int\n}\n'.bytes()
	bin << "fn (a Atom) str() string { return ':\${a.val}' }\n".bytes()

	order.reverse()
	for modl in order {
		bin << g.out_modules[modl]
	}
	bin << g.out_main
	filepath := '${g.program.build_folder}/main.v'
	os.write_file(filepath, bin.bytestr())!
	return filepath
}

pub fn (mut g VGen) write(modl string, s string) {
	if g.in_expr_decl {
		g.out_expr.writeln(s)
	} else {
		if g.in_function_decl {
			g.out_function.write_string(s)
		} else {
			g.out_modules[modl].write_string(s)
		}
	}
}

pub fn (mut g VGen) writeln(modl string, s string) {
	if g.in_expr_decl {
		g.out_expr.writeln(s)
	} else {
		if g.in_function_decl {
			g.out_function.writeln(s)
		} else {
			g.out_modules[modl].writeln(s)
		}
	}
}

fn (mut g VGen) endln(modl string) {
	g.writeln(modl, '')
}

fn (mut g VGen) get_args_concat(node ast.Expr) []string {
	mut args := []string{}
	match node {
		ast.StringLiteral {
			args << "\"${node.val}\""
		}
		ast.Ident {
			if v := g.local_vars_binding[node.name] {
				args << v
			} else {
				args << node.name
			}
		}
		ast.StringConcatExpr {
			args0 := g.get_args_concat(node.left)
			args.insert(args.len, args0)
			args1 := g.get_args_concat(node.right)
			args.insert(args.len, args1)
		}
		else {}
	}
	return args
}

fn (mut g VGen) stmt(modl string, node ast.Stmt) {
	g.parent_deep = 0
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
			g.writeln(modl, 'struct ${node.name.to_upper()} {')
			for field in node.fields {
				g.writeln(modl, '\t${parse_field(field)}')
			}
			g.writeln(modl, '}')
		}
		ast.EnumDecl {
			g.writeln(modl, 'enum ${node.name.to_upper()} {')
			mut i := 0
			for val in node.values {
				g.writeln(modl, '\t__${val.to_lower()}__')
				i++
			}
			g.writeln(modl, '}')
		}
		ast.FnDecl {
			g.fn_agg[node.name] << node
		}
		ast.ExprStmt {
			g.expr(modl, node.expr)
			g.endln(modl)
		}
		ast.VarDecl {
			g.in_var_decl = true
			g.var_name = node.name
			g.var_ti = node.ti
			g.expr(modl, node.expr)
			g.endln(modl)
		}
		else {
			println(node)
		}
	}
}

fn (mut g VGen) expr(modl string, node ast.Expr) {
	g.parent_deep++
	g.mount_var_decl(modl, node)
	match node {
		ast.IntegerLiteral {
			g.write(modl, node.val.str())
		}
		ast.NilLiteral {
			g.write(modl, 'Nil{}')
		}
		ast.FloatLiteral {
			g.write(modl, node.val.str())
		}
		ast.UnaryExpr {
			g.expr(modl, node.left)
			g.write(modl, ' ${node.op} ')
		}
		ast.Atom {
			g.write(modl, "Atom{val: \"${node.value}\"}")
		}
		ast.StringLiteral {
			g.write(modl, "\"${node.val}\"")
		}
		ast.TupleLiteral {
			g.write(modl, '"tuple"')
		}
		ast.NotExpr {
			g.write(modl, '!')
			g.expr(modl, node.expr)
		}
		ast.CharlistLiteral {
			g.write(modl, '${node.val}')
		}
		ast.StringConcatExpr {
			// 3, "Hello, ", var_1, "!")
			// tmpvar := g.temp_var(modl, types.string_ti)
			args := g.get_args_concat(node)
			g.write(modl, '[')
			for i := 0; i < args.len; i++ {
				g.write(modl, args[i])
				if i + 1 < args.len {
					g.write(modl, ',')
				}
			}
			g.write(modl, "].join('')")
		}
		ast.BinaryExpr {
			g.in_binary_exp = true
			g.expr(modl, node.left)
			g.write(modl, ' ')
			g.write(modl, node.op.str())
			g.write(modl, ' ')
			g.expr(modl, node.right)
			g.in_binary_exp = false
		}
		ast.MatchExpr {
			mut tmp_ := '_'
			type0 := parse_type(node.left_ti.kind)
			if node.is_used || g.is_last_statement {
				tmp_ = g.temp_var(modl, node.left_ti)
				g.write(modl, '${tmp_} := ')
			}
			g.write(modl, 'lx_to_${type0}(lx_match(')
			g.expr(modl, node.left)
			g.write(modl, ', ')
			g.expr(modl, node.right)
			g.writeln(modl, '))')
			if node.is_used || g.is_last_statement {
				g.write(modl, 'return ${tmp_}')
			}
		}
		ast.StructInit {
			if g.in_var_decl {
				if node.ti != g.var_ti {
					panic('error type ident wrong')
				}
			}
			println(node)
			g.writeln(modl, '${node.name.to_upper()}{')
			for i, field in node.fields {
				g.write(modl, '\t${field}: ')
				g.expr(modl, node.exprs[i])
				g.writeln(modl, '')
			}
			g.writeln(modl, '}')
		}
		ast.CallEnum {
			if g.in_var_decl {
				// g.write(modl, '${g.var_ti} ${g.var_name} = ')
				g.writeln(modl, '${node.name.to_upper()}.__${node.value.to_lower()}__')
			} else {
				g.writeln(modl, '${node.name.to_upper()}.__${node.value.to_lower()}__')
			}
		}
		ast.CallField {
			mut path := node.parent_path.clone()
			path << node.name
			g.write(modl, '${path.join('.')}')
		}
		ast.CallExpr {
			module_name := node.module_name.replace('.', '_')
			if node.is_external {
				if !node.is_c_module {
					g.write(modl, '\t${module_name}_'.to_lower())
				}
			}
			if node.is_c_module {
				g.write(modl, '${node.name}('.to_lower())
			} else if node.is_v_module {
				g.write(modl, '${node.name}('.to_lower())
			} else {
				g.write(modl, '${node.name}_${node.arity}('.to_lower())
			}

			for i, expr in node.args {
				g.expr(modl, expr)

				if i != node.args.len - 1 {
					g.write(modl, ', ')
				}
			}
			g.write(modl, ')')
		}
		ast.Ident {
			if v := g.local_vars_binding[node.name] {
				g.write(modl, v)
			} else {
				g.write(modl, node.name)
			}
		}
		ast.BoolLiteral {
			if node.val == true {
				g.write(modl, 'true')
			} else {
				g.write(modl, 'false')
			}
		}
		ast.IfExpr {
			g.endln(modl)
			g.write(modl, 'if (')
			g.expr(modl, node.cond)
			g.writeln(modl, ') {')
			for stmt in node.stmts {
				g.stmt(modl, stmt)
			}
			g.writeln(modl, '}')
			if node.else_stmts.len > 0 {
				g.writeln(modl, ' else {')
				for stmt in node.else_stmts {
					g.stmt(modl, stmt)
				}
				g.writeln(modl, '}')
			}
		}
		ast.EmptyExpr {}
		else {}
	}
	g.parent_deep--
}

fn (mut g VGen) mount_var_decl(modl string, node ast.Expr) {
	if g.in_var_decl {
		var := g.var_name
		g.var_count++
		tmp_var := 'var_${g.var_count}'
		arg1 := parse_type_ti(g.var_ti)
		g.out_expr_type[arg1] << tmp_var
		g.local_vars_binding[var] = tmp_var
		g.local_vars_binding_t[var] = arg1
		g.write(modl, '${tmp_var} := ')
		g.var_name = ''
		g.var_ti = types.void_ti
		g.in_var_decl = false
	} else {
		if g.parent_deep == 1 && !g.is_last_statement && !ast.get_is_used(node)
			&& ast.get_ti(node).kind != .void_ {
			g.write(modl, '_ := ')
		}
	}
}

fn is_defer_return(kind types.Kind) bool {
	return match kind {
		.struct_ { true }
		else { false }
	}
}

fn (mut g VGen) temp_var(modl string, type0 types.TypeIdent) string {
	g.var_count++
	tmp_var := 'tmpvar_${g.var_count}'
	// type1 := parse_type_ti(type0)
	// g.write(modl, '${tmp_var}')
	return tmp_var
}

fn (mut g VGen) mount_fns(modl string) {
	for _, fns in g.fn_agg {
		g.write_fns(modl, fns)
	}
}

fn (mut g VGen) write_fns(modl string, arr []ast.FnDecl) {
	module0 := g.program.modules[modl]
	module_name := module0.name.replace('.', '_')
	if arr.len > 0 {
		node := arr[0]
		name_fun_raw := '${module_name.replace('_', '.')}.${node.name}'
		fns0 := g.program.table.fns[name_fun_raw]
		if !fns0.is_valid {
			return
		}
		for a in arr {
			arity_idx := fns0.idx_arity_by_args[a.arity]
			arity := fns0.arities[arity_idx]
			g.write_fn(modl, a, arity_idx, arity, fns0.arities.len)
		}
	}
}

fn (mut g VGen) write_fn(modl string, node ast.FnDecl, arity_idx int, arity table.FnArity, total_arities int) {
	module0 := g.program.modules[modl]
	module_name := module0.name.replace('.', '_')
	if module0.is_main && node.name == 'main' {
		g.fn_main = '${module_name}_${node.name}'
		g.fn_main_ti = node.ti
	}
	mut total := node.stmts.len
	mut current := 0
	if total_arities > 0 {
		g.write(modl, 'fn ${module_name}_${node.name}_${node.arity}('.to_lower())
		mut i0 := 0
		for arg0 in node.args {
			mut var_name := '${arg0.name}'
			type0 := parse_arg_simple_pointer_no_arg(arg0)
			g.var_count++
			tmp_var := 'var_${g.var_count}'
			g.local_vars_binding[var_name] = tmp_var
			g.local_vars_binding_t[var_name] = type0

			g.write(modl, '${var_name} ')
			if arg0.ti.kind == .enum_ {
				g.write(modl, '${type0.to_upper()}')
			} else {
				g.write(modl, '${type0}')
			}
			if i0 + 1 < node.args.len {
				g.write(modl, ', ')
			}
			i0++
		}
		return_ti := parse_type_ti(node.ti)
		g.writeln(modl, ') ${return_ti} {')
	} else {
		g.writeln(modl, 'void *${module_name}_${node.name}_0(){')
	}
	if node.arity != '0' {
		for arg0 in node.args {
			mut var_name := '${arg0.name}'
			type0 := parse_arg(arg0)
			g.var_count++
			tmp_var := 'var_${g.var_count}'
			g.local_vars_binding[var_name] = tmp_var
			g.local_vars_binding_t[var_name] = type0
			g.writeln(modl, '${tmp_var} := ${var_name}')
		}
	}
	g.in_function_decl = true
	for stmt in node.stmts {
		if current + 1 == total && node.ti.kind == .void_ {
			g.stmt(modl, stmt)
			g.writeln(modl, 'return Nil{}')
		} else if current + 1 == total && node.ti.kind != .void_ {
			g.is_last_statement = true
			if !is_defer_return(node.ti.kind) {
				if ast.is_literal_from_stmt(stmt) {
					tmp_ := g.temp_var(modl, stmt.ti)
					// if stmt.ti.kind !in [.string_, .atom_] {
					// 	g.write(modl, '*')
					// }
					g.write(modl, '${tmp_} := ')

					g.stmt(modl, stmt)
					g.writeln(modl, '\treturn ${tmp_}')
				} else {
					if stmt.ti.kind == .void_ {
						g.stmt(modl, stmt)
						g.writeln(modl, '\treturn Nil{}')
					} else {
						mut dont_return := false
						tmp_ := g.temp_var(modl, stmt.ti)
						match stmt {
							ast.ExprStmt {
								match stmt.expr {
									ast.CallExpr {}
									ast.MatchExpr {
										dont_return = true
									}
									else {}
								}
							}
							else {}
						}
						if dont_return {
							g.stmt(modl, stmt)
						} else {
							g.write(modl, '${tmp_} := ')
							g.stmt(modl, stmt)
							g.writeln(modl, '\treturn ${tmp_}')
						}
					}
				}
				g.is_last_statement = false
			} else {
				g.stmt(modl, stmt)
			}
		} else {
			g.stmt(modl, stmt)
		}
		current++
	}
	{
		g.in_function_decl = false
		g.writeln(modl, g.out_function.str())
		g.local_vars.clear()
		// g.out_exprs.clear()
	}
	g.writeln(modl, '}')
}

fn (mut g VGen) mount_main() {
	if g.fn_main.len > 0 {
		g.out_main.writeln('fn main(){')
		g.out_main.writeln('result := ${g.fn_main.to_lower()}_0()')
		g.out_main.writeln("if typeof(result).name != 'Nil' {")
		g.out_main.writeln('println(result)')
		g.out_main.writeln('}else{')
		g.out_main.writeln('println("nil\\n")')
		g.out_main.writeln('}')
		g.out_main.writeln('}')
	}
}
