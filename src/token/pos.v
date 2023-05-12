module token

pub struct Pos {
pub:
	len     int
	line_nr int
	pos     int
	col     int
pub mut:
	last_line int
}
