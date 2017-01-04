#include <sys/unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

int main() {
	char c;
	int in = open("file.in", O_RDONLY);
	int out = open("file.out", O_WRONLY | O_CREAT | O_TRUNC, S_IRUSR | S_IWUSR);

	while(read(in, &c, 1)==1){
		write(out, &c, 1);
	}
	return 0;
}
