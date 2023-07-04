module c

import types
import compiler_v.ast

fn parse_arg(arg ast.Arg) string {
	kind := parse_type(arg.ti.kind)
	if ti_is_array(arg.ti) {
		return '${kind} ${arg.name}[]'
	} else {
		return '${kind} ${arg.name}'
	}
}

fn parse_type(kind types.Kind) string {
	return match kind {
		.atom { 'int' }
		.placeholder { 'placeholder' }
		.void { 'void' }
		.voidptr { 'voidptr' }
		.charptr { 'charptr' }
		.byteptr { 'byteptr' }
		.const_ { 'const' }
		.enum_ { 'enum' }
		.struct_ { 'struct' }
		.int { 'int' }
		.i8 { 'i8' }
		.i16 { 'i16' }
		.i64 { 'i64' }
		.byte { 'byte' }
		.u16 { 'u16' }
		.u32 { 'u32' }
		.u64 { 'u64' }
		.f32 { 'f32' }
		.f64 { 'f64' }
		.string { 'char' }
		.char { 'char' }
		.bool { 'bool' }
		.list { 'list' }
		.list_fixed { 'list' }
		.tuple { 'tuple' }
		.map { 'map' }
		.multi_return { 'multi' }
		.variadic { 'variadic' }
		.number { 'number' }
	}
}

fn ti_is_array(ti types.TypeIdent) bool {
	return ti.kind in [.string, .list, .list_fixed, .tuple]
}
