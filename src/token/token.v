module token

pub struct Token {
	pub mut:
	 typ Typ
	 literal string
	 line int
	 pos int
}

pub enum Typ {
	// keywords
	_ignore
	_eof
	_linebreak
	_end
	_and
	_def
	_else
	_false
	_true
	_nil
	_when
	_assign
	_right_double_arrow
	_or_op
	_capture_op
	_bang_op
	_pipe_op
	_plus_op
	_minus_op
	_mult_op
	_div_op
	_range_op
	_concat_op
	_gt_op
	_eq_op
	_neq_op
	_egt_op
	_lt_op
	_elt_op
	_left_arrow
	_right_arrow
	_dot
	_comma
	_type
	_left_parens
	_right_parens
	_left_braces
	_right_braces
	_integer
	_float
	_atom
}