// Include standard functions
#include <stdio.h>

// MODULE 'IO'.ex
// -------- --------
void IO_puts(Str) {
return _c_.stdio_printf([37, 46, 42, 115, 92, 110], 1, {var, 0, 'Str'});
}
// MODULE 'HelloWorld'.ex
// -------- --------
void HelloWorld_main() {
return IO_puts("Olá Mundo");
}
int main(int argc, char *argv[]) {
 HelloWorld_main();
return 0;
}
