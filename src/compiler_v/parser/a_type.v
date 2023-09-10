module parser

// Copyright (c) 2023 Helder de Sousa. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.
import compiler_v.types

pub fn (mut p Parser) parse_list_ti() types.TypeIdent {
	p.check(.lsbr)
	// fixed list
	if p.tok.kind in [.integer, .float] {
		size := p.tok.lit.int()
		p.check(.rsbr)
		elem_ti := p.parse_ti()
		idx, name := p.program.table.find_or_register_list_fixed(&elem_ti, size, 1)
		return types.new_ti(.list_fixed_, name, idx)
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
	return types.new_ti(.list_, name, idx)
}

pub fn (mut p Parser) parse_map_ti() types.TypeIdent {
	p.next_token()
	p.check(.lsbr)
	key_ti := p.parse_ti()
	p.check(.rsbr)
	value_ti := p.parse_ti()
	idx, name := p.program.table.find_or_register_map(&key_ti, &value_ti)
	return types.new_ti(.map_, name, idx)
}

pub fn (mut p Parser) parse_ti_name(name string) types.TypeIdent {
	mut name0 := name
	mut is_enum := false
	if name == 'enum_' {
		is_enum = true
	}
	for p.tok.kind == .amp {
		p.check(.amp)
	}
	match p.tok.kind {
		// list
		.lsbr {
			return p.parse_list_ti()
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
			return match p.tok.lit {
				// map
				'map' {
					p.parse_map_ti()
				}
				'nil' {
					types.new_builtin_ti(.nil_, false)
				}
				'atom' {
					types.new_builtin_ti(.atom_, false)
				}
				'any' {
					types.new_builtin_ti(.any_, false)
				}
				'pointer' {
					types.new_builtin_ti(.pointer_, false)
				}
				'int', 'integer' {
					types.new_builtin_ti(.integer_, false)
				}
				'float' {
					types.new_builtin_ti(.float_, false)
				}
				'string' {
					types.new_builtin_ti(.string_, false)
				}
				'char' {
					types.new_builtin_ti(.char_, false)
				}
				'bool', 'boolean' {
					types.new_builtin_ti(.bool_, false)
				}
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
					return types.new_ti(.void_, name, idx)
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
