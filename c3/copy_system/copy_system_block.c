#include <sys/unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

int main() {
	char c[1024];
	int in = open("file.in", O_RDONLY);
	int out = open("file.out", O_WRONLY | O_CREAT | O_TRUNC, S_IRUSR | S_IWUSR);
	int nread;

	while((nread = read(in, &c, sizeof(c)))>0){
		write(out, &c, nread);
	}
	return 0;
 }
