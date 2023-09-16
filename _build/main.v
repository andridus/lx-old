pub struct Underscore {}
pub struct Nil {}
pub struct Atom {
			val string
			ref int
		}
pub type AnyType = int | string | bool | f64 | Atom | Nil | Underscore

pub fn (t AnyType) str() string {
	return match t {
		int {
			r := t as int
			'$r'
		}
		f64 {
			r := t as f64
			'$r'
		}
		bool {
			r := t as bool
			'$r'
		}
		string {
			r := t as string
			'$r'
		}
		else {
			'undefined'
		}
	}
}

pub fn (a Atom) str() string { return ':${a.val}' }

pub fn do_match(left AnyType, right AnyType) AnyType {
	if typeof(left).name == typeof(right).name {
		if left == right {
			return left
		} else {
				eprintln('\033[31m**(RuntimeError::MatchError)\033[0m The left expression \033[97m`\$left`\033[0m doesn`t match with right expression \033[97m`\$right`\033[0m !')
				exit(0)
				}
	} else {
		panic('broken')
	}
}

pub fn is_match(left AnyType, right AnyType) bool {
	if typeof(left).name == typeof(right).name {
		if left == right {
			return true
		}
	}
	return false
}

pub fn any_to_string(value AnyType) string {
	return match value {
		Atom { value.val }
		string { value }
		else {
			eprintln("to_string: invalid conversion")
			exit(0)
		}
	}
}

pub fn any_to_int(value AnyType) int {
	return match value {
		int { value}
		f64 { value}
		bool {
			r := value as bool
			if r { 1 } else { 0 }
		}
		else {
			eprintln("\033[31m**(RuntimeError::InvalidConversion)\033[0m to_f64 conversion")
			exit(0)
		}
	}
}
// MODULE 'HelloWorld'.ex
// -------- --------
fn helloworld_main_0() string {
tmpvar_1 := "Hello World"
	return tmpvar_1

}
fn main(){
result := helloworld_main_0()
if typeof(result).name != 'Nil' {
print(result)
}else{
print("nil\n")
}
}
