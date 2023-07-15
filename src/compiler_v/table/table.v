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
	local_vars     map[string]Var
	global_aliases map[string]string
	atoms          []Atom
	fns            map[string]Fn
	unknown_calls  []ast.CallExpr
	tmp_cnt        int
}

pub struct Atom {
pub:
	name string
	id   int
}

pub struct Var {
pub:
	name   string
	ti     types.TypeIdent
	is_mut bool
	type_  types.Type
	expr   ast.ExprStmt
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

pub fn (t &Table) find_or_new_atom(atom string) Atom {
	for at in t.atoms {
		if at.name == atom {
			return at
		}
	}

	at := Atom{
		name: atom
		id: t.atoms.len
	}
	return at
}

pub fn (t &Table) find_var(name string) ?Var {
	for key, var in t.local_vars {
		if key == name {
			return var
		}
	}
	return none
}

pub fn (mut t Table) clear_vars() {
	if t.local_vars.len > 0 {
		t.local_vars = map[string]Var{}
	}
}

pub fn (mut t Table) register_var(v Var) {
	t.local_vars[v.name] = v
}

pub fn (mut t Table) register_alias(ident string, modl string) {
	t.global_aliases[ident] = modl
}

pub fn (mut t Table) find_alias(ident string) string {
	id := t.global_aliases[ident]
	return if id.len > 0 { id } else { ident }
}

pub fn (mut t Table) update_var_ti(v Var, ti types.TypeIdent) {
	t.local_vars[v.name] = Var{
		...v
		ti: ti
	}
}

pub fn (t &Table) find_fn(name string, module_name string) ?Fn {
	f := t.fns[module_name + '.' + name]
	if f.is_valid {
		return f
	}
	return none
}

pub fn (mut t Table) register_fn(new_fn Fn) {
	t.fns[new_fn.module_name + '.' + new_fn.name] = new_fn
}

pub fn (mut t Table) register_or_update_fn(arity string, args []Var, ti types.TypeIdent, new_fn Fn) {
	idx_name := new_fn.module_name + '.' + new_fn.name
	mut fn0 := t.fns[idx_name]
	empty_arity0 := FnArity{}
	arity0 := FnArity{
		args: args
		return_ti: ti
		is_valid: true
	}

	if fn0.name == new_fn.name {
		mut tis := []types.TypeIdent{}
		l := fn0.arities.len
		fn0.arities << arity0
		fn0.idx_arity_by_args[arity] = l
		for a in fn0.arities {
			tis << a.return_ti
		}
		fn0.return_tis = tis
		t.fns[idx_name] = fn0
	} else {
		mut arity_names := map[string]int{}
		arity_names[arity] = 1
		t.fns[idx_name] = Fn{
			...new_fn
			return_tis: [empty_arity0.return_ti, arity0.return_ti]
			arities: [empty_arity0, arity0]
			idx_arity_by_args: arity_names
		}
	}
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

pub fn (t &Table) find_type_name(elem_ti &types.TypeIdent) (int, string) {
	mut existing_idx := 0
	mut name := elem_ti.str()
	match elem_ti.kind {
		.struct_ {
			name = 'struct_${elem_ti.name}'
			existing_idx = t.type_idxs[name]
		}
		else {}
	}
	if existing_idx > 0 {
		return existing_idx, name
	} else {
		return existing_idx, name
	}
}

pub fn (mut t Table) register_struct(elem_ti &types.TypeIdent, fields []ast.Field) (int, string) {
	name := 'struct_${elem_ti.name}'
	// existing
	existing_idx := t.type_idxs[name]
	if existing_idx > 0 {
		return existing_idx, name
	}
	// register
	idx := t.types.len
	mut struct_type := types.Type(types.Void{})
	mut fields0 := []types.Field{}
	for field in fields {
		fields0 << types.Field{
			name: field.name
			type_idx: idx
			ti: field.ti
		}
	}
	struct_type = types.Struct{
		idx: idx
		name: name
		fields: fields0
	}
	t.type_idxs[name] = idx
	t.types << struct_type
	return idx, name
}

pub fn (mut t Table) register_enum(elem_ti &types.TypeIdent, values []string) (int, string) {
	name := 'enum_${elem_ti.name}'
	// existing
	existing_idx := t.type_idxs[name]
	if existing_idx > 0 {
		return existing_idx, name
	}
	// register
	idx := t.types.len
	mut enum_type := types.Type(types.Void{})
	enum_type = types.Enum{
		idx: idx
		name: name
		values: values
	}
	t.type_idxs[name] = idx
	t.types << enum_type
	return idx, name
}

pub fn (mut t Table) find_or_register_list_fixed(elem_ti &types.TypeIdent, size int, nr_dims int) (int, string) {
	name := 'list_fixed_${elem_ti.name}_${size}' + if nr_dims > 1 { '_${nr_dims}d' } else { '' }
	// existing
	existing_idx := t.type_idxs[name]
	if existing_idx > 0 {
		return existing_idx, name
	}
	// register
	idx := t.types.len
	mut list_fixed_type := types.Type(types.Void{})
	list_fixed_type = types.ListFixed{
		idx: idx
		name: name
		elem_type_idx: elem_ti.idx
		elem_is_ptr: elem_ti.is_ptr()
		size: size
		nr_dims: nr_dims
	}
	t.type_idxs[name] = idx
	t.types << list_fixed_type
	return idx, name
}

pub fn (mut t Table) find_or_register_list(elem_ti &types.TypeIdent, nr_dims int) (int, string) {
	name := 'list_${elem_ti.name}' + if nr_dims > 1 { '_${nr_dims}d' } else { '' }
	// existing
	existing_idx := t.type_idxs[name]
	if existing_idx > 0 {
		return existing_idx, name
	}
	// register
	idx := t.types.len
	mut list_type := types.Type(types.Void{})
	list_type = types.List{
		idx: idx
		name: name
		elem_type_idx: elem_ti.idx
		elem_is_ptr: elem_ti.is_ptr()
		nr_dims: nr_dims
	}
	t.type_idxs[name] = idx
	t.types << list_type
	return idx, name
}

pub fn (mut t Table) find_or_register_tuple(elem_ti &types.TypeIdent, nr_dims int) (int, string) {
	name := 'tuple_${elem_ti.name}' + if nr_dims > 1 { '_${nr_dims}d' } else { '' }
	// existing
	existing_idx := t.type_idxs[name]
	if existing_idx > 0 {
		return existing_idx, name
	}
	// register
	idx := t.types.len
	mut tuple_type := types.Type(types.Void{})
	tuple_type = types.Tuple{
		idx: idx
		name: name
		elem_type_idx: elem_ti.idx
		elem_is_ptr: elem_ti.is_ptr()
		nr_dims: nr_dims
	}
	t.type_idxs[name] = idx
	t.types << tuple_type
	return idx, name
}

pub fn (mut t Table) find_or_register_map(key_ti &types.TypeIdent, value_ti &types.TypeIdent) (int, string) {
	name := 'map_${key_ti.name}_${value_ti.name}'
	// existing
	existing_idx := t.type_idxs[name]
	if existing_idx > 0 {
		return existing_idx, name
	}
	// register
	idx := t.types.len
	mut map_type := types.Type(types.Void{})
	map_type = types.Map{
		name: name
		key_type_idx: key_ti.idx
		value_type_idx: value_ti.idx
	}
	t.type_idxs[name] = idx
	t.types << map_type
	return idx, name
}

pub fn (mut t Table) find_or_register_multi_return(mr_tis []types.TypeIdent) (int, string) {
	mut name := 'multi_return'
	for mr_ti in mr_tis {
		name += '_${mr_ti.name}'
	}
	// existing
	existing_idx := t.type_idxs[name]
	if existing_idx > 0 {
		return existing_idx, name
	}
	// register
	idx := t.types.len
	mut mr_type := types.Type(types.Void{})
	mr_type = types.MultiReturn{
		idx: idx
		name: name
		tis: mr_tis
	}
	t.type_idxs[name] = idx
	t.types << mr_type
	return idx, name
}

pub fn (mut t Table) find_or_register_variadic(variadic_ti &types.TypeIdent) (int, string) {
	name := 'variadic_${variadic_ti.name}'
	// existing
	existing_idx := t.type_idxs[name]
	if existing_idx > 0 {
		return existing_idx, name
	}
	// register
	idx := t.types.len
	mut variadic_type := types.Type(types.Void{})
	variadic_type = types.Variadic{
		idx: idx
		ti: variadic_ti
	}
	t.type_idxs[name] = idx
	t.types << variadic_type
	return idx, name
}

[inline]
pub fn (t &Table) find_type_idx(name string) int {
	return t.type_idxs[name]
}

[inline]
pub fn (t &Table) find_type(name string) ?types.Type {
	idx := t.type_idxs[name]
	for idx0, type0 in t.types {
		if idx0 == idx && name.starts_with('struct_') {
			return type0
		}
	}
	return none
}

pub fn (mut t Table) add_placeholder_type(name string) int {
	idx := t.types.len
	t.type_idxs[name] = t.types.len
	mut pt := types.Type(types.Void{})
	pt = types.Placeholder{
		idx: idx
		name: name
	}
	t.types << pt
	return idx
}
