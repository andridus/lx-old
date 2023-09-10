// Copyright (c) 2023 Helder de Sousa. All rights reserved
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file
module types

import compiler_v.token

pub enum Kind {
	void_
	any_
	nil_
	atom_
	string_
	char_
	bool_
	list_
	list_fixed_
	tuple_
	map_
	integer_
	float_
	pointer_
	enum_
	result_
	struct_
	sum_
}

pub type Type = Atom
	| Bool
	| Char
	| Enum
	| Float
	| Integer
	| List
	| ListFixed
	| Map
	| Nil
	| String
	| Struct
	| Tuple
	| Void

pub struct TypeIdent {
pub:
	name     string
	idx      int
	is_list  bool
	kind     Kind
	sum_kind []Kind
}

pub struct Nil {}

pub struct Void {}

pub struct Atom {
pub:
	idx  int
	name string
}

pub struct Enum {
pub:
	idx    int
	name   string
	values []string
}

pub struct Struct {
pub:
	idx        int
	parent_idx int
	name       string
pub mut:
	fields  []Field
	methods []Field
}

pub struct Field {
pub:
	name     string
	type_idx int
	ti       TypeIdent
}

pub struct Integer {
pub:
	bit_size    u32
	is_unsigned bool
}

pub struct Float {
	bit_size u32
}

pub struct String {}

pub struct Char {}

pub struct Bool {}

pub struct List {
pub:
	idx            int
	name           string
	elem_type_kind Kind
	elem_type_idx  int
	elem_is_ptr    bool
	nr_dims        int
}

pub struct ListFixed {
pub:
	idx            int
	name           string
	elem_type_kind Kind
	elem_type_idx  int
	elem_is_ptr    bool
	nr_dims        int
	size           int
}

pub struct Tuple {
pub:
	idx            int
	name           string
	elem_type_kind Kind
	elem_type_idx  int
	elem_is_ptr    bool
	nr_dims        int
	size           int
}

pub struct Map {
pub:
	idx             int
	name            string
	key_type_kind   Kind
	key_type_idx    int
	value_type_kind Kind
	value_type_idx  int
}

pub const (
	atom_type    = Atom{}
	nil_type     = Nil{}
	void_type    = Void{}
	integer_type = Integer{32, false}
	float_type   = Float{32}
	string_type  = String{}
	char_type    = Char{}
	bool_type    = Bool{}
)

pub const (
	pointer_ti  = new_builtin_ti(.pointer_, false)
	void_ti     = new_builtin_ti(.void_, false)
	nil_ti      = new_builtin_ti(.nil_, false)
	any_ti      = new_builtin_ti(.any_, false)
	integer_ti  = new_builtin_ti(.integer_, false)
	float_ti    = new_builtin_ti(.float_, false)
	string_ti   = new_builtin_ti(.string_, false)
	charlist_ti = new_builtin_ti(.char_, true)
	tuple_ti    = new_builtin_ti(.tuple_, false)
	bool_ti     = new_builtin_ti(.bool_, false)
	atom_ti     = new_builtin_ti(.atom_, false)
)

pub fn get_default_type(kind token.Kind) TypeIdent {
	return match kind {
		.plus {
			types.integer_ti
		}
		.minus {
			types.integer_ti
		}
		.mul {
			types.integer_ti
		}
		.div {
			types.integer_ti
		}
		.mod {
			types.integer_ti
		}
		.xor {
			types.integer_ti
		}
		.pipe {
			types.integer_ti
		}
		.eq {
			types.bool_ti
		}
		.seq {
			types.bool_ti
		}
		.eqt {
			types.bool_ti
		}
		.ne {
			types.bool_ti
		}
		.sne {
			types.bool_ti
		}
		.gt {
			types.bool_ti
		}
		.lt {
			types.bool_ti
		}
		.ge {
			types.bool_ti
		}
		.le {
			types.bool_ti
		}
		.and {
			types.bool_ti
		}
		.logical_or {
			types.bool_ti
		}
		.key_and {
			types.bool_ti
		}
		.key_or {
			types.bool_ti
		}
		else {
			types.void_ti
		}
	}
}
