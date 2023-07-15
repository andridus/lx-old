// Include standard functions
#include <tcclib.h>
#include <string.h>
// MODULE 'Lx.Compiler.FILE'.ex
// -------- --------
typedef struct  {
	void * ptr;
	char *path;
} struct_lx_compiler_file;
// MODULE 'Lx.Compiler.Builtin'.ex
// -------- --------
void *Lx_Compiler_Builtin_is_nil(int arity, char *types, ...){
if(arity == 1 && strcmp(types, "1_nil") == 0){
	va_list args;
	va_start(args, types);
	void * nil = va_arg(args, void *);
	va_end(args);
	int *__return__;
	*__return__ = 1;
	return __return__;
}
if(arity == 1 && strcmp(types, "1_any") == 0){
	va_list args;
	va_start(args, types);
	void * _ = va_arg(args, void *);
	va_end(args);
	int *__return__;
	*__return__ = 0;
	return __return__;
}
}
void *Lx_Compiler_Builtin_print(int arity, char *types, ...){
if(arity == 1 && strcmp(types, "1_string") == 0){
	va_list args;
	va_start(args, types);
	char *str = va_arg(args, char *);
	va_end(args);
printf("%s\n", str);
	return NULL;
}
}
void *Lx_Compiler_Builtin_read_file(int arity, char *types, ...){
if(arity == 1 && strcmp(types, "1_string") == 0){
	va_list args;
	va_start(args, types);
	char *path = va_arg(args, char *);
	va_end(args);
void * fptr;
fptr = fopen(path, "r");
if (	Lx_Compiler_Builtin_is_nil(1,"1_nil",fptr)) {
"tuple";
}
 else {
"tuple";
}
	return NULL;
}
}
void *Lx_Compiler_Builtin_close_file(int arity, char *types, ...){
if(arity == 1 && strcmp(types, "1_struct_lx_compiler_file") == 0){
	va_list args;
	va_start(args, types);
	struct_lx_compiler_file file = va_arg(args, struct_lx_compiler_file);
	va_end(args);
int result;
result = fclose(file.ptr);
if (result==NULL) {
"tuple";
}
 else {
"tuple";
}
	return NULL;
}
}
// MODULE 'Lx'.ex
// -------- --------
void *Lx_main(int arity, char *types, ...){
if(arity == 0 && strcmp(types, "0_") == 0){
	va_list args;
	va_start(args, types);
	va_end(args);
;
if (1) {
	Lx_Compiler_Builtin_print(1,"1_string","Olá Mundo");
}
 else {
	Lx_Compiler_Builtin_print(1,"1_string","Oh No!");
}
	return NULL;
}
}
int main(int argc, char *argv[]) {
 Lx_main(0, "0_");
return 0;
}
