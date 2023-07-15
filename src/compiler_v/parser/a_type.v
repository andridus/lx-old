module parser

// Copyright (c) 2023 Helder de Sousa. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.
import compiler_v.types

pub fn (mut p Parser) parse_list_ti(nr_muls int) types.TypeIdent {
	p.check(.lsbr)
	// fixed list
	if p.tok.kind in [.integer, .float] {
		size := p.tok.lit.int()
		p.check(.rsbr)
		elem_ti := p.parse_ti()
		idx, name := p.program.table.find_or_register_list_fixed(&elem_ti, size, 1)
		return types.new_ti(.list_fixed, name, idx, nr_muls)
	}
	// list
	p.check(.rsbr)
	elem_ti := p.parse_ti()
	mut nr_dims := 1
	for p.tok.kind == .lsbr {
		p.check(.lsbr)
		p.check(.rsbr)
		nr_dims++
	}
	idx, name := p.program.table.find_or_register_list(&elem_ti, nr_dims)
	return types.new_ti(.list, name, idx, nr_muls)
}

pub fn (mut p Parser) parse_map_ti(nr_muls int) types.TypeIdent {
	p.next_token()
	p.check(.lsbr)
	key_ti := p.parse_ti()
	p.check(.rsbr)
	value_ti := p.parse_ti()
	idx, name := p.program.table.find_or_register_map(&key_ti, &value_ti)
	return types.new_ti(.map, name, idx, nr_muls)
}

pub fn (mut p Parser) parse_multi_return_ti() types.TypeIdent {
	p.check(.lpar)
	mut mr_tis := []types.TypeIdent{}
	for {
		mr_ti := p.parse_ti()
		mr_tis << mr_ti
		if p.tok.kind == .comma {
			p.check(.comma)
		} else {
			break
		}
	}
	p.check(.rpar)
	idx, name := p.program.table.find_or_register_multi_return(mr_tis)
	return types.new_ti(.multi_return, name, idx, 0)
}

pub fn (mut p Parser) parse_variadic_ti() types.TypeIdent {
	p.check(.ellipsis)
	variadic_ti := p.parse_ti()
	idx, name := p.program.table.find_or_register_variadic(&variadic_ti)
	return types.new_ti(.variadic, name, idx, 0)
}

pub fn (mut p Parser) parse_ti_name(name string) types.TypeIdent {
	mut name0 := name
	mut is_enum := false
	mut nr_muls := 0
	if name == 'enum_' {
		is_enum = true
	}
	for p.tok.kind == .amp {
		p.check(.amp)
		nr_muls++
	}
	match p.tok.kind {
		// list
		.lsbr {
			return p.parse_list_ti(nr_muls)
		}
		// multiple return
		.lpar {
			if nr_muls > 0 {
				p.error('parse_ti: unexpected `&` before multiple returns')
			}
			return p.parse_multi_return_ti()
		}
		// variadic
		.ellipsis {
			if nr_muls > 0 {
				p.error('parse_ti: unexpected `&` before variadic')
			}
			return p.parse_variadic_ti()
		}
		.modl {
			name0 = name + p.get_mdl_name()
			name0 = p.program.table.find_alias(name0).to_lower().replace('.', '_')

			if p.peek_tok.kind == .arrob && name != 'enum_' {
				p.check(.modl)
				p.check(.arrob)
				name0 = 'enum_' + name0
				is_enum = true
			} else if name == 'enum_' {
				p.check(.modl)
			} else {
				name0 = 'struct_' + name0
			}
			mut idx := p.program.table.find_type_idx(name0)

			if idx >= 0 {
				if is_enum {
					return types.new_enum(name0)
				}
				for i, t in p.program.table.types {
					if i == idx {
						if t is types.Struct {
							return types.new_struct(name0)
						}
					}
				}
			}
			p.error('Module is not a type ident')
			exit(0)
		}
		else {
			defer {
				p.next_token()
			}
			match p.tok.lit {
				// map
				'map' {
					return p.parse_map_ti(nr_muls)
				}
				'nil' {
					return types.new_builtin_ti(.nil_, nr_muls, false)
				}
				'any' {
					return types.new_builtin_ti(.any_, nr_muls, false)
				}
				'pointer' {
					return types.new_builtin_ti(.pointer, nr_muls, false)
				}
				'voidptr' {
					return types.new_builtin_ti(.voidptr, nr_muls, false)
				}
				'byteptr' {
					return types.new_builtin_ti(.byteptr, nr_muls, false)
				}
				'charptr' {
					return types.new_builtin_ti(.charptr, nr_muls, false)
				}
				'i8' {
					return types.new_builtin_ti(.i8, nr_muls, false)
				}
				'i16' {
					return types.new_builtin_ti(.i16, nr_muls, false)
				}
				'int', 'integer' {
					return types.new_builtin_ti(.int, nr_muls, false)
				}
				'i64' {
					return types.new_builtin_ti(.i64, nr_muls, false)
				}
				'byte' {
					return types.new_builtin_ti(.byte, nr_muls, false)
				}
				'u16' {
					return types.new_builtin_ti(.u16, nr_muls, false)
				}
				'u32' {
					return types.new_builtin_ti(.u32, nr_muls, false)
				}
				'u64' {
					return types.new_builtin_ti(.u64, nr_muls, false)
				}
				'f32', 'float' {
					return types.new_builtin_ti(.f32, nr_muls, false)
				}
				'f64' {
					return types.new_builtin_ti(.f64, nr_muls, false)
				}
				'string' {
					return types.new_builtin_ti(.string, nr_muls, false)
				}
				'char' {
					return types.new_builtin_ti(.char, nr_muls, false)
				}
				'bool' {
					return types.new_builtin_ti(.bool, nr_muls, false)
				}
				// struct / enum / placeholder
				else {
					mut is_result := false
					if p.tok.kind == .lcbr && p.peek_tok.lit == 'ok' {
						// IF result like {ok}integer, should be return {:ok, integer} or {:error, atom}
						p.check(.lcbr)
						p.check(.atom)
						if p.tok.kind == .rcbr && p.peek_tok.kind in [.ident, .atom, .modl] {
							name0 = 'result_${p.peek_tok.lit}'
							is_result = true
							p.check(.rcbr)
						} else {
							println('Tuple not implemented yet')
							exit(0)
						}
					}

					// struct
					mut idx := p.program.table.find_type_idx(name0)
					// add placeholder

					if is_result {
						return types.new_result(name0)
					}
					return types.new_ti(.placeholder, name, idx, nr_muls)
				}
			}
		}
	}
}

pub fn (mut p Parser) parse_ti() types.TypeIdent {
	mut nr_muls := 0
	for p.tok.kind == .amp {
		p.check(.amp)
		nr_muls++
	}
	// name := p.tok.lit
	return p.parse_ti_name('')
}
