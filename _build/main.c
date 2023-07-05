// Include standard functions
#include <stdio.h>
// MODULE 'Lx.IO'.ex
// -------- --------
void Lx_IO_puts(char str[]) {
printf(str);
return 0;
}
// MODULE 'HelloWorld'.ex
// -------- --------
void HelloWorld_main() {
Lx_IO_puts("Olá usando o alias e core\n");
return 0;
}
int main(int argc, char *argv[]) {
 HelloWorld_main();
return 0;
}
