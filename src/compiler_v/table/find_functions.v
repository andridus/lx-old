module table

import compiler_v.types

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

pub fn (t &Table) find_fn(name string, module_name string) ?Fn {
	f := t.fns[module_name + '.' + name]
	if f.is_valid {
		return f
	}
	return none
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

pub fn (mut t Table) find_alias(ident string) string {
	id := t.global_aliases[ident]
	return if id.len > 0 { id } else { ident }
}
