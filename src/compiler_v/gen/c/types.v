module c

import compiler_v.types
import compiler_v.ast

fn parse_field(field ast.Field) string {
	kind := parse_type(field.ti.kind)
	mut name := field.name
	match field.ti.kind {
		.string { name = '*${name}' }
		else {}
	}
	return '${kind} ${name}'
}

fn parse_arg_simple(arg ast.Arg, name string) string {
	kind := parse_type(arg.ti.kind)
	return '${kind} ${name}'
}

fn parse_arg_simple_pointer(arg ast.Arg, name string) string {
	kind := parse_type_ti(arg.ti)
	match arg.ti.kind {
		.string {
			return '${kind} *${name}'
		}
		else {
			return '${kind} ${name}'
		}
	}
}

fn parse_arg_simple_pointer_no_arg(arg ast.Arg) string {
	kind := parse_type_ti(arg.ti)
	match arg.ti.kind {
		.string {
			return '${kind} *'
		}
		else {
			return '${kind}'
		}
	}
}

fn parse_arg(arg ast.Arg, name string) string {
	kind := parse_type(arg.ti.kind)
	if ti_is_array(arg.ti) {
		return '${kind} ${name}[]'
	} else {
		return '${kind} ${name}'
	}
}

fn parse_arg_pointer(arg ast.Arg, name string) string {
	kind := parse_type(arg.ti.kind)
	if ti_is_array(arg.ti) {
		return '${kind} *${name}[]'
	} else {
		return '${kind} *${name}'
	}
}

fn parse_type_ti(ti types.TypeIdent) string {
	if ti.kind in [.struct_, .enum_] {
		return ti.name
	} else {
		return parse_type(ti.kind)
	}
}

fn parse_type(kind types.Kind) string {
	return match kind {
		.atom { 'int' }
		.placeholder { 'placeholder' }
		.void { 'void' }
		.nil_ { 'nil' }
		.any_ { 'any' }
		.voidptr { 'voidptr' }
		.charptr { 'charptr' }
		.byteptr { 'byteptr' }
		.const_ { 'const' }
		.enum_ { 'enum' }
		.struct_ { 'struct' }
		.result_ { 'result' }
		.int { 'int' }
		.i8 { 'i8' }
		.i16 { 'i16' }
		.i64 { 'i64' }
		.byte { 'byte' }
		.u16 { 'u16' }
		.u32 { 'u32' }
		.u64 { 'u64' }
		.f32 { 'double' }
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
