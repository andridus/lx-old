module lexer
import token
pub struct Lexer {
	input string
	pub mut:
		pos int
		total int
		tokens []token.Token
}

pub fn new(input string) Lexer {
	mut l := Lexer {
		input: input
		total: input.len
	}
	for l.pos < l.total {
		l.tokens << l.parse_token()
	}
	l.tokens = l.tokens.filter(it.typ != 'IGNORE')
	return l
}
fn has_next(i int, total int) bool{
	return i < total
}
fn (l Lexer) match_next(u string) bool{
	pos := l.pos + 1
	return has_next(pos, l.total) && u == l.input[pos].ascii_str()
}
fn (l Lexer) match_next_word(u string) bool{
	pos := l.pos + 1
	return has_next(u.len + pos, l.total) && l.input[pos..(pos+u.len)] == u
}
fn (mut l Lexer) parse_token() token.Token {
	u := l.input[l.pos].ascii_str()
	tok := match u {
		'=' {
			if l.match_next('=') { l.new_token('==','OPERATOR', 2) }
			else {l.new_token('=','OPERATOR', 1)}
		}
		'!' {
			if l.match_next('=') { l.new_token('!=','OPERATOR', 1) }
			else {l.new_token('!','OPERATOR', 1)}
		}
		//operators
		'+','-','*','/',',','<','>','.' {
			l.new_token(u,'OPERATOR', 1)
		}
		'(',')' {
			l.new_token(u,'DELIMITER', 1)
		}
		else {
		l.get_token_word(u) or {
			l.get_token_integer(u) or {
				l.new_token(u,'IGNORE',1)
				}
			}
		}
	}
	return tok
}

fn (mut l Lexer) get_token_word(cch string) !token.Token {
	term := l.get_word(cch)
	if term.len > 0  {
		return l.new_token(term, 'ATOM', term.len)
	} else {
		return error("not have a word")
	}
}
fn (mut l Lexer) get_token_integer(cch string) !token.Token {
	term, typ := l.get_number(cch)
	if term.len > 0  {
		return l.new_token(term, typ, term.len)
	} else {
		return error("not have a integer")
	}
}

fn (l Lexer) get_word(cch string) string {
	mut str := ''
	mut current_ch := cch
	mut pos := l.pos + 1
	for is_letter(current_ch) && pos < l.total {
		str += current_ch
		current_ch = l.input[pos].ascii_str()
		pos += 1
	}
	return str
}
fn (mut l Lexer) get_number(cch string) (string, string) {
	mut str := ''
	mut current_ch := cch
	mut pos := l.pos + 1
	mut typ := 'INTEGER'
	for (is_digit(current_ch) && pos < l.total) || (str.len > 0 && current_ch in ['.', '_'] && pos < l.total) {
		if current_ch == '.' { typ = 'FLOAT'}
		str += current_ch
		current_ch = l.input[pos].ascii_str()
		pos += 1
	}
	return str.replace('_',''), typ

}

fn (mut l Lexer) new_token(key string, typ string, forward int) token.Token {
	l.pos += forward
	lookup := token.lookup_keyword(key,typ)
	if lookup == "LINE_BREAK" {
		return token.Token {
			typ: lookup
			literal: ''
		}
	} else {
		return token.Token {
			typ: lookup
			literal: key
		}

	}
}
fn is_letter(a string) bool {
	return (a >= 'a' && a<= 'z') || (a >= 'A' && a <= 'Z') || (a == '_')
}
fn is_digit(a string) bool {
	return (a >= '0' && a<= '9')
}
