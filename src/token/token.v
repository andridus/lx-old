// Copyright (c) 2019 Alexander Medvednikov. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.
module token

pub struct Token {
pub:
	kind       Kind
	lit        string
	line_nr    int
	pos        int
	pos_inline int
	value      LiteralValue
}

pub union LiteralValue {
pub:
	sval string
	ival int
	fval f32
}

pub enum Kind {
	// types
	ignore // to ignore token
	eof // end of file
	newline // \n
	ident // name
	atom //  :atom or :'atom'
	sigil // ~s followed by (), {}, [], <>, "", '', ||, //
	list // [1,2,3] ...
	tuple // {x,y}
	integer // 123
	float // 123.12
	str // "my first string"
	str_inter // '#user.name'
	charlist // 'abcd'
	map // %{}
	struct // %MyStruct{}
	// Operators
	typedef // :, ::
	bang // !
	not // !
	plus // +
	minus // -
	mul // *
	div // /
	mod // %
	xor // ^
	pipe // |
	inc // ++
	dec // --
	and // &&
	bit_not // ~
	logical_or // ||
	question // ?
	comma //,
	semicolon //;
	colon //:
	colon_space //:[32]
	arrow // =>
	right_arrow // ->
	left_arrow // <-
	amp // &
	capture // &
	hash // #
	dollar // $
	arrob // @
	assign // =
	// {}  () []
	lcbr
	rcbr
	lpar
	rpar
	lsbr
	rsbr
	// == != <= < >= >
	eq
	seq
	eqt
	ne
	sne
	gt
	lt
	ge
	le
	modl // module 'MyModule'
	// comments
	line_comment // starts by #
	doc // starts by @doc
	moduledoc // starts by moduledoc
	multistring // starts by """
	dot // .
	range // ..
	ellipsis // ...
	plus_concat // ++
	minus_concat // --
	string_concat // <>
	// keywords
	keyword_beging
	key_keyword
	key_and
	key_or
	key_true
	key_false
	key_else
	key_nil
	key_when
	key_not
	key_in
	key_fn
	key_do
	key_end
	key_catch
	key_rescue
	key_after
	// function and definitions
	key_def
	key_defp
	key_defmacro
	key_defmacrop
	key_defmodule
	key_import
	key_defstruct
	key_alias
	key_require
	keyword_endg
}

const (
	token_str = build_token_str()
	keywords  = build_keywords()
)

fn build_keywords() map[string]int {
	mut res := map[string]int{}
	for t := int(Kind.keyword_beging) + 1; t < int(Kind.keyword_endg); t++ {
		key := token.token_str[t]
		res[key] = t
	}
	return res
}

fn build_token_str() []string {
	mut s := []string{len: 98, init: ''}
	s[Kind.ignore] = 'IGNORE'
	s[Kind.eof] = 'EOF'
	s[Kind.newline] = 'NEWLINE'
	s[Kind.ident] = 'ident'
	s[Kind.atom] = 'atom'
	s[Kind.sigil] = 'sigil'
	s[Kind.list] = 'list'
	s[Kind.tuple] = 'tuple'
	s[Kind.integer] = 'integer'
	s[Kind.float] = 'float'
	s[Kind.str] = 'str'
	s[Kind.str_inter] = '#'
	s[Kind.charlist] = 'charlist'
	s[Kind.map] = 'map'
	s[Kind.struct] = 'struct'
	s[Kind.colon] = ':'
	s[Kind.typedef] = ':'
	s[Kind.bang] = '!'
	s[Kind.not] = '!'
	s[Kind.plus] = '+'
	s[Kind.minus] = '-'
	s[Kind.mul] = '*'
	s[Kind.div] = '/'
	s[Kind.mod] = '%'
	s[Kind.xor] = '^'
	s[Kind.pipe] = '|'
	s[Kind.inc] = '++' // ++
	s[Kind.dec] = '--' // --
	s[Kind.and] = '&&' // &&
	s[Kind.bit_not] = '~' // &&
	s[Kind.logical_or] = '||'
	s[Kind.question] = '?'
	s[Kind.comma] = ','
	s[Kind.semicolon] = ';'
	s[Kind.colon] = ':'
	s[Kind.colon_space] = ':s'
	s[Kind.arrow] = '=>' // =>
	s[Kind.right_arrow] = '->' // ->
	s[Kind.left_arrow] = '<-' // <-
	s[Kind.amp] = '&' // <-
	s[Kind.capture] = '&'
	s[Kind.hash] = '#'
	s[Kind.dollar] = '$'
	s[Kind.arrob] = '@'
	s[Kind.assign] = '=' // =
	s[Kind.lcbr] = '{'
	s[Kind.rcbr] = '}'
	s[Kind.lpar] = '('
	s[Kind.rpar] = ')'
	s[Kind.lsbr] = '['
	s[Kind.rsbr] = ']'
	s[Kind.eq] = '=='
	s[Kind.seq] = '==='
	s[Kind.ne] = '!='
	s[Kind.sne] = '!=='
	s[Kind.eqt] = '~='
	s[Kind.gt] = '<'
	s[Kind.lt] = '>'
	s[Kind.ge] = '<='
	s[Kind.le] = '>-'
	s[Kind.modl] = 'module'
	s[Kind.line_comment] = 'comment'
	s[Kind.doc] = 'doc'
	s[Kind.moduledoc] = 'moduledoc'
	s[Kind.multistring] = 'multistring'
	s[Kind.dot] = '.'
	s[Kind.range] = '..'
	s[Kind.ellipsis] = '...'
	s[Kind.plus_concat] = '++'
	s[Kind.minus_concat] = '--'
	s[Kind.string_concat] = '<>'
	s[Kind.keyword_beging] = ''
	s[Kind.key_keyword] = 'keyword'
	s[Kind.key_and] = 'and'
	s[Kind.key_or] = 'or'
	s[Kind.key_true] = 'true'
	s[Kind.key_false] = 'false'
	s[Kind.key_else] = 'else'
	s[Kind.key_nil] = 'nil'
	s[Kind.key_when] = 'when'
	s[Kind.key_not] = 'not'
	s[Kind.key_in] = 'in'
	s[Kind.key_fn] = 'fn'
	s[Kind.key_do] = 'do'
	s[Kind.key_end] = 'end'
	s[Kind.key_catch] = 'catch'
	s[Kind.key_rescue] = 'rescue'
	s[Kind.key_after] = 'after'
	// funcs and defs
	s[Kind.key_def] = 'def'
	s[Kind.key_defp] = 'defp'
	s[Kind.key_defmacro] = 'defmacro'
	s[Kind.key_defmacrop] = 'defmacrop'
	s[Kind.key_defmodule] = 'defmodule'
	s[Kind.key_import] = 'import'
	s[Kind.key_defstruct] = 'defstruct'
	s[Kind.key_alias] = 'alias'
	s[Kind.key_require] = 'require'
	s[Kind.keyword_endg] = ''
	return s
}

