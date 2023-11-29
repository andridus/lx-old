module lexer

fn test_is_digit() {
	digit := `1`
	assert true == is_digit(digit)
}

fn test_is_digit_for_all() {
	digits := [`1`, `2`, `3`, `4`, `5`, `6`, `7`, `8`, `9`, `0`]
	for d in digits {
		assert true == is_digit(d)
	}
}

fn test_not_is_digit() {
	digit := `a`
	assert false == is_digit(digit)
}
