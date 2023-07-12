// Include standard functions
#include <tcclib.h>
#include <string.h>
// MODULE 'Lx'.ex
// -------- --------
void *Lx_main(int arity, char *types, ...){
if(arity == 0 && strcmp(types, "0_") == 0){
	va_list args;
	va_start(args, types);
	va_end(args);
}
}
int main(int argc, char *argv[]) {
 Lx_main(0, "0_");
return 0;
}
