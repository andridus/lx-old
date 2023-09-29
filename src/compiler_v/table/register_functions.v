module table

import compiler_v.types
import compiler_v.ast

pub fn (mut t Table) register_struct(elem_ti &types.TypeIdent, fields map[string]ast.Node) (int, string) {
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
	for _, field in fields {
		fields0 << types.Field{
			name: field.nodes[0].left.atomic_str()
			type_idx: idx
			ti: field.meta.ti
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

pub fn (mut t Table) register_alias(ident string, modl string) {
	t.global_aliases[ident] = modl
}
