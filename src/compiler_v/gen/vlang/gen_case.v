module vlang

import compiler_v.ast

fn (mut g VGen) write_condition(modl string, tmp_ string, condition ast.Node) bool {
	if condition.kind.str() == 'underscore' {
		g.write(modl, 'true')
		return false
	} else if condition.kind.str() == 'var' {
		g.write(modl, 'true')
		return true
	} else {
		g.write(modl, 'is_match(${tmp_},')
		g.parse_node(modl, condition)
		g.write(modl, ')')
		return false
	}
}

fn (mut g VGen) gen_case(modl string, node ast.Node) {
	kind_case := node.kind as ast.Case
	g.context_var = '${kind_case.ref}_'
	eval_node := node.nodes[0]
	clauses_node := node.nodes[1]
	clauses_block := clauses_node.keyword_get('do') or {
		ast.throw_argument_error([err.msg()])
		exit(1)
	}
	g.match_eval_arg = eval_node

	// mount the eval expr
	value0 := eval_node.left.atomic_str()
	tmp_ := g.get_var(value0) or { '' }

	// the closure to DRY (dont repeat yourself) and retur is match any case
	for i, clause in clauses_block {
		mut is_match_case := false
		condition := clause.get_deep_nth_children([0, 0]) or {
			ast.throw_argument_error([err.msg()])
			exit(1)
		}
		value := clause.get_nth_children(1) or {
			ast.throw_argument_error([err.msg()])
			exit(1)
		}
		// if the first clause
		if i == 0 {
			g.write(modl, 'if ')
		} else {
			g.write(modl, 'else if ')
		}
		match condition.kind.str() {
			'when' {
				var0 := condition.get_nth_children(0) or {
					ast.throw_argument_error([err.msg()])
					exit(1)
				}
				// prepare local var
				var_name := var0.left.atomic_str()
				g.set_var_custom('${g.context_var}${var_name}', tmp_)
				//
				g.parse_node(modl, condition)
			}
			'or_match' {
				g.parse_node(modl, condition)
			}
			else {
				is_match_case = g.write_condition(modl, tmp_, condition)
			}
		}
		g.writeln(modl, ' {')
		// clause return expresion
		if is_match_case {
			g.parse_node(modl, condition)
			g.writeln(modl, ' := ${tmp_}')
		}
		g.parse_node(modl, value)
		g.writeln(modl, ' ')
		//
		g.write(modl, '} ')
		g.context_var = ''
	}
	g.writeln(modl, 'else { ')
	g.writeln(modl, 'dont_match_error(${tmp_})')
	g.writeln(modl, 'exit(1)')
	g.write(modl, '}')
	g.write(modl, '\n')
}
