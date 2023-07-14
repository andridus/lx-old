// Copyright (c) 2023 Helder de Sousa. All rights reserved
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file
module types

import compiler_v.token

pub enum Kind {
	atom
	placeholder
	void
	nil_
	any_
	voidptr
	charptr
	byteptr
	const_
	enum_
	result_
	struct_
	int
	i8
	i16
	i64
	byte
	u16
	u32
	u64
	f32
	f64
	number
	string
	char
	bool
	list
	list_fixed
	tuple
	map
	multi_return
	variadic
}

pub type Type = Atom
	| Bool
	| Byte
	| Byteptr
	| Char
	| Charptr
	| Const
	| Enum
	| Float
	| Int
	| List
	| ListFixed
	| Map
	| MultiReturn
	| Placeholder
	| String
	| Struct
	| Tuple
	| Variadic
	| Void
	| Voidptr

pub struct TypeIdent {
pub:
	idx     int
	is_list bool
	kind    Kind
	name    string
	nr_muls int
}

pub fn new_struct(name string) TypeIdent {
	return new_ti(.struct_, name, 20, 0)
}

pub fn new_enum(name string) TypeIdent {
	return new_ti(.enum_, name, 21, 0)
}

pub fn new_result(name string) TypeIdent {
	return new_ti(.result_, name, 22, 0)
}

pub fn new_ti(kind Kind, name string, idx int, nr_muls int) TypeIdent {
	return TypeIdent{
		idx: idx
		kind: kind
		name: name
		nr_muls: nr_muls
	}
}

pub fn new_builtin_ti(kind Kind, nr_muls int, is_list bool) TypeIdent {
	return TypeIdent{
		idx: -int(kind) - 1
		is_list: is_list
		kind: kind
		name: kind.str()
		nr_muls: nr_muls
	}
}

[inline]
pub fn (ti &TypeIdent) is_ptr() bool {
	return ti.nr_muls > 0
}

[inline]
pub fn (ti TypeIdent) is_int() bool {
	return ti.kind in [.i8, .i16, .int, .i64, .byte, .u16, .u32, .u64]
}

[inline]
pub fn (ti TypeIdent) is_float() bool {
	return ti.kind in [.f32, .f64]
}

[inline]
pub fn (ti &TypeIdent) is_number() bool {
	return ti.is_int() || ti.is_float()
}

pub fn (ti &TypeIdent) str() string {
	mut muls := ''
	for _ in 0 .. ti.nr_muls {
		muls += '&'
	}
	list := if ti.is_list { 'list' } else { '' }
	return '${muls}${ti.name}${list}'
}

pub fn check(got TypeIdent, expected &TypeIdent) bool {
	if expected.kind == .voidptr {
		return true
	}
	if expected.name == 'array' {
		return true
	}
	if got.idx != expected.idx {
		return false
	}
	return true
}

pub fn (k Kind) str() string {
	k_str := match k {
		.atom {
			'atom'
		}
		.placeholder {
			'placeholder'
		}
		.void {
			'void'
		}
		.nil_ {
			'nil'
		}
		.any_ {
			'any'
		}
		.voidptr {
			'voidptr'
		}
		.charptr {
			'charptr'
		}
		.byteptr {
			'byteptr'
		}
		.const_ {
			'const'
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
		.int {
			'int'
		}
		.i8 {
			'i8'
		}
		.i16 {
			'i16'
		}
		.i64 {
			'i64'
		}
		.byte {
			'byte'
		}
		.u16 {
			'u18'
		}
		.f32 {
			'f32'
		}
		.f64 {
			'f64'
		}
		.string {
			'string'
		}
		.char {
			'char'
		}
		.bool {
			'bool'
		}
		.list {
			'list'
		}
		.list_fixed {
			'list_fixed'
		}
		.tuple {
			'tuple'
		}
		.map {
			'map'
		}
		.multi_return {
			'multi_return'
		}
		.variadic {
			'variadic'
		}
		.number {
			'number'
		}
		else {
			'unknown'
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

pub struct Placeholder {
pub:
	idx  int
	name string
}

pub struct Nil {}

pub struct Void {}

pub struct Voidptr {}

pub struct Charptr {}

pub struct Byteptr {}

pub struct Atom {
pub:
	idx  int
	name string
}

pub struct Const {
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
}

pub struct Int {
pub:
	bit_size    u32
	is_unsigned bool
}

pub struct Float {
	bit_size u32
}

pub struct String {}

pub struct Char {}

pub struct Byte {}

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

pub struct MultiReturn {
pub:
	idx  int
	name string
	tis  []TypeIdent
}

pub struct Variadic {
pub:
	idx int
	ti  TypeIdent
}

pub fn (t Nil) str() string {
	return 'nil'
}

pub fn (t Void) str() string {
	return 'void'
}

pub fn (t Voidptr) str() string {
	return 'voidptr'
}

pub fn (t Charptr) str() string {
	return 'charptr'
}

pub fn (t Byteptr) str() string {
	return 'byteptr'
}

pub fn (t Const) str() string {
	return t.name
}

pub fn (t Enum) str() string {
	return t.name
}

pub fn (t Struct) str() string {
	return t.name
}

pub fn (t Int) str() string {
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

pub fn (t Byte) str() string {
	return 'byte'
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

pub fn (t MultiReturn) str() string {
	return t.name
}

pub fn (t Variadic) str() string {
	return 'variadic_${t.ti.kind.str()}'
}

pub const (
	nil_type     = Nil{}
	void_type    = Void{}
	voidptr_type = Voidptr{}
	charptr_type = Charptr{}
	byteptr_type = Byteptr{}
	i8_type      = Int{8, false}
	i16_type     = Int{16, false}
	int_type     = Int{32, false}
	i64_type     = Int{64, false}
	byte_type    = Int{8, true}
	u16_type     = Int{16, true}
	u32_type     = Int{32, true}
	u64_type     = Int{64, true}
	f32_type     = Float{32}
	f64_type     = Float{64}
	string_type  = String{}
	char_type    = Char{}
	bool_type    = Bool{}
)

pub fn type_from_token(tok token.Token) TypeIdent {
	return match tok.kind {
		.key_any { types.any_ti }
		.key_nil { types.nil_ti }
		.integer { types.int_ti }
		.float { types.float_ti }
		.str { types.string_ti }
		else { types.void_ti }
	}
}

pub const (
	void_ti     = new_builtin_ti(.void, 0, false)
	nil_ti      = new_builtin_ti(.nil_, 0, false)
	any_ti      = new_builtin_ti(.any_, 0, false)
	int_ti      = new_builtin_ti(.int, 0, false)
	number_ti   = new_builtin_ti(.number, 0, false)
	float_ti    = new_builtin_ti(.f32, 0, false)
	string_ti   = new_builtin_ti(.string, 0, false)
	charlist_ti = new_builtin_ti(.char, 0, true)
	tuple_ti    = new_builtin_ti(.tuple, 0, false)
	bool_ti     = new_builtin_ti(.bool, 0, false)
	atom_ti     = new_builtin_ti(.atom, 0, false)
)

pub fn get_default_type(kind token.Kind) TypeIdent {
	return match kind {
		.not {
			types.int_ti
		}
		.plus {
			types.int_ti
		}
		.minus {
			types.int_ti
		}
		.mul {
			types.int_ti
		}
		.div {
			types.int_ti
		}
		.mod {
			types.int_ti
		}
		.xor {
			types.int_ti
		}
		.pipe {
			types.int_ti
		}
		else {
			types.void_ti
		}
	}
}
