module ast

import compiler_v.color

pub fn throw_argument_error(args_error []string) {
	eprintln(color.fg(color.red, 0, '** (ArgumentError): errors were found at the given arguments\n'))
	for e in args_error {
		eprintln('\t ${color.fg(color.red, 0, e)}')
	}
	println('')
}
