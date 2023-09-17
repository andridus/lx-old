module parser

import compiler_v.types
import compiler_v.ast

pub fn (p Parser) node(meta ast.Meta, atom string, nodes []ast.Node) ast.Node {
	kind := match atom {
		'defmodule' { types.NodeKind(types.Module{}) }
		'def' { types.NodeKind(types.Function{}) }
		'__aliases__' { types.NodeKind(types.Alias{}) }
		else { types.NodeKind(types.Nil{}) }
	}
	return ast.Node{
		atom: atom
		kind: kind
		meta: meta
		nodes: nodes
	}
}

pub fn (p Parser) node_function(meta ast.Meta, atom string, nodes []ast.Node, ty types.Function) ast.Node {
	return ast.Node{
		atom: atom
		kind: types.NodeKind(ty)
		meta: meta
		nodes: nodes
	}
}

pub fn (p Parser) node_atom(mut meta ast.Meta, atom string) ast.Node {
	meta.put_ti(types.atom_ti)
	return ast.Node{
		atom: atom
		kind: types.NodeKind(types.Atom{})
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
		atom: atom
		kind: types.NodeKind(types.Atomic{})
		nodes: []
	}
}

pub fn (p Parser) meta() ast.Meta {
	return ast.Meta{
		line: p.tok.line_nr
	}
}
