// Include standard functions
type AnyType = Atom | Nil | bool | f64 | int | string

fn (t AnyType) str() string {
	return match t {
		int {
			r := t as int
			'${r}'
		}
		f64 {
			r := t as f64
			'${r}'
		}
		bool {
			r := t as bool
			'${r}'
		}
		string {
			r := t as string
			'${r}'
		}
		else {
			'undefined'
		}
	}
}

fn lx_to_int(value AnyType) int {
	return match value {
		int {
			value
		}
		bool {
			r := value as bool
			if r {
				1
			} else {
				0
			}
		}
		else {
			eprintln('to_int: invalid conversion')
			exit(0)
		}
	}
}

fn lx_to_string(value AnyType) string {
	return match value {
		Atom {
			value.val
		}
		string {
			value
		}
		else {
			eprintln('to_string: invalid conversion')
			exit(0)
		}
	}
}

fn lx_to_f64(value AnyType) int {
	return match value {
		int {
			value
		}
		f64 {
			value
		}
		bool {
			r := value as bool
			if r {
				1
			} else {
				0
			}
		}
		else {
			eprintln('[31m**(RuntimeError::InvalidConversion)[0m to_f64 conversion')
			exit(0)
		}
	}
}

fn lx_match(left AnyType, right AnyType) AnyType {
	if typeof(left).name == typeof(right).name {
		if left == right {
			return left
		} else {
			eprintln('[31m**(RuntimeError::MatchError)[0m The left expression [97m`${left}`[0m doesn`t match with right expression [97m`${right}`[0m !')
			exit(0)
		}
	} else {
		panic('broken')
	}
}

struct Nil {}

struct Atom {
	val string
	ref int
}

fn (a Atom) str() string {
	return ':${a.val}'
}

// MODULE 'PatternMatching'.ex
// -------- --------
fn patternmatching_sum_2_integer_integer(a int, b int) int {
	var_3 := a
	var_4 := b
	tmpvar_5 := var_3 + var_4
	return tmpvar_5
}

fn patternmatching_sub_2_integer_integer(a int, b int) int {
	var_8 := a
	var_9 := b
	tmpvar_10 := var_8 - var_9
	return tmpvar_10
}

fn patternmatching_mul_2_integer_integer(a int, b int) int {
	var_13 := a
	var_14 := b
	tmpvar_15 := var_13 * var_14
	return tmpvar_15
}

fn patternmatching_div_2_integer_integer(a int, b int) int {
	var_18 := a
	var_19 := b
	tmpvar_20 := var_18 / var_19
	return tmpvar_20
}

fn patternmatching_main_0() Atom {
	var_21 := patternmatching_sum_2_integer_integer(1, 2)
	var_22 := patternmatching_sub_2_integer_integer(2, 1)
	var_23 := patternmatching_mul_2_integer_integer(3, 2)
	var_24 := patternmatching_div_2_integer_integer(2, 2)
	println(var_21)
	println(var_22)
	println(var_23)
	println(var_24)
	println('#{a} #{b} #{c} #{d}')
	println('\n')
	println('*****************\n\n')
	_ := lx_to_int(lx_match(3, patternmatching_sum_2_integer_integer(1, 2)))

	_ := lx_to_int(lx_match(1, patternmatching_sub_2_integer_integer(2, 1)))

	_ := lx_to_int(lx_match(6, patternmatching_mul_2_integer_integer(3, 2)))

	_ := lx_to_int(lx_match(4, patternmatching_div_2_integer_integer(8, 2)))

	_ := lx_to_string(lx_match('Hello World', 'Hello Home'))

	tmpvar_25 := Atom{
		val: 'ok'
	}
	return tmpvar_25
}

fn main() {
	result := patternmatching_main_0()
	if typeof(result).name != 'Nil' {
		println(result)
	} else {
		println('nil\n')
	}
}
