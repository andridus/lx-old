module parser

import compiler_v.table
import compiler_v.lexer
import os
import compiler_v.color
import compiler_v.token

// The parse module is responsible to make an overview about files
// and define basic informations about module compilation, that's include:
// - Requireds modules to compile
// - Detects the  main module over the main function defined in itself
// - Set the headers->functions with summary of functions that are defined in itself
pub fn preprocess(path string, prog &table.Program) {
	mut prog0 := unsafe { prog }
	mut metadata := generate_core_modules(prog)
	prog0.core_modules = metadata.move()
	if os.is_dir(path) {
		files := os.ls('${path}') or { []string{} }
		for file in files {
			parse_modules('${path}/${file}', prog)
		}
	} else {
		parse_modules('${path}', prog)
	}
	prog0.compile_order = compile_order(prog)
}

fn generate_core_modules(prog &table.Program) map[string]table.Module {
	mut metadata := map[string]table.Module{}
	for path in prog.core_modules_path {
		if os.is_dir(path) {
			files := get_all_files_in_dir(path)
			for file in files {
				meta := generate_module_core_metadata(file, prog)
				metadata[meta.name] = meta
			}
		} else {
			meta := generate_module_core_metadata('${path}', prog)
			metadata[meta.name] = meta
		}
	}
	return metadata
}

fn get_all_files_in_dir(dir string) []string {
	mut all_files := []string{}
	if os.is_dir(dir) {
		files := os.ls('${dir}') or { []string{} }
		for file in files {
			arr := get_all_files_in_dir('${dir}/${file}')
			for a in arr {
				all_files << a
			}
		}
	} else {
		all_files << dir
	}
	return all_files
}

fn generate_module_core_metadata(path string, prog &table.Program) table.Module {
	// mut prog0 := unsafe { prog }
	text := os.read_file(path) or {
		println(err)
		exit(0)
	}
	mut l := lexer.new(text)
	l.generate_tokens()
	mut functions := []string{}
	tk_len := l.tokens.len
	mut name := ''
	mut i := 0
	// ------ analyze entire source code of file
	for i < tk_len {
		match l.tokens[i].kind {
			// Gets the name module
			.key_defmodule {
				i++
				i, name = get_module_name(i, l.tokens[i], l.tokens)
			}
			// Define the main module when have the main function
			// TODO: get functions with arity and put on module headers struct, event if not defined type.
			.key_def {
				i++
				if i < tk_len {
					tk := l.tokens[i]
					if tk.kind == .ident {
						functions << tk.lit
					}
				}
			}
			else {}
		}
		i++
	}
	return table.Module{
		name: name
		path: path
		dependencies: []
		is_main: false
	}
}

