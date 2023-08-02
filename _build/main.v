// Include standard functions
type AnyType = int | string | Atom | Nil
fn (t AnyType) str() string {
		return match t {
			int {
				r := t as int
				'$r'
			}
			else {
				'undefined'
			}
		}
	}
fn lx_to_int(value AnyType) int {
		return match value {
			int { value}
			else {
				eprintln("to_int: invalid conversion")
				exit(0)
			}
		}
	}

	fn lx_match(left AnyType, right AnyType) AnyType {
		if typeof(left).name == typeof(right).name {
			if left == right {
				return left
			} else {
				 panic(' $left = $right don`t match  broken')
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
fn (a Atom) str() string { return ':${a.val}' }
// MODULE 'Strings'.ex
// -------- --------
fn strings_main_0() string {
// "Hello Lx"
// "Hello\n    Lx"
// "👩‍💻 こんにちは Lx 💫"
// "\n      Multiline String\n      Other Line\n      And other line\n"
["name:","Fulano"].join('')
var_1 := "Fulano"
tmpvar_2 := ["Hello,",var_1,"!"].join('')
	return tmpvar_2

}
fn main(){
result := strings_main_0()
if typeof(result).name != 'Nil' {
println(result)
}else{
println("nil\n")
}
}
