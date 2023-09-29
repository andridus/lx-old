// Copyright (c) 2023 Helder de Sousa. All rights reserved
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file
import os
import compiler_v

fn main() {
	if os.args.len >= 2 {
		command := os.args[1]
		match command {
			'-c' {
				compiler_v.compile(os.args)
			}
			else {
				println('Basic commands `lx [file.ex]` or `lx .`(to current folder) or `lx repl`')
			}
		}
	} else {
		println('Basic commands `lx [file.ex]` or `lx .`(to current folder) or `lx repl`')
	}
}
