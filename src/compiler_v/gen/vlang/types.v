module vlang

import compiler_v.types

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
		.bool_ { 'bool' }
		.list_ { 'list' }
		.list_fixed_ { 'list' }
		.tuple_ { 'tuple' }
		.map_ { 'map' }
		.sum_ { 'sum' }
	}
}
