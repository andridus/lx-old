module parser

import compiler_v.types
import compiler_v.ast

pub fn (p Parser) node_string_left(node string) ast.NodeLeft {
	return ast.NodeLeft(node)
}

pub fn (p Parser) node_left(node ast.Node) ast.NodeLeft {
	return ast.NodeLeft(node)
}

pub fn (p Parser) node(meta ast.Meta, left ast.NodeLeft, nodes []ast.Node) ast.Node {
	kind := match left {
		string {
			match left {
				'defmodule' { types.NodeKind(types.Module{}) }
				'def' { types.NodeKind(types.Function{}) }
				'__aliases__' { types.NodeKind(types.Alias{}) }
				'.' { types.NodeKind(types.Ast{
						lit: '.'
					}) }
				else { types.NodeKind(types.Nil{}) }
			}
		}
		ast.Node {
			left.kind
		}
	}
	return ast.Node{
		left: left
		kind: kind
		meta: meta
		nodes: nodes
	}
}

pub fn (p Parser) node_function(meta ast.Meta, left ast.NodeLeft, nodes []ast.Node, ty types.Function) ast.Node {
	return ast.Node{
		left: left
		kind: types.NodeKind(ty)
		meta: meta
		nodes: nodes
	}
}

pub fn (p Parser) node_function_caller(meta ast.Meta, left ast.NodeLeft, nodes []ast.Node, ty types.FunctionCaller) ast.Node {
	return ast.Node{
		left: left
		kind: types.NodeKind(ty)
		meta: meta
		nodes: nodes
	}
}

pub fn (p Parser) node_atom(mut meta ast.Meta, atom string) ast.Node {
	meta.put_ti(types.atom_ti)
	return ast.Node{
		left: ast.NodeLeft(atom)
		kind: types.NodeKind(types.Atom{})
		meta: meta
	}
}

pub fn (p Parser) node_string(mut meta ast.Meta, str string) ast.Node {
	meta.put_ti(types.string_ti)
	return ast.Node{
		left: ast.NodeLeft(str)
		kind: types.NodeKind(types.String{})
		meta: meta
	}
}

pub fn (p Parser) node_integer(mut meta ast.Meta, val int) ast.Node {
	meta.put_ti(types.integer_ti)
	return ast.Node{
		left: ast.NodeLeft(val.str())
		kind: types.NodeKind(types.Integer{})
		meta: meta
	}
}

pub fn (p Parser) node_float(mut meta ast.Meta, val f64) ast.Node {
	meta.put_ti(types.float_ti)
	return ast.Node{
		left: ast.NodeLeft(val.str())
		kind: types.NodeKind(types.Float{})
		meta: meta
	}
}

pub fn (p Parser) node_tuple(meta ast.Meta, nodes []ast.Node) ast.Node {
	return ast.Node{
		kind: types.NodeKind(types.Tuple{})
		meta: meta
		nodes: nodes
	}
}

pub fn (p Parser) node_list(meta ast.Meta, nodes []ast.Node) ast.Node {
	return ast.Node{
		kind: types.NodeKind(types.List{})
		meta: meta
		nodes: nodes
	}
}

pub fn (p Parser) node_atomic(atom string) ast.Node {
	return ast.Node{
		left: ast.NodeLeft(atom)
		kind: types.NodeKind(types.Atomic{})
		nodes: []
	}
}

pub fn (p Parser) node_default() ast.Node {
	return ast.Node{
		left: ast.NodeLeft('default')
		kind: types.NodeKind(types.Atomic{})
		nodes: []
	}
}

pub fn (p Parser) meta() ast.Meta {
	return ast.Meta{
		line: p.tok.line_nr
		inside_parens: p.inside_parens
	}
}
