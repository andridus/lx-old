module vlang

import compiler_v.ast
import compiler_v.table
import compiler_v.types

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
	fun_name := node0.left.str().replace(':', '').replace('?', '_question')
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
			tmp_var := g.set_var(var_name)
			if var_name.starts_with('_') {
				g.write(modl, '_ ')
			} else {
				g.write(modl, '${tmp_var} ')
			}
			if arg0.meta.ti.kind == .enum_ {
				g.write(modl, '${arg0.meta.ti.str().to_upper()}')
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

	g.in_function_decl = true
	g.parse_node(modl, node1)
	g.in_function_decl = false
	g.writeln(modl, g.out_function.str())
	g.writeln(modl, '}')
	g.clear_vars()
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
