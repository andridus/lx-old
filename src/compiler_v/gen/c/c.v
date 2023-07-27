module c

import strings
import compiler_v.ast
import compiler_v.table
import compiler_v.types
import os

struct CGen {
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

pub fn gen(prog table.Program) CGen {
	mut outm := map[string]strings.Builder{}
	for o in prog.compile_order {
		outm[o] = strings.new_builder(100)
	}

	mut g := CGen{
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

pub fn (mut g CGen) main_function() string {
	return g.out_main.str()
}

pub fn (mut g CGen) save() !string {
	mut bin := []u8{}
	mut order := g.program.compile_order.clone()
	/// include std functions
	bin << '// Include standard functions\n'.bytes()
	mut deps := g.program.c_dependencies.clone()
	// deps << 'tcclib'
	deps << 'stdlib'
	deps << 'stdio'
	deps << 'stdarg'

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
	// own libs
	// MODULE 'C'.ex

	bin << '
		typedef enum { NIL, ATOM, FLOAT, INTEGER, STRING, VOID } LxTypes;
		void * lx_print(void ** str, LxTypes tp) {
			if (tp == ATOM) { printf("%s",str);}
			else if (tp == INTEGER) { printf("%d",(*(int *) str));}
			else if (tp == STRING) { printf("%s", str);}
			else if (tp == FLOAT) { printf("%lf", (*(double *) str));}
			else if (tp == VOID) { printf("nil");}
			else { printf("can\'t print object");}
		}\n'.bytes()

	bin << '
	void * lx_match(void ** left, LxTypes type, void ** right) {
	if (type == ATOM && (*(int *)left) == (*(int *)right)) { return left; }
	else if (type == FLOAT  && (*(double *)left) == (*(double *)right)) { return left; }
	else if (type == INTEGER && (*(int *)left) == (*(int *)right)) { return left; }
	else if (type == STRING && strcmp((char *)left, (char *)right)) { return left; }
	else { printf("DONT MATCH"); exit(0); }
	}\n'.bytes()
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

pub fn (mut g CGen) writeln(modl string, s string) {
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

fn (mut g CGen) expr(modl string, node ast.Expr) {
	g.mount_var_decl(modl, node)
	match node {
		ast.IntegerLiteral {
			g.write(modl, node.val.str())
		}
		ast.NilLiteral {
			g.write(modl, 'NULL')
		}
		ast.FloatLiteral {
			g.write(modl, node.val.str())
		}
		ast.UnaryExpr {
			g.expr(modl, node.left)
			g.write(modl, ' ${node.op} ')
		}
		ast.Atom {
			g.write(modl, "\"${node.value}\"")
		}
		ast.StringLiteral {
			g.write(modl, "\"${node.val}\"")
		}
		ast.TupleLiteral {
			g.write(modl, '"tuple"')
		}
		ast.CharlistLiteral {
			g.write(modl, '${node.val}')
		}
		ast.BinaryExpr {
			g.in_binary_exp = true
			g.write(modl, '(')
			g.expr(modl, node.left)
			g.write(modl, ')')
			g.write(modl, node.op.str())
			g.write(modl, '(')
			g.expr(modl, node.right)
			g.write(modl, ')')
			g.in_binary_exp = false
		}
		ast.MatchExpr {
			mut left_is_caller := false
			mut left_var := ''
			mut right_is_caller := false
			mut right_var := ''

			left_var = g.temp_var(modl, node.left_ti)
			if ast.is_literal_from_expr(node.left) {
				g.write(modl, '*')
			}
			g.write(modl, '${left_var} = ')
			g.expr(modl, node.left)
			g.writeln(modl, ';')
			left_is_caller = true
			right_var = g.temp_var(modl, node.right_ti)
			if ast.is_literal_from_expr(node.right) {
				g.write(modl, '*')
			}
			g.write(modl, '${right_var} = ')
			g.expr(modl, node.right)
			g.writeln(modl, ';')
			right_is_caller = true

			tmp_ := g.temp_var(modl, node.left_ti)
			g.write(modl, '${tmp_} = lx_match(')
			if left_is_caller {
				g.write(modl, '(void *) ${left_var}')
			} else {
				g.write(modl, '(void *)')
				g.expr(modl, node.left)
			}
			g.write(modl, ', ')
			g.write(modl, node.left_ti.str().to_upper())
			g.write(modl, ', ')
			if right_is_caller {
				g.write(modl, '(void *) ${right_var}')
			} else {
				g.write(modl, '(void *)')
				g.expr(modl, node.right)
			}
			g.write(modl, ')')
			if g.is_last_statement {
				g.writeln(modl, ';')
				g.write(modl, 'return ${tmp_}')
			}
		}
		ast.StructInit {
			mut var := 'a'
			if g.in_var_decl {
				var = g.var_name
				if node.ti != g.var_ti {
					panic('error type ident wrong')
				}
			}
			for i, field in node.fields {
				g.write(modl, '\t${var}.${field} = ')
				g.expr(modl, node.exprs[i])
				g.writeln(modl, '; ')
			}
			if g.is_last_statement {
				g.writeln(modl, '\treturn ${var}; ')
			}
		}
		ast.CallEnum {
			if g.in_var_decl {
				g.write(modl, '${g.var_ti} ${g.var_name} = ')
				g.writeln(modl, '${node.name}_${node.value.to_upper()};')
			} else {
				g.writeln(modl, '${node.name}_${node.value.to_upper()}')
			}
		}
		ast.CallField {
			mut path := node.parent_path.clone()
			path << node.name
			g.write(modl, '${path.join('.')}')
		}
		ast.CallExpr {
			g.in_expr_decl = true
			defer {
				g.var_count++
				typ := parse_type_ti(node.ti)
				g.in_expr_decl = false
				if !node.is_c_module {
					g.write(modl, '(${typ} *)')
				}
				g.write(modl, '${g.out_expr}'.replace('\n', ''))
			}

			module_name := node.module_name.replace('.', '_')
			if node.is_external {
				if !node.is_c_module {
					g.write(modl, '\t${module_name}_')
				}
			}
			if node.is_c_module {
				g.write(modl, '${node.name}(')
			} else {
				g.write(modl, '${node.name}_${node.arity}(')
			}

			if node.is_c_module {
				g.in_ident_c = true
			}
			for i, expr in node.args {
				g.expr(modl, expr)

				if i != node.args.len - 1 {
					g.write(modl, ', ')
				}
			}
			g.in_ident_c = false
			g.write(modl, ')')
		}
		ast.Ident {
			if v := g.local_vars_binding[node.name] {
				s := g.local_vars_binding_t[node.name]
				if s != 'char *' {
					g.write(modl, '*')
				}
				g.write(modl, v)
			} else {
				if g.in_ident_c {
					g.write(modl, '*')
				}
				g.write(modl, node.name)
			}
		}
		ast.BoolLiteral {
			if node.val == true {
				g.write(modl, '1')
			} else {
				g.write(modl, '0')
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
}

fn (mut g CGen) mount_var_decl(modl string, node ast.Expr) {
	if g.in_var_decl {
		var := g.var_name
		g.var_count++
		tmp_var := 'var_${g.var_count}'
		arg1 := parse_type_ti(g.var_ti)
		g.out_expr_type[arg1] << tmp_var
		g.local_vars_binding[var] = tmp_var
		g.local_vars_binding_t[var] = arg1
		if g.var_ti.kind == .enum_ {
			g.write(modl, '*${tmp_var} = ')
		} else {
			g.write(modl, '${tmp_var} = ')
		}
		g.var_name = ''
		g.var_ti = types.void_ti
		g.in_var_decl = false
	}
}

fn is_defer_return(kind types.Kind) bool {
	return match kind {
		.struct_ { true }
		else { false }
	}
}

fn (mut g CGen) temp_var(modl string, type0 types.TypeIdent) string {
	g.var_count++
	tmp_var := 'tmpvar_${g.var_count}'
	type1 := parse_type_ti(type0)
	g.writeln(modl, '\t${type1} *${tmp_var};')
	if type0.kind != .void_ {
		g.writeln(modl, '\t${tmp_var} = malloc(sizeof(${type1}));')
	}
	return tmp_var
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
		for a in arr {
			arity_idx := fns0.idx_arity_by_args[a.arity]
			arity := fns0.arities[arity_idx]
			g.write_fn(modl, a, arity_idx, arity, fns0.arities.len)
		}
	}
}

fn (mut g CGen) write_fn(modl string, node ast.FnDecl, arity_idx int, arity table.FnArity, total_arities int) {
	module0 := g.program.modules[modl]
	module_name := module0.name.replace('.', '_')
	if module0.is_main && node.name == 'main' {
		g.fn_main = '${module_name}_${node.name}'
		g.fn_main_ti = node.ti
	}
	mut total := node.stmts.len
	mut current := 0
	if total_arities > 0 {
		g.write(modl, 'void *${module_name}_${node.name}_${node.arity}(')
		mut i0 := 0
		for arg0 in node.args {
			mut var_name := '${arg0.name}'
			type0 := parse_arg_simple_pointer_no_arg(arg0)
			g.var_count++
			tmp_var := 'var_${g.var_count}'
			g.local_vars_binding[var_name] = tmp_var
			g.local_vars_binding_t[var_name] = type0
			g.write(modl, '${type0} ${var_name}')
			if i0 + 1 < node.args.len {
				g.write(modl, ', ')
			}
			i0++
		}
		g.writeln(modl, '){')
	} else {
		g.writeln(modl, 'void *${module_name}_${node.name}_0(){')
	}
	if node.arity != '0' {
		for arg0 in node.args {
			mut var_name := '${arg0.name}'
			type0 := parse_arg_simple_pointer_no_arg(arg0)
			g.var_count++
			tmp_var := 'var_${g.var_count}'
			g.local_vars_binding[var_name] = tmp_var
			g.local_vars_binding_t[var_name] = type0

			if type0 == 'char *' {
				g.writeln(modl, '${type0} ${tmp_var};')
				g.writeln(modl, '${tmp_var} = ${var_name};')
			} else {
				g.writeln(modl, '${type0} *${tmp_var};')
				g.writeln(modl, '${tmp_var} = &${var_name};')
			}
		}
	}
	g.in_function_decl = true
	for stmt in node.stmts {
		if current + 1 == total && node.ti.kind == .void_ {
			g.stmt(modl, stmt)
			g.writeln(modl, '\treturn NULL;')
		} else if current + 1 == total && node.ti.kind != .void_ {
			g.is_last_statement = true
			if !is_defer_return(node.ti.kind) {
				if ast.is_literal_from_stmt(stmt) {
					tmp_ := g.temp_var(modl, stmt.ti)
					if stmt.ti.kind !in [.string_, .atom_] {
						g.write(modl, '*')
					}
					g.write(modl, '${tmp_} = ')

					g.stmt(modl, stmt)
					g.writeln(modl, '\treturn ${tmp_};')
				} else {
					if stmt.ti.kind == .void_ {
						g.stmt(modl, stmt)
						g.writeln(modl, ';\treturn NULL;')
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
									else {
										if stmt.ti.kind !in [.string_, .atom_] {
											g.write(modl, '*')
										}
									}
								}
							}
							else {}
						}
						if dont_return {
							g.stmt(modl, stmt)
						} else {
							g.write(modl, '${tmp_} = ')
							g.stmt(modl, stmt)
							g.writeln(modl, '\treturn ${tmp_};')
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
		for typ, vars in g.out_expr_type {
			g.write(modl, '\t${typ} ')

			for i := 0; i < vars.len; i++ {
				g.write(modl, '*${vars[i]}')
				if i + 1 < vars.len {
					g.write(modl, ', ')
				}
			}
			g.writeln(modl, ';')
			for i := 0; i < vars.len; i++ {
				if typ != 'void' {
					if vars[i] != 'void' {
						g.write(modl, '${vars[i]} = malloc(sizeof(${typ}))')
						g.writeln(modl, '; ')
					}
				}
			}
			g.writeln(modl, '')
		}
		g.writeln(modl, g.out_function.str())
		for _, vars in g.out_expr_type {
			for v in vars {
				g.writeln(modl, 'free(${v});')
			}
		}
		g.local_vars.clear()
		// g.out_exprs.clear()
	}
	g.writeln(modl, '}')
}

fn (mut g CGen) mount_main() {
	if g.fn_main.len > 0 {
		g.out_main.writeln('int main(int argc, char *argv[]) {')
		g.out_main.writeln('void *result;')
		g.out_main.writeln('result = ${g.fn_main}_0();')
		g.out_main.writeln('if(result != NULL){')
		g.out_main.writeln('lx_print((void *)result,${g.fn_main_ti.str().to_upper()});')
		g.out_main.writeln('}else{')
		g.out_main.writeln('printf("nil\\n");')
		g.out_main.writeln('}')
		g.out_main.writeln('return 0;')
		g.out_main.writeln('}')
	}
}
