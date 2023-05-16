// Copyright (c) 2019 Alexander Medvednikov. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.
module token

pub struct Token {
pub:
	kind    Kind // the token number/enum; for quick comparisons
	lit     string // literal representation of the token
	line_nr int // the line number in the source where the token occured
	// name_idx int // name table index for O(1) lookup
	pos      int // the position of the token in scanner text
	value LiteralValue
}
pub union LiteralValue {
	pub:
		sval string
		ival int
		fval f32
	}

pub enum Kind {
	eof
	atom
	sigil
	list
	tuple


	ignore
	integer
	float
	typedef // :, ::
	name // user
	number // 123
	newline
	str // 'foo'
	str_inter // 'name=$user.name'
	chartoken // `A`
	bang
	plus
	minus
	mul
	div
	mod
	xor // ^
	pipe // |
	inc // ++
	dec // --
	and // &&
	logical_or
	not
	bit_not
	question
	comma
	semicolon
	colon
	arrow // =>
	right_arrow // ->
	left_arrow // <-
	amp
	hash
	dollar
	capture
	str_dollar
	left_shift
	righ_shift
	arrob // @
	assign // =
	decl_assign // :=
	plus_assign // +=
	minus_assign // -=
	div_assign
	mult_assign
	xor_assign
	mod_assign
	or_assign
	and_assign
	righ_shift_assign
	left_shift_assign
	// {}  () []
	lcbr
	rcbr
	lpar
	rpar
	lsbr
	rsbr
	// == != <= < >= >
	eq
	ne
	gt
	lt
	ge
	le
	modl
	// comments
	line_comment
	doc
	multistring
	moduledoc
	mline_comment
	nl
	dot
	dotdot
	range
	ellipsis
	plus_concat
	minus_concat
	string_concat
	// keywords
	keyword_beging
	key_def
	key_defmodule
	key_do
	key_end
	key_else
	key_false
	key_true
	key_when
	key_nil
	key_as
	key_asm
	key_assert
	key_atomic
	key_break
	key_const
	key_continue
	key_defer
	key_embed
	key_enum
	key_for
	key_fn
	key_global
	key_go
	key_goto
	key_if
	key_import
	key_import_const
	key_in
	key_interface
	// key_it
	key_match
	key_module
	key_mut
	key_none
	key_return
	key_select
	key_sizeof
	key_offsetof
	key_struct
	key_switch
	key_type
	// typeof
	key_orelse
	key_union
	key_pub
	key_static
	key_unsafe
	keyword_endg
}

const (
	assign_tokens = [Kind.assign, .plus_assign, .minus_assign, .mult_assign,
	.div_assign, .xor_assign, .mod_assign, .or_assign, .and_assign,
	.righ_shift_assign, .left_shift_assign]
	nr_tokens = 129
	token_str = build_token_str()
	keywords = build_keys()
)
// build_keys genereates a map with keywords' string values:
// Keywords['return'] == .key_return
fn build_keys() map[string]int {
	mut res := map[string]int{}
	 for t := int(Kind.keyword_beging) + 1; t < int(Kind.keyword_endg); t++ {
	 	key := token_str[t]
		res[key] = t
	 }
	return res
}

