// Copyright (c) 2023 Helder de Sousa. All rights reserved/
// Use of this source code is governed by a MIT license
// that can be found in the LICENSE file
module ast

import compiler_v.types

pub type NodeLeft = Atom | Node | f64 | int | string

pub struct Node {
pub:
	left  NodeLeft
	kind  NodeKind
	nodes []Node
pub mut:
	meta Meta
}

pub fn (n Node) get_ti() types.TypeIdent {
	return n.meta.ti
}

pub fn (n Node) is_inside_parens() bool {
	return n.meta.inside_parens > 0
}

pub fn precedence(term string) int {
	return match term {
		'[' { 9 }
		'.' { 8 }
		'++', '--' { 7 }
		'*', '/', '%', '<<', '>>', '&' { 6 }
		'+', '-', '|', '^' { 5 }
		'==', '!=', '<', '<=', '>', '>=' { 4 }
		'&&', 'and' { 3 }
		'||', '=' { 2 }
		else { 0 }
	}
}

pub fn (n Node) precedence() int {
	return precedence(n.left.atomic_str())
}

pub struct Meta {
pub mut:
	ti            types.TypeIdent
	line          int
	inside_parens int
	is_last_stmt  bool
}

pub fn (mut m Meta) put_ti(ti types.TypeIdent) {
	m.ti = ti
}

pub fn (mut n Node) put_last_stmt() {
	meta := n.meta
	n.meta = Meta{
		...meta
		is_last_stmt: true
	}
}
