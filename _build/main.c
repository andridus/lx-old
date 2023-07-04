// Include standard functions
#include <stdio.h>
// MODULE 'LxCore.IO'.ex
// -------- --------
void LxCore_IO_puts(char str[]) {
printf(str);
return 0;
}
// MODULE 'HelloWorld'.ex
// -------- --------
void HelloWorld_main() {
LxCore_IO_puts("Olá usando o core\n");
return 0;
}
int main(int argc, char *argv[]) {
 HelloWorld_main();
return 0;
}
