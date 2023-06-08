module color

pub const (
	prefix       = '\033['
	suffix       = 'm'
	reset        = '\033[0m'
	default      = 39
	black        = 30
	dark_red     = 31
	dark_green   = 32
	dark_yellow  = 33
	dark_blue    = 34
	dark_magenta = 35
	dark_cyan    = 36
	dark_gray    = 90
	light_gray   = 37
	red          = 91
	green        = 92
	orange       = 93
	blue         = 94
	magenta      = 95
	cyan         = 96
	white        = 97
)

pub fn fg(c int, text string) string {
	return '${color.prefix}${c}${color.suffix}${text}${color.reset}'
}
