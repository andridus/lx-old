// Include standard functions
#include <tcclib.h>
#include <string.h>
// MODULE 'Lx.Compiler.FILE'.ex
// -------- --------
typedef struct  {
	placeholder ptr;
	char *path;
} struct_lx_compiler_file;
// MODULE 'Lx.Compiler.Builtin'.ex
// -------- --------
void *Lx_Compiler_Builtin_is_nil(int arity, char *types, ...){
if(arity == 1 && strcmp(types, "1_nil") == 0){
	va_list args;
	va_start(args, types);
	nil nil = va_arg(args, nil);
	va_end(args);
	return {atom, 0, true};
}
if(arity == 1 && strcmp(types, "1_any") == 0){
	va_list args;
	va_start(args, types);
	any _ = va_arg(args, any);
	va_end(args);
	return {atom, 0, false};
}
}
void *Lx_Compiler_Builtin_print(int arity, char *types, ...){
if(arity == 1 && strcmp(types, "1_string") == 0){
	va_list args;
	va_start(args, types);
	char *str = va_arg(args, char *);
	va_end(args);
	return printf("%s\n", str);
}
}
void *Lx_Compiler_Builtin_read_file(int arity, char *types, ...){
if(arity == 1 && strcmp(types, "1_string") == 0){
	va_list args;
	va_start(args, types);
	char *path = va_arg(args, char *);
	va_end(args);
fopen(path, "r")	return if (Lx_Compiler_Builtin_is_nil(1,"1_nil",fptr)) {
;
}
}
}
void *Lx_Compiler_Builtin_close_file(int arity, char *types, ...){
if(arity == 1 && strcmp(types, "1_struct_lx_compiler_file") == 0){
	va_list args;
	va_start(args, types);
	struct_lx_compiler_file file = va_arg(args, struct_lx_compiler_file);
	va_end(args);
close(file)	return if (result==) {
;
}
}
}
// MODULE 'Lx'.ex
// -------- --------
void *Lx_main(int arity, char *types, ...){
if(arity == 0 && strcmp(types, "0_") == 0){
	va_list args;
	va_start(args, types);
	va_end(args);
	return Lx_Compiler_Builtin_print(1,"1_string","Olá Mundo");
}
}
int main(int argc, char *argv[]) {
 Lx_main(0, "0_");
return 0;
}
