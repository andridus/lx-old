module lexer

fn is_digit(a rune) bool {
	return a >= `0` && a <= `9`
}
