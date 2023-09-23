// Copyright (c) 2023 Helder de Sousa. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.
module parser

// import compiler_v.ast
// import compiler_v.table
// import compiler_v.types
// import compiler_v.token
// import compiler_v.docs

// fn (mut p Parser) call_enum() !(ast.CallEnum, types.TypeIdent) {
// 	p.error_pos_in = p.tok.pos - p.tok.lit.len
// 	ti := p.parse_ti_name('enum_')
// 	mut value := ''
// 	p.check(.arrob)
// 	value = p.tok.lit
// 	p.check(.ident)
// 	idx, name0 := p.program.table.find_type_name(ti)
// 	t := p.program.table.types[idx]
// 	if t is types.Enum {
// 		if value in t.values {
// 			return ast.CallEnum{
// 				name: name0
// 				val: value
// 				ti: ti
// 			}, ti
// 		} else {
// 			p.error_pos_out = p.tok.pos
// 			p.log_d('ERROR', 'The value `${value}` of enum `${t.name}` is not valid. Please use one of ${t.values}`',
// 				'', '', '')
// 			exit(1)
// 		}
// 	} else {
// 		p.error_pos_out = p.tok.pos
// 		p.log_d('ERROR', 'The enum `{fun_name.lit}` is not defined.`', '', '', '')
// 		exit(1)
// 	}
// }

// fn (mut p Parser) defenum_decl() ast.EnumDecl {
// 	// pos_in := p.tok.pos
// 	// mut pos_out := p.tok.pos
// 	is_private := p.tok.kind == .key_defenump
// 	if is_private {
// 		p.check(.key_defenump)
// 	} else {
// 		p.check(.key_defenum)
// 	}

// 	name := p.check_modl_name()
// 	p.check(.lsbr)

// 	// GET values
// 	mut values := []string{}

// 	for p.tok.kind != .rsbr {
// 		values << p.check_atom()
// 		for p.tok.kind == .comma {
// 			p.check(.comma)
// 			values << p.check_atom()
// 		}
// 	}

// 	p.check(.rsbr)
// 	ti := types.new_enum('${name}')
// 	p.program.table.register_enum(ti, values)
// 	return ast.EnumDecl{
// 		name: 'enum_${name}'
// 		values: values
// 		ti: ti
// 		// size:
// 		is_pub: !is_private
// 	}
// }
