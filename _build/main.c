// Include standard functions
#include <stdio.h>

// MODULE 'IO'.ex
// -------- --------
atom IO_puts(Str) {
return {var, 0, 'C_extern.stdio.printf(str)'};
}
// MODULE 'HelloWorld'.ex
// -------- --------
atom HelloWorld_main() {
return IO_puts("Olá Mundo");
}
int main(int argc, char *argv[]) {
 HelloWorld_main();
return 0;
}
