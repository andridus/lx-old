module token

pub struct Token {
	pub mut:
	 typ string
	 literal string
}

pub const (
	keywords     = {
		'0': 'IGNORE'
		'*': 'ASTERISK'
		'+': 'PLUS'
		'-': 'MINUS'
		'.': 'DOT'
		',': 'COMMA'
		'!': 'BANG'
		'/': 'SLASH'
		'<': 'LT'
		'=': 'ASSIGN'
		'>': 'GT'
		'\n': 'LINE_BREAK'
		'def': 'DEF'
		'true': 'TRUE'
		'false': 'FALSE'
		'if': 'IF'
		'else': 'ELSE'
		'do': 'DO'
		'end': 'END'
		'return': 'RETURN'
		'atom': 'ATOM'
		'nil': 'NIL'
		'error': 'ERROR'
		'illegal': 'ILLEGAL'
		'eof': 'EOF'
	}
)

pub fn lookup_keyword(keyword_ string, df string) string {
	if keyword_ in keywords {
		return keywords[keyword_]
	}
	return df
}