pub fn key_to_token(key string) Kind {
	kind := token.keywords[key] or { 3 }
	a := unsafe { Kind(kind) }
	return a
}

pub fn is_key(key string) bool {
	return int(key_to_token(key)) > 0
}

pub fn is_decl(t Kind) bool {
	return t in [.key_def, .key_defp, .key_defstruct, .key_alias, .key_import, .key_require,
		.key_defmodule, .eof]
}

pub fn (t Kind) is_assign() bool {
	return t == .assign
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
	return match t {
		.integer {
			'integer'
		}
		.float {
			'float'
		}
		.charlist {
			'charlist'
		}
		.str {
			'string'
		}
		.atom {
			'atom'
		}
		.list {
			'list'
		}
		.map {
			'map'
		}
		.tuple {
			'tuple'
		}
		.struct {
			'struct'
		}
		else {
			token.token_str[int(t)]
		}
	}
}

pub fn (t Token) str() string {
	return '[${t.kind.str()}] "${t.lit}"'
}

pub const (
	lowest_prec  = 0
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
	p[Kind.assign] = .assign
	p[Kind.eq] = .eq
	p[Kind.ne] = .eq
	p[Kind.lt] = .less_greater
	p[Kind.gt] = .less_greater
	p[Kind.le] = .less_greater
	p[Kind.ge] = .less_greater
	p[Kind.plus] = .sum
	p[Kind.minus] = .sum
	p[Kind.div] = .product
	p[Kind.mul] = .product
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
)

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
		.mul, .div, .amp {
			return 6
		}
		// `+` |  `-` |  `|` | `^`
		.plus, .minus {
			return 5
		}
		// `==` | `!=` | `<` | `<=` | `>` | `>=`
		.eq, .ne, .lt, .le, .gt, .ge {
			return 4
		}
		// `&&`
		.and, .key_and {
			return 3
		}
		// `||`
		.logical_or, .assign {
			return 2
		}
		else {
			return token.lowest_prec
		}
	}
}

pub fn (tok Token) is_scalar() bool {
	return tok.kind in [.integer, .float, .str]
}

pub fn (tok Token) is_unary() bool {
	return tok.kind in [
		// `+` | `-` | `!` |  `*` | `&`
		Kind.plus,
		Kind.minus,
		Kind.not,
		Kind.mul,
		Kind.amp,
		Kind.key_not,
		Kind.arrob,
		Kind.xor,
	]
}

pub fn (tok Token) is_left_assoc() bool {
	return tok.kind in [
		// .
		Kind.dot,
		// **
		// * /
		Kind.mul,
		Kind.div,
		// + -
		Kind.plus,
		Kind.minus,
		// in not
		Kind.key_in,
		Kind.key_not,
		// |> <<< >>> <<~ ~>> <~ ~> <~>
		// < > <= >=
		Kind.lt,
		Kind.le,
		Kind.gt,
		Kind.ge,
		// == != =~ === !==
		Kind.eq,
		Kind.ne,
		Kind.eqt,
		Kind.seq,
		Kind.sne,
		// && &&& and
		// || ||| or
		// <- \\
	]
}

pub fn (tok Token) is_right_assoc() bool {
	return false // tok.kind in [
	// ++ -- +++ --- .. <>
	// =
	// => (only inside %{})
	// ::
	// when
	//	]
}

pub fn (tok Kind) is_relational() bool {
	return tok in [
		.lt,
		.le,
		.gt,
		.ge,
		.eq,
		.ne,
	]
}

pub fn (kind Kind) is_infix() bool {
	return kind in [.plus, .minus, .mod, .mul, .div, .eq, .ne, .gt, .lt, .ge, .le, .logical_or,
		.and, .dot, .key_in, .key_and, .key_or]
}
