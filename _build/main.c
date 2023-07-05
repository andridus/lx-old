// Include standard functions
// MODULE 'Person'.ex
// -------- --------
typedef struct  {
	char name;
	int age;
} Person;
Person Person_main() {
	Person b;
	b.name = "Rich Man"; 
	return b; 
}
int main(int argc, char *argv[]) {
 Person_main();
return 0;
}
