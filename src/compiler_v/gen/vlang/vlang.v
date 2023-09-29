module vlang

import strings
import compiler_v.ast
import compiler_v.table
import compiler_v.types
import os
import time

pub struct VGen {
pub:
	program &table.Program
mut:
	definitions   strings.Builder
	out_main      strings.Builder
	out_modules   map[string]strings.Builder
	out_function  strings.Builder
	out_expr      strings.Builder
	out_exprs     map[string]string
	out_expr_type map[string][]string

	defer_return bool

	in_var_decl          bool
	in_function_decl     bool
	in_function_args     bool
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
	fn_agg               map[string][]ast.Function
	fn_agg_node          map[string][]ast.Node
	fn_main              string
	fn_main_ti           types.TypeIdent

	parent_node ast.Node
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
		for node in prog.modules[modl].asts {
			g.parse_node(modl, node)
		}
	}
	return g
}

pub fn (mut g VGen) main_function() string {
	return g.out_main.str()
}

pub fn (mut g VGen) save() !string {
	// read native functions
	native := os.read_file('src/compiler_v/gen/vlang/native.v.source') or {
		eprintln("the file 'native.v.source' not found in dir 'src/compiler_v/gen/vlang' ")
		exit(1)
	}
	mut bin := []u8{}
	mut order := g.program.compile_order.clone()
	order.reverse()
	bin << native.bytes()
	for modl in order {
		bin << g.out_modules[modl]
		// println(g.out_modules[modl].bytestr())
	}
	bin << g.out_main
	filename := time.now().unix_time_nano()
	filepath := '${g.program.build_folder}/${filename}.v'
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

fn parse_function_name(str string) string {
	return str.replace(':', '').replace('.', '_')
}

fn defer_return(node ast.Node) bool {
	return match node.kind {
		ast.Ast {
			match node.kind.lit {
				'match' { true }
				else { false }
			}
		}
		else {
			false
		}
	}
}

fn (mut g VGen) parse_many_nodes(modl string, nodes []ast.Node) {
	for node in nodes {
		g.parse_node(modl, node)
		g.write(modl, '\n')
	}
}

fn (mut g VGen) parse_node(modl string, node ast.Node) {
	if node.meta.is_last_expr && !defer_return(node) {
		g.write(modl, 'return ')
	}
	if node.meta.is_unused && !node.meta.is_last_expr {
		g.write(modl, '_ = ')
	}
	match node.kind {
		ast.Module {
			module0 := g.program.modules[modl]
			g.writeln(modl, '// MODULE \'${module0.name}\'.ex')
			g.parent_node = node
			g.parse_many_nodes(modl, node.nodes)
			g.mount_fns_node(modl)
			g.mount_main()
		}
		ast.Alias {
			g.writeln(modl, '// -------- ${node.nodes[0]} --------')
		}
		ast.Ast {
			match node.kind.lit {
				'block' {
					g.parse_many_nodes(modl, node.nodes)
				}
				'var' {
					value := node.left.str().replace(':', '')
					if value0 := g.local_vars_binding[value] {
						g.write(modl, value0)
					} else {
						g.write(modl, value)
					}
				}
				'assign' {
					if node.nodes.len == 2 {
						g.parse_node(modl, node.nodes[0])
						g.write(modl, ' := ')
						g.parse_node(modl, node.nodes[1])
					}
				}
				'string_concat' {
					if node.nodes.len == 2 {
						g.parse_node(modl, node.nodes[0])
						g.write(modl, ' + ')
						g.parse_node(modl, node.nodes[1])
					}
				}
				'match' {
					mut tmp_ := '_'
					g.defer_return = true
					left := node.nodes[0]
					right := node.nodes[1]
					type0 := parse_type(left.meta.ti.kind)
					if node.meta.is_last_expr {
						tmp_ = g.temp_var(modl, left.meta.ti)
						g.write(modl, '${tmp_} := ')
					}
					g.write(modl, 'any_to_${type0}(do_match(')
					g.parse_node(modl, left)
					g.write(modl, ', ')
					g.parse_node(modl, right)
					g.write(modl, '))')

					if node.meta.is_last_expr {
						g.writeln(modl, 'return ${tmp_}')
					}
					g.defer_return = false
				}
				'bang' {
					g.write(modl, '!')
					g.parse_node(modl, node.nodes[0])
				}
				'.' {
					g.parse_node(modl, node.nodes[0])
					g.write(modl, '.')
					g.write(modl, node.nodes[1].left.atomic_str())
				}
				else {}
			}
		}
		ast.Struct {
			if node.kind.is_def {
				g.writeln(modl, 'struct ${node.kind.internal.to_upper()}{')
				for key, node0 in node.kind.fields {
					g.write(modl, '\t${key} ')
					g.writeln(modl, '${parse_type(node0.meta.ti.kind)} ')
				}
				g.writeln(modl, '}')
			} else {
				g.writeln(modl, '${node.kind.internal.to_upper()}{')
				for node0 in node.nodes[1].nodes {
					field := node0.nodes[0].left.atomic_str()
					value := node0.nodes[1]
					g.write(modl, '\t${field}: ')
					g.parse_node(modl, value)
					g.writeln(modl, '')
				}
				g.writeln(modl, '}')
			}
		}
		ast.List {
			g.parse_many_nodes(modl, node.nodes)
		}
		ast.Atom, ast.Atomic {
			// g.writeln(modl, '\'${node.atom}\'')
			g.write(modl, "Atom{val: \"${node.left.atomic_str()}\"}")
		}
		ast.String {
			g.write(modl, "\"${node.left.str()}\"")
		}
		ast.Boolean {
			g.write(modl, '${node.left.atomic_str()}')
		}
		ast.Integer {
			g.write(modl, '${node.left.str()}')
		}
		ast.Float {
			g.write(modl, '${node.left.str()}')
		}
		ast.Function {
			node0 := node.nodes[0]
			g.fn_agg_node[node0.left.str()] << node
		}
		ast.FunctionCaller {
			ty := node.kind as ast.FunctionCaller
			if ty.infix {
				if node.nodes.len == 2 {
					if node.is_inside_parens() {
						g.write(modl, '(')
					}
					g.parse_node(modl, node.nodes[0])
					g.write(modl, ' ${parse_function_name(node.left.str())} ')
					g.parse_node(modl, node.nodes[1])
					if node.is_inside_parens() {
						g.write(modl, ')')
					}
				}
			} else {
				mut fn_name := parse_function_name(ty.module_name + '_' + ty.name)
				if ty.module_name.starts_with('FFI.v') {
					fn_name = fn_name.replace('FFI_v_', '')
				} else {
					mut arity := ''
					if ty.arity.len > 0 {
						arity = '_' + ty.arity.len.str() + '_' + ty.arity.join('_')
					} else {
						arity = '_0'
					}
					fn_name = fn_name + arity
				}

				g.write(modl, fn_name.to_lower())
				g.write(modl, '(')
				for i := 0; i < node.nodes.len; i++ {
					g.parse_node(modl, node.nodes[i])
					if i < (node.nodes.len - 1) {
						g.write(modl, ',')
					}
				}
				g.write(modl, ')')
			}
		}
		ast.Tuple {
			if node.nodes[0].left.str() == ':do' {
				match g.parent_node.kind {
					ast.Module {
						g.parse_node(modl, node.nodes[1])
					}
					ast.Function {
						g.writeln(modl, '{')
						g.parse_node(modl, node.nodes[1])
						g.writeln(modl, '}')
					}
					else {
						g.parse_node(modl, node.nodes[1])
					}
				}
			}
		}
		else {
			eprintln('\n\nOTHER NODE ${node.kind} ${node.left} ${node.meta.ti}')
			exit(1)
		}
	}
}

// fn (mut g VGen) expr(modl string, node ast.Expr) {
// 	g.parent_deep++
// 	g.mount_var_decl(modl, node)
// 	match node {
// 		ast.NilLiteral {
// 			g.write(modl, 'Nil{}')
// 		}
// 		ast.UnaryExpr {
// 			g.expr(modl, node.left)
// 			g.write(modl, ' ${node.op} ')
// 		}

// 		ast.CharlistLiteral {
// 			g.write(modl, '${node.val}')
// 		}
// 		ast.CaseClauseExpr {
// 			g.expr(modl, node.expr)
// 		}
// 		ast.UnderscoreExpr {
// 			g.writeln(modl, 'Underscore{}')
// 		}
// 		ast.StructInit {
// 			if g.in_var_decl {
// 				if node.ti != g.var_ti {
// 					panic('error type ident wrong')
// 				}
// 			}
// 			g.writeln(modl, '${node.name.to_upper()}{')
// 			for i, field in node.fields {
// 				g.write(modl, '\t${field}: ')
// 				g.expr(modl, node.exprs[i])
// 				g.writeln(modl, '')
// 			}
// 			g.writeln(modl, '}')
// 		}
// 		ast.CallEnum {
// 			if g.in_var_decl {
// 				// g.write(modl, '${g.var_ti} ${g.var_name} = ')
// 				g.writeln(modl, '${node.name.to_upper()}.__${node.val.to_lower()}__')
// 			} else {
// 				g.writeln(modl, '${node.name.to_upper()}.__${node.val.to_lower()}__')
// 			}
// 		}
// 		ast.CallField {
// 			mut path := node.parent_path.clone()
// 			path << node.name
// 			g.write(modl, '${path.join('.')}')
// 		}
// 		ast.StructField {
// 			vname := g.local_vars_binding[node.var_name]
// 			g.write(modl, '${vname}.${node.name}')
// 		}
// 		ast.CallExpr {
// 			module_name := node.module_name.replace('.', '_')
// 			if node.is_external {
// 				if !node.is_c_module {
// 					g.write(modl, '\t${module_name}_'.to_lower())
// 				}
// 			}
// 			if node.is_c_module {
// 				g.write(modl, '${node.name}('.to_lower())
// 			} else if node.is_v_module {
// 				g.write(modl, '${node.name}('.to_lower())
// 			} else {
// 				g.write(modl, '${node.name}_${node.arity}('.to_lower())
// 			}

// 			for i, expr in node.args {
// 				g.expr(modl, expr)

// 				if i != node.args.len - 1 {
// 					g.write(modl, ', ')
// 				}
// 			}
// 			g.write(modl, ')')
// 		}
// 		ast.IfExpr {
// 			g.endln(modl)
// 			g.write(modl, 'if (')
// 			g.expr(modl, node.cond)
// 			g.writeln(modl, ') {')
// 			for stmt in node.stmts {
// 				g.stmt(modl, stmt)
// 			}
// 			g.writeln(modl, '}')
// 			if node.else_stmts.len > 0 {
// 				g.writeln(modl, ' else {')
// 				for stmt in node.else_stmts {
// 					g.stmt(modl, stmt)
// 				}
// 				g.writeln(modl, '}')
// 			}
// 		}
// 		ast.EmptyExpr {}
// 		else {
// 			println(node)
// 		}
// 	}
// 	g.parent_deep--
// }

fn (mut g VGen) temp_var(modl string, type0 types.TypeIdent) string {
	g.var_count++
	tmp_var := 'tmpvar_${g.var_count}'
	return tmp_var
}

fn (mut g VGen) mount_fns_node(modl string) {
	for _, fns in g.fn_agg_node {
		g.write_fns_node(modl, fns)
	}
}

fn (mut g VGen) write_fns_node(modl string, nodes []ast.Node) {
	module0 := g.program.modules[modl]
	module_name := module0.name.replace('.', '_')
	if nodes.len > 0 {
		node := nodes[0]
		node0 := node.nodes[0]
		name_fun_raw := '${module_name.replace('_', '.')}.${node0.left}'.replace(':',
			'')
		fns0 := g.program.table.fns[name_fun_raw]
		if !fns0.is_valid {
			return
		}
		for n in nodes {
			fdata := n.kind as ast.Function
			rtis := fns0.return_tis
			arity_idx := fns0.idx_arity_by_args[fdata.arity]
			arity := fns0.arities[arity_idx]
			g.write_fn_node(modl, n, arity_idx, fdata, arity, fns0.arities.len, rtis)
		}
	}
}

fn (mut g VGen) write_fn_node(modl string, node ast.Node, arity_idx int, fdata ast.Function, arity table.FnArity, total_arities int, rtis []types.TypeIdent) {
	node0 := node.nodes[0]
	node1 := node.nodes[1]
	fun_name := node0.left.str().replace(':', '')
	module0 := g.program.modules[modl]
	module_name := module0.name.replace('.', '_')

	if module0.is_main && fdata.is_main {
		g.fn_main = '${module_name}_${fun_name}'
		g.fn_main_ti = fdata.return_ti
	}

	if total_arities > 0 {
		g.write(modl, 'fn ${module_name}_${fun_name}_${fdata.arity}('.to_lower())
		mut i0 := 0

		for arg0 in fdata.args {
			mut var_name := '${arg0.left.atomic_str()}'
			type0 := parse_type(arg0.meta.ti.kind)
			g.var_count++
			tmp_var := 'var_${g.var_count}'
			g.local_vars_binding[var_name] = tmp_var
			g.local_vars_binding_t[var_name] = type0

			g.write(modl, '${var_name} ')
			if arg0.meta.ti.kind == .enum_ {
				g.write(modl, '${type0.to_upper()}')
			} else {
				g.write(modl, '${type0}')
			}
			if i0 + 1 < fdata.args.len {
				g.write(modl, ', ')
			}
			i0++
		}
		arity_ti := rtis[arity_idx]
		return_ti := parse_type(arity_ti.kind)
		g.writeln(modl, ') ${return_ti} {')
	}

	if fdata.arity != '0' {
		for arg0 in fdata.args {
			mut var_name := '${arg0.left.atomic_str()}'
			type0 := parse_type(arg0.meta.ti.kind)
			g.var_count++
			tmp_var := 'var_${g.var_count}'
			g.local_vars_binding[var_name] = tmp_var
			g.local_vars_binding_t[var_name] = type0
			g.writeln(modl, '${tmp_var} := ${var_name}')
		}
	}

	g.in_function_decl = true
	g.parse_node(modl, node1)

	g.in_function_decl = false
	g.writeln(modl, g.out_function.str())
	g.local_vars.clear()
	g.writeln(modl, '}')
}

fn (mut g VGen) mount_main() {
	if g.fn_main.len > 0 {
		g.out_main.writeln('fn main(){')
		g.out_main.writeln('result := ${g.fn_main.to_lower()}_0()')
		g.out_main.writeln("if typeof(result).name != 'Nil' {")
		g.out_main.writeln('print(result)')
		g.out_main.writeln('}else{')
		g.out_main.writeln('print("nil\\n")')
		g.out_main.writeln('}')
		g.out_main.writeln('}')
	}
}
