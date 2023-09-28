// Copyright (c) 2023 Helder de Sousa. All rights reserved/
// Use of this source code is governed by a MIT license
// that can be found in the LICENSE file

module table

import compiler_v.types
import compiler_v.ast

pub struct Table {
pub mut:
	types          []types.Type
	type_idxs      map[string]int
	local_vars     map[string]map[string]Var
	global_aliases map[string]string
	atoms          []Atom
	fns            map[string]Fn
	unknown_calls  []ast.Node
	tmp_cnt        int
}

pub struct Atom {
pub:
	name string
	id   int
}

pub struct Var {
pub:
	name     string
	ti       types.TypeIdent
	is_mut   bool
	is_arg   bool
	type_    types.Type
	context  []string = ['root']
	expr     ast.Node
	is_valid bool
}

pub struct Alias {
pub:
	as_key      string
	args        []Var
	module_name string
}

pub struct Require {
pub:
	args        []Var
	module_path string
	module_name string
}

pub struct Fn {
pub:
	name        string
	is_external bool
	is_valid    bool
	module_path string
	module_name string
	def_pos_in  int
	def_pos_out int
pub mut:
	return_tis        []types.TypeIdent
	arities           []FnArity
	idx_arity_by_args map[string]int
}

pub struct FnArity {
pub:
	args      []Var
	return_ti types.TypeIdent
	is_valid  bool
}

pub fn new_table() &Table {
	mut t := &Table{}
	t.types << types.Void{}
	t.type_idxs['dummy_type_at_idx'] = 0
	return t
}

pub fn (v Var) str() string {
	return v.expr.str()
}
