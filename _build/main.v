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

// MODULE 'C'.ex
// -------- --------
fn c_sum_0() int {
	tmpvar_1 := 1
	return tmpvar_1
}

// MODULE 'B'.ex
// -------- --------
fn b_one_0() f64 {
	_ := c_sum_0()
	tmpvar_2 := 2.0
	return tmpvar_2
}

// MODULE 'A'.ex
// -------- --------
fn a_main_0() Atom {
	_ := b_one_0()
	tmpvar_3 := Atom{
		val: 'ok'
	}
	return tmpvar_3
}

fn a_other_0() int {
	tmpvar_4 := c_sum_0()
	return tmpvar_4
}

fn main() {
	result := a_main_0()
	if typeof(result).name != 'Nil' {
		println(result)
	} else {
		println('nil\n')
	}
}
