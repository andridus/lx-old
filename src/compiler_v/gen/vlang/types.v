module vlang

import compiler_v.types
import compiler_v.ast

fn parse_field(field ast.Field) string {
	kind := parse_type(field.ti.kind)
	mut name := field.name
	return '${name} ${kind}'
}

fn parse_arg_simple(arg ast.Arg, name string) string {
	kind := parse_type(arg.ti.kind)
	return '${name} ${kind}'
}

fn parse_arg_simple_pointer(arg ast.Arg, name string) string {
	kind := parse_type_ti(arg.ti)
	return '${name} ${kind}'
}

fn parse_arg_simple_pointer_no_arg(arg ast.Arg) string {
	kind := parse_type_ti(arg.ti)
	match arg.ti.kind {
		.string_ {
			return '${kind}'
		}
		else {
			return '${kind}'
		}
	}
}

fn parse_arg(arg ast.Arg) string {
	kind := parse_type(arg.ti.kind)
	return '${kind}'
}

fn parse_arg_pointer(arg ast.Arg, name string) string {
	kind := parse_type(arg.ti.kind)
	if ti_is_array(arg.ti) {
		return '${name} ${kind}[]'
	} else {
		return '${name} ${kind}'
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
		.atom_ { 'Atom' }
		.void_ { 'Nil' }
		.nil_ { 'void *' }
		.any_ { 'void *' }
		.pointer_ { 'void *' }
		.enum_ { 'enum' }
		.struct_ { 'struct' }
		.result_ { 'result' }
		.integer_ { 'int' }
		.float_ { 'f64' }
		.string_ { 'string' }
		.char_ { 'rune' }
		.bool_ { 'int' }
		.list_ { 'list' }
		.list_fixed_ { 'list' }
		.tuple_ { 'tuple' }
		.map_ { 'map' }
	}
}

fn ti_is_array(ti types.TypeIdent) bool {
	return ti.kind in [.string_, .list_, .list_fixed_, .tuple_]
}
