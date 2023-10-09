module vlang

import compiler_v.ast

fn (mut g VGen) parse_node(modl string, node ast.Node) {
	// check if is need return statement
	if node.meta.is_last_expr && !defer_return(node) {
		if node.meta.ti.kind == .void_ {
			defer {
				g.writeln(modl, '\nreturn Nil{}')
			}
		} else {
			g.write(modl, 'return ')
		}
	}
	// check if is need assign var for statment
	if node.meta.is_unused && !node.meta.is_last_expr {
		g.write(modl, '_ := ')
	}
	match node.kind.str() {
		'module' {
			module0 := g.program.modules[modl]
			g.writeln(modl, '// MODULE \'${module0.name}\'.ex')
			g.parent_node = node
			g.parse_many_nodes(modl, node.nodes)
			g.mount_fns_node(modl)
			g.mount_main()
		}
		'alias' {
			g.writeln(modl, '// -------- ${node.nodes[0]} --------')
		}
		'block' {
			g.parse_many_nodes(modl, node.nodes)
		}
		'var' {
			mut value := node.left.str().replace(':', '')
			value = '${g.context_var}${value}'
			println(value)

			if value0 := g.get_var(value) {
				g.write(modl, value0)
			} else {
				// var0 := node.left.atomic_str()
				t0 := g.set_var(value)
				// tmp_var := g.get_var(var0) or {var0}
				g.write(modl, t0)
			}
			println(g.local_vars_binding_arr0)
			println(g.local_vars_binding_arr1)
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
				tmp_ = g.temp_var(modl)
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
		'enum' {
			kind := node.kind as ast.Enum
			if kind.is_def {
				g.writeln(modl, 'enum ${kind.internal.to_upper()}{')
				for value in kind.values {
					g.writeln(modl, '\t_${value}_ ')
				}
				g.writeln(modl, '}')
			} else {
				g.write(modl, '${kind.internal.to_upper()}.')
				g.writeln(modl, '_${node.nodes[1].left.atomic_str()}_')
			}
		}
		'struct' {
			kind := node.kind as ast.Struct
			if kind.is_def {
				g.writeln(modl, 'struct ${kind.internal.to_upper()}{')
				for key, node0 in kind.fields {
					g.write(modl, '\t${key} ')
					g.writeln(modl, '${parse_type(node0.meta.ti.kind)} ')
				}
				g.writeln(modl, '}')
			} else {
				g.writeln(modl, '${kind.internal.to_upper()}{')
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
		'underscore' {
			g.write(modl, '_')
		}
		'nil' {
			g.write(modl, 'Nil{}')
		}
		'list' {
			g.parse_many_nodes(modl, node.nodes)
		}
		'atom', 'atomic' {
			// g.writeln(modl, '\'${node.atom}\'')
			g.write(modl, "Atom{val: \"${node.left.atomic_str()}\"}")
		}
		'string' {
			g.write(modl, "\"${node.left.str()}\"")
		}
		'boolean' {
			g.write(modl, '${node.left.atomic_str()}')
		}
		'integer' {
			g.write(modl, '${node.left.str()}')
		}
		'float' {
			g.write(modl, '${node.left.str()}')
		}
		'function' {
			node0 := node.nodes[0]
			g.fn_agg_node[node0.left.str()] << node
		}
		'function_caller' {
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
		'tuple' {
			if node.nodes[0].left.str() == ':do' {
				match g.parent_node.kind.str() {
					'module' {
						g.parse_node(modl, node.nodes[1])
					}
					'function' {
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
		/// case match
		'case' {
			g.gen_case(modl, node)
		}
		'when' {
			_ := g.match_eval_arg or { return }
			fn_or_literal := node.get_nth_children(1) or {
				ast.throw_argument_error([err.msg()])
				exit(1)
			}
			match fn_or_literal.kind.str() {
				'function_caller' {
					g.parse_node(modl, fn_or_literal)
				}
				else {
					eval_node := g.match_eval_arg or { return }
					value0 := eval_node.left.atomic_str()
					tmp_ := g.get_var(value0) or { '' }
					var0 := node.get_nth_children(0) or {
						ast.throw_argument_error([err.msg()])
						exit(1)
					}
					// prepare local var
					var_name := var0.left.atomic_str()
					g.set_var_custom('${g.context_var}${var_name}', tmp_)
					n0 := node.get_nth_children(1) or {
						ast.throw_argument_error([err.msg()])
						exit(1)
					}
					g.parse_node(modl, n0)
				}
			}
		}
		'or_match' {
			eval_node := g.match_eval_arg or { return }

			var0 := node.get_deep_nth_children([0, 0]) or { ast.Node{} }
			mut value := node.left.atomic_str()
			value = '${g.context_var}${value}'

			tmp_ := g.get_var(value) or { g.get_var_force(eval_node.left.atomic_str()) }
			if var0.kind.str() == 'var' {
				var_name := var0.left.atomic_str()
				g.set_var_custom(var_name, tmp_)
			}
			// prepare local var
			//
			for i0, c0 in node.nodes {
				if c0.nodes.len == 0 {
					_ := g.write_condition(modl, tmp_, c0)
				} else {
					g.parse_node(modl, c0)
				}
				if i0 + 1 < node.nodes.len {
					g.write(modl, ' || ')
				}
			}
		}
		else {
			eprintln('\n\nOTHER NODE ${node.kind} ${node.left} ${node.meta.ti}')
			exit(1)
		}
	}
}
