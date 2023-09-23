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
				'defmodule' {
					ast.NodeKind(ast.Module{})
				}
				'def' {
					ast.NodeKind(ast.Ast{
						lit: 'def'
					})
				}
				'__aliases__' {
					ast.NodeKind(ast.Alias{})
				}
				'.' {
					ast.NodeKind(ast.Ast{
						lit: '.'
					})
				}
				'__block__' {
					ast.NodeKind(ast.Ast{
						lit: 'block'
					})
				}
				else {
					ast.NodeKind(ast.Nil{})
				}
			}
		}
		int {
			ast.NodeKind(ast.Integer{})
		}
		f64 {
			ast.NodeKind(ast.Float{})
		}
		ast.Atom {
			ast.NodeKind(left)
		}
		ast.Node {
			left.kind
		}
	}
	mut left0 := left
	if left is string {
		s := left as string
		left0 = ast.NodeLeft(ast.Atom{
			name: s
		})
	}
	return ast.Node{
		left: left0
		kind: kind
		meta: meta
		nodes: nodes
	}
}

pub fn (p Parser) node_function(meta ast.Meta, nodes []ast.Node, ty ast.Function) ast.Node {
	return ast.Node{
		left: ast.NodeLeft(ast.Atom{
			name: 'def'
		})
		kind: ast.NodeKind(ty)
		meta: meta
		nodes: nodes
	}
}

pub fn (p Parser) node_function_caller(meta ast.Meta, left ast.NodeLeft, nodes []ast.Node, ty ast.FunctionCaller) ast.Node {
	mut left0 := left
	if left is string {
		atom := left as string
		left0 = ast.NodeLeft(ast.Atom{
			name: atom
		})
	}
	return ast.Node{
		left: left0
		kind: ast.NodeKind(ty)
		meta: meta
		nodes: nodes
	}
}

pub fn (p Parser) node_var(meta ast.Meta, left string, nodes []ast.Node) ast.Node {
	return ast.Node{
		left: ast.NodeLeft(left)
		kind: ast.NodeKind(ast.Ast{
			lit: 'var'
		})
		meta: meta
		nodes: nodes
	}
}

pub fn (p Parser) node_assign(meta ast.Meta, ident string, node ast.Node) ast.Node {
	return ast.Node{
		left: ast.NodeLeft(ast.Atom{
			name: '='
		})
		kind: ast.NodeKind(ast.Ast{
			lit: 'assign'
		})
		meta: meta
		nodes: [p.node_var(meta, ident, []), node]
	}
}

pub fn (p Parser) node_match(meta ast.Meta, left ast.Node, right ast.Node) ast.Node {
	return ast.Node{
		left: ast.NodeLeft(ast.Atom{
			name: '='
		})
		kind: ast.NodeKind(ast.Ast{
			lit: 'match'
		})
		meta: meta
		nodes: [left, right]
	}
}

pub fn (p Parser) node_bang(meta ast.Meta, node ast.Node) ast.Node {
	return ast.Node{
		left: ast.NodeLeft(ast.Atom{
			name: '!'
		})
		kind: ast.NodeKind(ast.Ast{
			lit: 'bang'
		})
		meta: meta
		nodes: [node]
	}
}

pub fn (p Parser) node_atom(mut meta ast.Meta, atom string) ast.Node {
	meta.put_ti(types.atom_ti)
	return ast.Node{
		left: ast.NodeLeft(ast.Atom{
			name: atom
		})
		kind: ast.NodeKind(ast.Atom{})
		meta: meta
	}
}

pub fn (p Parser) node_string(mut meta ast.Meta, str string) ast.Node {
	meta.put_ti(types.string_ti)
	return ast.Node{
		left: ast.NodeLeft(str)
		kind: ast.NodeKind(ast.String{})
		meta: meta
	}
}

pub fn (p Parser) node_string_concat(mut meta ast.Meta, left ast.Node, right ast.Node) ast.Node {
	meta.put_ti(types.string_ti)
	return ast.Node{
		left: ast.NodeLeft(ast.Atom{
			name: '<>'
		})
		kind: ast.NodeKind(ast.Ast{
			lit: 'string_concat'
		})
		meta: meta
		nodes: [left, right]
	}
}

pub fn (p Parser) node_integer(mut meta ast.Meta, val int) ast.Node {
	meta.put_ti(types.integer_ti)
	return ast.Node{
		left: ast.NodeLeft(val)
		kind: ast.NodeKind(ast.Integer{})
		meta: meta
	}
}

pub fn (p Parser) node_float(mut meta ast.Meta, val f64) ast.Node {
	meta.put_ti(types.float_ti)
	return ast.Node{
		left: ast.NodeLeft(val)
		kind: ast.NodeKind(ast.Float{})
		meta: meta
	}
}

pub fn (p Parser) node_tuple(meta ast.Meta, nodes []ast.Node) ast.Node {
	return ast.Node{
		kind: ast.NodeKind(ast.Tuple{})
		meta: meta
		nodes: nodes
	}
}

pub fn (p Parser) node_list(meta ast.Meta, nodes []ast.Node) ast.Node {
	return ast.Node{
		kind: ast.NodeKind(ast.List{})
		meta: meta
		nodes: nodes
	}
}

pub fn (p Parser) node_atomic(atom string) ast.Node {
	return ast.Node{
		left: ast.NodeLeft(ast.Atom{
			name: atom
		})
		kind: ast.NodeKind(ast.Atomic{})
		nodes: []
	}
}

pub fn (p Parser) node_boolean(meta ast.Meta, atom string) ast.Node {
	return ast.Node{
		left: ast.NodeLeft(ast.Atom{
			name: atom
		})
		kind: ast.NodeKind(ast.Boolean{})
		meta: meta
		nodes: []
	}
}

pub fn (p Parser) node_default() ast.Node {
	return ast.Node{
		left: ast.NodeLeft('default')
		kind: ast.NodeKind(ast.Atomic{})
		nodes: []
	}
}

pub fn (p Parser) meta() ast.Meta {
	return ast.Meta{
		line: p.tok.line_nr
		inside_parens: p.inside_parens
	}
}
