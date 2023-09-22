// Copyright (c) 2023 Helder de Sousa. All rights reserved
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file
module ast

import compiler_v.types

pub type NodeKind = Alias
	| Ast
	| Atom
	| Atomic
	| Bool
	| Char
	| Enum
	| Float
	| Function
	| FunctionCaller
	| Integer
	| List
	| ListFixed
	| Map
	| Module
	| Nil
	| Port
	| Record
	| String
	| Struct
	| Tuple

pub struct Function {
pub:
	name        string
	module_name string
	arity       string
	args        []Node
	return_ti   types.TypeIdent
	is_private  bool
	is_main     bool
}

pub struct FunctionCaller {
pub:
	name        string
	module_name string
	arity       []string
	args        []Node
	return_ti   types.TypeIdent
	infix       bool
	postfix     bool
}

pub struct Alias {}

pub struct Module {}

pub struct Record {}

pub struct Port {}

pub struct Nil {}

pub struct Void {}

pub struct Atomic {}

pub struct Ast {
pub:
	lit string
}

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
	ti       types.TypeIdent
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
	elem_type_kind types.Kind
	elem_type_idx  int
	elem_is_ptr    bool
	nr_dims        int
}

pub struct ListFixed {
pub:
	idx            int
	name           string
	elem_type_kind types.Kind
	elem_type_idx  int
	elem_is_ptr    bool
	nr_dims        int
	size           int
}

pub struct Tuple {
pub:
	idx            int
	name           string
	elem_type_kind types.Kind
	elem_type_idx  int
	elem_is_ptr    bool
	nr_dims        int
	size           int
}

pub struct Map {
pub:
	idx             int
	name            string
	key_type_kind   types.Kind
	key_type_idx    int
	value_type_kind types.Kind
	value_type_idx  int
}

pub fn (kind NodeKind) is_literal() bool {
	return match kind {
		Bool, Char, Enum, Float, Integer, Nil, String, Struct, Tuple { true }
		else { false }
	}
}
