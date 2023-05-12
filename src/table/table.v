// Copyright (c) 2023 Helder de Sousa. All rights reserved/
// Use of this source code is governed by a MIT license
// that can be found in the LICENSE file
module table

import types
import ast

pub struct Table {
pub mut:
	types         []types.Type
	type_idxs     map[string]int
	local_vars    []Var
	fns           map[string]Fn
	unknown_calls []ast.CallExpr
	tmp_cnt       int
}

pub struct Var {
pub:
	name   string
	ti     types.TypeIdent
	is_mut bool
}

pub struct Fn {
pub:
	name      string
	args      []Var
	return_ti types.TypeIdent
}

pub fn new_table() Table {
	mut t := Table{}
	t.types << types.Type{}
	t.type_idxs['dummy_type_at_idx'] = 0
	return t
}

pub fn (t &Table) find_var(name string) ?Var {
	for var in t.local_vars {
		if var.name == name {
			return var
		}
	}
	return none
}

pub fn (mut t Table) clear_vars() {
	if t.local_vars.len > 0 {
		t.local_vars = []
	}
}

pub fn (mut t Table) register_var(v Var) {
	t.local_vars << v
}

pub fn (t Table) find_fn(name string) ?Fn {
	f := t.fns[name]
	if f.name.str != 0 {
		return f
	}
	return none
}

pub fn (mut t Table) register_fn(new_fn Fn) {
	t.fns[new_fn.name] = new_fn
}

pub fn (mut t Table) register_method(ti types.TypeIdent, new_fn Fn) bool {
	println('register method `${new_fn.name}` tiname=${ti.name} ')

	match t.types[ti.idx] {
		types.Struct {
			println('got struct')
		}
		else {
			return false
		}
	}
	mut struc := t.types[ti.idx] as types.Struct

	if struc.methods.len == 0 {
		struc.methods = []types.Field{}
	}
	println('register method `${new_fn.name}` struct=${struc.name} ')
	struc.methods << types.Field{
		name: new_fn.name
	}
	t.types[ti.idx] = struc
	return true
}

pub fn (mut t Table) new_tmp_var() string {
	t.tmp_cnt++
	return 'tmp${t.tmp_cnt}'
}
