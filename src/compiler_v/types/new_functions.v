module types

pub fn new_struct(name string) TypeIdent {
	return new_ti(.struct_, name, 20)
}

pub fn new_enum(name string) TypeIdent {
	return new_ti(.enum_, name, 21)
}

pub fn new_result(name string) TypeIdent {
	return new_ti(.result_, name, 22)
}

pub fn new_ti(kind Kind, name string, idx int) TypeIdent {
	return TypeIdent{
		idx: idx
		kind: kind
		name: name
	}
}

pub fn new_builtin_ti(kind Kind, is_list bool) TypeIdent {
	return TypeIdent{
		name: kind.str()
		idx: -int(kind) - 1
		is_list: is_list
		kind: kind
	}
}

pub fn new_sum_ti(sum_kind []Kind) TypeIdent {
	mut name := ['SUM']
	for k in sum_kind {
		name << k.str()
	}

	return TypeIdent{
		name: name.join('::')
		idx: 100
		kind: .sum_
		sum_kind: sum_kind
	}
}