// TODO remove once we have `enum Kind { name('name') if('if') ... }`
 fn build_token_str() []string {
	mut s := []string{len: 129, init: ''}
	s[Kind.eof] = 'EOF'
	s[Kind.ignore] = 'IGNORE'
	s[Kind.integer] = 'integer'
	s[Kind.float] = 'float'
	s[Kind.atom] = 'atom'
	s[Kind.list] = 'list'
	s[Kind.tuple] = 'tuple'
	s[Kind.sigil] = 'sigil'
	s[Kind.typedef] = ':' // :, ::
	s[Kind.name] = 'name' // user
	s[Kind.number] = 'number' // 123
	s[Kind.newline] = 'NEWLINE'
	s[Kind.str] = 'str' // 'foo'
	s[Kind.str_inter] = '$' // 'name=$user.name'
	s[Kind.chartoken] = 'A' // `A`
	s[Kind.bang] = '!'
	s[Kind.plus] = '+'
	s[Kind.minus] = '-'
	s[Kind.mul] = '*'
	s[Kind.div] = '/'
	s[Kind.mod] = '%'
	s[Kind.xor] = '^' // ^
	s[Kind.pipe] = '|' // |
	s[Kind.inc] = '++' // ++
	s[Kind.dec] = '--' // --
	s[Kind.and] = '&&' // &&
	s[Kind.logical_or] = '||'
	s[Kind.not] = '!'
	s[Kind.bit_not] = ''
	s[Kind.question] = '?'
	s[Kind.comma] = ','
	s[Kind.semicolon] = ';'
	s[Kind.colon] = ':'
	s[Kind.arrow] = '=>' // =>
	s[Kind.right_arrow] = '->' // ->
	s[Kind.left_arrow] = '<-' // <-
	s[Kind.amp] = '&'
	s[Kind.arrob] = '@'
	s[Kind.hash] = '#'
	s[Kind.dollar] = '$'
	s[Kind.capture] = '&'
	s[Kind.str_dollar] = '$'
	s[Kind.left_shift] = ''
	s[Kind.righ_shift] = ''
	s[Kind.assign] = '=' // =
	s[Kind.decl_assign] = ':=' // :=
	s[Kind.plus_assign] = '+=' // +=
	s[Kind.minus_assign] = '-=' // -=
	s[Kind.div_assign] = '/='
	s[Kind.mult_assign] = '*='
	s[Kind.xor_assign] = '^='
	s[Kind.mod_assign] = '%='
	s[Kind.or_assign] = '||='
	s[Kind.and_assign] = '&&='
	s[Kind.righ_shift_assign] = '>>='
	s[Kind.left_shift_assign] = '<<='
	s[Kind.lcbr] = '{'
	s[Kind.rcbr] = '}'
	s[Kind.lpar] = '('
	s[Kind.rpar] = ')'
	s[Kind.lsbr] = '['
	s[Kind.rsbr] = ']'
	s[Kind.eq] = '=='
	s[Kind.ne] = '!='
	s[Kind.gt] = '<'
	s[Kind.lt] = '>'
	s[Kind.ge] = '<='
	s[Kind.le] = '>-'
	s[Kind.line_comment] = 'comment'
	s[Kind.modl] = 'module'
	s[Kind.doc] = 'doc'
	s[Kind.moduledoc] = 'moduledoc'
	s[Kind.multistring] = 'multistring'
	s[Kind.mline_comment] = ''
	s[Kind.nl] = 'nl'
	s[Kind.dot] = 'dot'
	s[Kind.dotdot] = 'dotdot'
	s[Kind.range] = 'range'
	s[Kind.ellipsis] = 'ellipsis'
	s[Kind.plus_concat] = 'plus_concat'
	s[Kind.minus_concat] = 'minus_concat'
	s[Kind.string_concat] = 'string_concat'
	s[Kind.keyword_beging] = ''
	s[Kind.key_def] = 'def'
	s[Kind.key_defmodule] = 'defmodule'
	s[Kind.key_do] = 'do'
	s[Kind.key_end] = 'end'
	s[Kind.key_else] = 'else'
	s[Kind.key_false] = 'false'
	s[Kind.key_true] = 'true'
	s[Kind.key_when] = 'when'
	s[Kind.key_nil] = 'nil'
	s[Kind.key_as] = 'as'
	s[Kind.key_asm] = 'asm'
	s[Kind.key_assert] = 'assert'
	s[Kind.key_atomic] = 'atomic'
	s[Kind.key_break] = 'break'
	s[Kind.key_const] = 'const'
	s[Kind.key_continue] = 'continue'
	s[Kind.key_defer] = 'defer'
	s[Kind.key_embed] = 'embed'
	s[Kind.key_enum] = 'enum'
	s[Kind.key_for] = 'for'
	s[Kind.key_fn] = 'fn'
	s[Kind.key_global] = 'global'
	s[Kind.key_go] = 'go'
	s[Kind.key_goto] = 'goto'
	s[Kind.key_if] = 'if'
	s[Kind.key_import] = 'import'
	s[Kind.key_import_const] = 'import_const'
	s[Kind.key_in] = 'in'
	s[Kind.key_interface] = 'interface'
	s[Kind.key_match] = 'match'
	s[Kind.key_module] = 'module'
	s[Kind.key_mut] = 'mut'
	s[Kind.key_none] = 'none'
	s[Kind.key_return] = 'return'
	s[Kind.key_select] = 'select'
	s[Kind.key_sizeof] = 'sizeof'
	s[Kind.key_offsetof] = 'offsetof'
	s[Kind.key_struct] = 'struct'
	s[Kind.key_switch] = 'switch'
	s[Kind.key_type] = 'type'
	s[Kind.key_orelse] = 'orelse'
	s[Kind.key_union] = 'union'
	s[Kind.key_pub] = 'pub'
	s[Kind.key_static] = 'static'
	s[Kind.key_unsafe] = 'unsafe'
	s[Kind.keyword_endg] = ''
	return s
}



pub fn key_to_token(key string) Kind {
	kind := keywords[key] or { 1}
	a := unsafe { Kind(kind) }
	return a
}

pub fn is_key(key string) bool {
	return int(key_to_token(key)) > 0
}

pub fn is_decl(t Kind) bool {
	return t in [.key_enum, .key_interface, .key_fn, .key_struct, .key_type, .key_const, .key_import_const, .key_pub, .eof]
}

pub fn (t Kind) is_assign() bool {
	return t in assign_tokens
}

fn (t []Kind) contains(val Kind) bool {
	for tt in t {
		if tt == val {
			return true
		}
	}
	return false
}

