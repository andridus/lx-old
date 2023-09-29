// Copyright (c) 2023 Helder de Sousa. All rights reserved/
// Use of this source code is governed by a MIT license
// that can be found in the LICENSE file
module lexer

fn is_letter(a u8) bool {
	return (a >= `a` && a <= `z`) || (a >= `A` && a <= `Z`) || a == `_`
}

fn is_alpha(a u8) bool {
	return is_digit(a) || (a >= `a` && a <= `z`) || is_capital(a) || a == `_`
}

fn is_capital(a u8) bool {
	return a >= `A` && a <= `Z`
}

fn is_digit(a rune) bool {
	return a >= `0` && a <= `9`
}
