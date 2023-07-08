// Include standard functions
#include <tcclib.h>
#include <string.h>
// MODULE 'Lx.IO'.ex
// -------- --------
void *Lx_IO_puts(int arity, char *types, ...){
if(arity == 1 && strcmp(types, "1_int") == 0){
	va_list args;
	va_start(args, types);
	int a = va_arg(args, int);
	va_end(args);
printf("%d\n", a);
	return NULL;
}
if(arity == 1 && strcmp(types, "1_f32") == 0){
	va_list args;
	va_start(args, types);
	double a = va_arg(args, double);
	va_end(args);
printf("%f\n", a);
	return NULL;
}
if(arity == 1 && strcmp(types, "1_string") == 0){
	va_list args;
	va_start(args, types);
	char *a = va_arg(args, char *);
	va_end(args);
printf("%s\n", a);
	return NULL;
}
if(arity == 0 && strcmp(types, "0_") == 0){
	va_list args;
	va_start(args, types);
	va_end(args);
printf("now\n");
	return NULL;
}
}
// MODULE 'Person'.ex
// -------- --------
typedef struct  {
	char *name;
	int age;
} struct_Person;
void *Person_main(int arity, char *types, ...){
if(arity == 0 && strcmp(types, "0_") == 0){
	va_list args;
	va_start(args, types);
	va_end(args);
	struct_Person b;
	b.name = "Person 1"; 
	b.age = 15; 
Lx_IO_puts(1,"1_string","\n----- start of test ----- \n");
Lx_IO_puts(1,"1_int",15);
Lx_IO_puts(1,"1_f32",18.8);
Lx_IO_puts(1,"1_int",25);
Lx_IO_puts(1,"1_string","Minha String");
Lx_IO_puts(1,"1_string","Person 1");
Lx_IO_puts(0,"0_");
Lx_IO_puts(1,"1_string","\n----- end of test ----- \n");
	return NULL;
}
}
int main(int argc, char *argv[]) {
 Person_main(0, "0_");
return 0;
}
