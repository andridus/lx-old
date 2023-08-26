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

// MODULE 'CaseAndGuards'.ex
// -------- --------
fn caseandguards_is_number_1_integer(x int) Nil {
	var_2 := x
	_ := true
	return Nil{}
}

fn caseandguards_main_0() Atom {
	var_3 := 1
	var_4 := 1
	var_5 := 1
	var_6 := 1
	var_7 := 1
	var_8 := 1
	var_9 := 1
	var_10 := 1
	var_11 := 1
	var_12 := 1
	tmpvar_13 := Atom{
		val: 'ok'
	}
	return tmpvar_13
}

fn main() {
	result := caseandguards_main_0()
	if typeof(result).name != 'Nil' {
		println(result)
	} else {
		println('nil\n')
	}
}