pub fn (t Kind) str() string {
	if t == .number {
		return 'number'
	}
	if t == .chartoken {
		return 'char' // '`lit`'
	}
	if t == .str {
		return 'str' // "'lit'"
	}
	/*
	if t < .plus {
		return lit // string, number etc
	}
	*/

	return token_str[int(t)]
}

pub fn (t Token) str() string {
	return '[$t.kind.str()] "$t.lit"'
}

// Representation of highest and lowest precedence
pub const (
	lowest_prec = 0
	highest_prec = 8
)

pub enum Precedence {
	lowest
	cond // OR or AND
	assign // =
	eq // == or !=
	less_greater // > or <
	sum // + or -
	product // * or /
	mod // %
	prefix // -X or !X
	call // func(X) or foo.method(X)
	index // array[index], map[key]
}

pub fn build_precedences() []Precedence {
	mut p := []Precedence{len: 100}
	// p = make(100, 100, sizeof(Precedence))
	p[Kind.assign] = .assign
	p[Kind.eq] = .eq
	p[Kind.ne] = .eq
	p[Kind.lt] = .less_greater
	p[Kind.gt] = .less_greater
	p[Kind.le] = .less_greater
	p[Kind.ge] = .less_greater
	p[Kind.plus] = .sum
	p[Kind.plus_assign] = .sum
	p[Kind.minus] = .sum
	p[Kind.minus_assign] = .sum
	p[Kind.div] = .product
	p[Kind.div_assign] = .product
	p[Kind.mul] = .product
	p[Kind.mult_assign] = .product
	p[Kind.mod] = .mod
	p[Kind.and] = .cond
	p[Kind.logical_or] = .cond
	p[Kind.lpar] = .call
	p[Kind.dot] = .call
	p[Kind.lsbr] = .index
	return p
}

const (
	precedences = build_precedences()
	// int(Kind.assign): Precedence.assign
	// }
)
// precedence returns a tokens precedence if defined, otherwise lowest_prec
pub fn (tok Token) precedence() int {
	match tok.kind {
		.lsbr {
			return 9
		}
		.dot {
			return 8
		}
		// `++` | `--`
		.inc, .dec {
			// return 0
			return 7
		}
		// `*` |  `/` | `%` | `<<` | `>>` | `&`
		.mul, .div, .left_shift, .righ_shift, .amp {
			return 6
		}
		// `+` |  `-` |  `|` | `^`
		.plus, .minus, .pipe, .xor {
			return 5
		}
		// `==` | `!=` | `<` | `<=` | `>` | `>=`
		.eq, .ne, .lt, .le, .gt, .ge {
			return 4
		}
		// `&&`
		.and {
			return 3
		}
		// `||`
		.logical_or, .assign, .plus_assign, .minus_assign, .div_assign, .mult_assign {
			return 2
		}
		// /.plus_assign {
		// /return 2
		// /}
		else {
			return lowest_prec
		}
	}
}

// is_scalar returns true if the token is a scalar
pub fn (tok Token) is_scalar() bool {
	return tok.kind in [.number, .str]
}

// is_unary returns true if the token can be in a unary expression
pub fn (tok Token) is_unary() bool {
	return tok.kind in [
	// `+` | `-` | `!` | `~` | `*` | `&`
	.plus, .minus, .not, .bit_not, .mul, .amp]
}

// NOTE: do we need this for all tokens (is_left_assoc / is_right_assoc),
// or only ones with the same precedence?
// is_left_assoc returns true if the token is left associative
pub fn (tok Token) is_left_assoc() bool {
	return tok.kind in [
	// `.`
	.dot,
	// `+` | `-`
	.plus, .minus, // additive
	// .number,
	// `++` | `--`
	.inc, .dec,
	// `*` | `/` | `%`
	.mul, .div, .mod,
	// `^` | `||` | `&`
	.xor, .logical_or, .and,
	// `==` | `!=`
	.eq, .ne,
	// `<` | `<=` | `>` | `>=`
	.lt, .le, .gt, .ge, .ne, .eq,
	// `,`
	.comma]
}

// is_right_assoc returns true if the token is right associative
pub fn (tok Token) is_right_assoc() bool {
	return tok.kind in [
	// `+` | `-` | `!`
	.plus, .minus, .not, // unary
	// `=` | `+=` | `-=` | `*=` | `/=`
	.assign, .plus_assign, .minus_assign, .mult_assign, .div_assign,
	// `%=` | `>>=` | `<<=`
	.mod_assign, .righ_shift_assign, .left_shift_assign,
	// `&=` | `^=` | `|=`
	.and_assign, .xor_assign, .or_assign]
}

pub fn (tok Kind) is_relational() bool {
	return tok in [
	// `<` | `<=` | `>` | `>=`
	.lt, .le, .gt, .ge, .eq, .ne]
}

pub fn (kind Kind) is_infix() bool {
	return kind in [.plus, .minus, .mod, .mul, .div, .eq, .ne, .gt, .lt, .ge, .le, .logical_or, .and, .dot]
}
