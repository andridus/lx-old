module types

pub fn (ti &TypeIdent) str() string {
	list := if ti.is_list { 'list' } else { '' }
	return '${ti.name}${list}'
}

pub fn (k Kind) str() string {
	k_str := match k {
		.void_ {
			'void'
		}
		.any_ {
			'any'
		}
		.atom_ {
			'atom'
		}
		.nil_ {
			'nil'
		}
		.pointer_ {
			'pointer'
		}
		.enum_ {
			'enum'
		}
		.result_ {
			'result'
		}
		.struct_ {
			'struct'
		}
		.integer_ {
			'integer'
		}
		.float_ {
			'float'
		}
		.string_ {
			'string'
		}
		.char_ {
			'char'
		}
		.bool_ {
			'bool'
		}
		.list_ {
			'list'
		}
		.list_fixed_ {
			'list_fixed'
		}
		.tuple_ {
			'tuple'
		}
		.map_ {
			'map'
		}
	}
	return k_str
}

pub fn (kinds []Kind) str() string {
	mut kinds_str := ''
	for i, k in kinds {
		kinds_str += k.str()
		if i < kinds.len - 1 {
			kinds_str += '_'
		}
	}
	return kinds_str
}

pub fn (t Nil) str() string {
	return 'nil'
}

pub fn (t Void) str() string {
	return 'void'
}

pub fn (t Enum) str() string {
	return t.name
}

pub fn (t Struct) str() string {
	return t.name
}

pub fn (t Integer) str() string {
	return if t.is_unsigned { 'u${t.bit_size}' } else { 'i${t.bit_size}' }
}

pub fn (t Float) str() string {
	return 'f${t.bit_size}'
}

pub fn (t String) str() string {
	return 'string'
}

pub fn (t Char) str() string {
	return 'char'
}

pub fn (t List) str() string {
	return t.name
}

pub fn (t ListFixed) str() string {
	return t.name
}

pub fn (t Map) str() string {
	return t.name
}