fn parse_modules(path string, prog &table.Program) {
	text := os.read_file(path) or { panic(err) }
	mut l := lexer.new(text)
	l.generate_tokens()
	mut prog0 := unsafe { prog }
	mut is_main := false
	mut dependencies := []string{}
	mut aliases := map[string]string{}
	tk_len := l.tokens.len
	mut name := ''
	mut aliases_name := ''
	mut i := 0
	mut inner := 0
	ignore_dependencies := [token.Kind.key_defstruct, .key_defenum]
	mut ignore_modules := []string{}
	// ------ analyze entire source code of file
	for i < tk_len {
		match l.tokens[i].kind {
			// Gets the name module
			.key_defmodule {
				i++
				if inner == 0 {
					i, name = get_module_name(i, l.tokens[i], l.tokens)
				}
			}
			.key_defstruct {
				i++
				mut name0 := ''
				i, name0 = get_module_name(i, l.tokens[i], l.tokens)
				if name0 != '' {
					ignore_modules << '${name}.${name0}'
					ignore_modules << name0
				}
			}
			.key_defenum {
				i++
				mut name0 := ''
				i, name0 = get_module_name(i, l.tokens[i], l.tokens)
				if name0 != '' {
					ignore_modules << '${name}.${name0}'
					ignore_modules << name0
				}
			}
			.key_do {
				inner++
			}
			.key_end {
				inner--
			}
			// Gets the requireds module by seek source code for external function calling
			// TODO: gets the arity of function
			.modl {
				if i > 0 && l.tokens[i - 1].kind !in ignore_dependencies {
					mut module_required_name := ''
					i, module_required_name = get_module_name(i, l.tokens[i], l.tokens)
					if module_required_name.len > 0 {
						if module_required_name !in ignore_modules {
							dependencies << module_required_name
						}
					}
				}
			}
			// Define the main module when have the main function
			.key_alias {
				i++

				i, aliases_name = get_module_name(i, l.tokens[i], l.tokens)
				// aliases << name
				a := aliases_name.clone().split('.').reverse().first()
				aliases[a] = aliases_name
				aliases_name = ''
				i--
			}
			// TODO: get functions with arity and put on module headers struct, event if not defined type.
			.key_def {
				i++
				if i < tk_len {
					tk := l.tokens[i]
					if tk.kind == .ident && tk.lit == 'main' {
						is_main = true
					}
				}
			}
			else {}
		}

		i++
	}
	mut dependencies0 := []string{}
	// println('aliases: $aliases')
	for dep in dependencies {
		mut inserted := false
		for k, v in aliases {
			if dep.starts_with(k) {
				// println('dep: $dep, k: $k, value; $v, !in $ignore_modules')
				if dep == k && k !in ignore_modules {
					dependencies0 << v
				} else {
					dependencies0 << dep.replace_once(k, v)
				}
				inserted = true
			}
		}
		if inserted == false {
			if dep !in ignore_modules {
				dependencies0 << dep
			}
		}
		// if modl := aliases[dep] {
		// 	println('name: $modl')
		// 	dependencies0 << modl
		// } else {
		// 	println('one: $dep')
		// 	if name != dep && dep !in ignore_modules {
		// 		dependencies0 << dep
		// 	}
		// }
	}
	prog0.modules[name] = table.Module{
		name: name
		path: path
		aliases: aliases
		dependencies: uniq(dependencies0)
		is_main: is_main
	}
}

// Get compile order from table that have information about modules
pub fn compile_order(prog &table.Program) []string {
	mut main_module := ''
	mut dependencies := []string{}
	for _, mod in prog.modules {
		if mod.is_main {
			main_module = mod.name
			dependencies.prepend(mod.dependencies)
		}
	}
	for req in dependencies.clone() {
		dependencies.prepend(prog.modules[req].dependencies)
	}
	mut arr := []string{}

	for nam in dependencies {
		modl := prog.modules[nam]
		a := modl.name
		if a.len == 0 {
			// try check in core lib
			b := prog.core_modules[nam]

			if b.name.len > 0 {
				// import module
				arr << '@${b.name}'
			} else {
				println(color.fg(color.red, 0, 'COMPILER: Module ${nam} is required and wasn\'t defined in current project'))
				exit(1)
			}
		} else {
			arr << a
		}
	}
	arr << main_module
	if main_module == '' {
		println(color.fg(color.red, 0, "COMPILER: Main module wasn't defined in current project"))
		exit(1)
	}
	return arr
}

fn uniq(arr []string) []string {
	mut new_arr := []string{}
	for el in arr {
		mut in_array := false
		for i := 0; i < new_arr.len; i++ {
			if new_arr[i] == el {
				in_array = true
			}
		}
		if !in_array {
			new_arr << el
		}
	}
	return new_arr
}

fn get_module_name(i int, tok token.Token, tokens []token.Token) (int, string) {
	tk_len := tokens.len
	mut i0 := i
	mut name := []string{}
	if i0 < tk_len && tokens[i0].kind == .modl {
		name << tokens[i0].lit
		i0++
		for tokens[i0].kind == .dot {
			if tokens[i0].kind == .dot {
				i0++
			}
			if tokens[i0].kind == .modl {
				name << tokens[i0].lit
				i0++
			} else {
				break
			}
		}
	}
	return i0, name.join('.')
}

fn get_module_function_name(i int, tok token.Token, tokens []token.Token) (int, string) {
	tk_len := tokens.len
	mut i0 := i
	mut name := []string{}
	if i0 < tk_len && tokens[i0].kind == .modl {
		name << tokens[i0].lit
		i0++
		for j := i0; j < tk_len; j++ {
			if tokens[j].kind == .dot {
				continue
			} else if tokens[j].kind == .modl {
				name << tokens[j].lit
			} else {
				break
			}
			i0++
		}
	}
	return i0, name.join('.')
}
