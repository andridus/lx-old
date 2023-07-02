module c

fn stdlib(str string) !string {
	return match str {
		"assert" {"<assert.h>"}
		"complex" {"<complex.h>"}
		"ctype" {"<ctype.h>"}
		"errno" {"<errno.h>"}
		"fenv" {"<fenv.h>"}
		"float" {"<floath.h>"}
		"inttypes" {"<inttypes.h>"}
		"iso646" {"<iso646.h>"}
		"limits" {"<limits.h>"}
		"locale" {"<locale.h>"}
		"math" {"<math.h>"}
		"setjmp" {"<setjmp.h>"}
		"signal" {"<signal.h>"}
		"stdalign" {"<stdalign.h>"}
		"stdarg" {"<stdarg.h>"}
		"stdatomic" {"<stdatomic.h>"}
		"stdbool" {"<stdbool.h>"}
		"stddef" {"<stddef.h>"}
		"stdint" {"<stdint.h>"}
		"stdio" {"<stdio.h>"}
		"stdlib" {"<stdlib.h>"}
		"stdnoreturn" {"<stdnoreturn.h>"}
		"string" {"<string.h>"}
		"tgmath" {"<tgmath.h>"}
		"threads" {"<threads.h>"}
		"time" {"<time.h>"}
		"uchar" {"<uchar.h>"}
		"wchar" {"<wchar.h>"}
		"wctype" {"<wctype.h>"}
		else {
			error("not found stdlib")
		}
	}
}