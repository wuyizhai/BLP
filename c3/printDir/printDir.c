#include <unistd.h>
#include <stdio.h>
#include <sys/types.h>
#include <dirent.h>
#include <sys/stat.h>
#include <string.h>
#include <stdlib.h>
#include <errno.h>

void printDir(const char *dir, int depth) {
	DIR* d;
	struct dirent *entry;
	struct stat *buff = new struct stat[1];

	if((d=opendir(dir))==NULL) {
		fprintf(stderr, "%s", strerror(errno));
		fprintf(stderr, "打开目录%s失败\n", dir);
		return;
	}

	chdir(dir);
	while((entry = readdir(d))!=NULL){
		lstat(entry->d_name, buff);
		if(S_ISDIR(buff->st_mode)) {
			if(strcmp(".", entry->d_name) == 0 || strcmp("..", entry->d_name) == 0) {
				continue;
			}
			printf("%*s-%s\n",depth*4," ",entry->d_name);
			printDir(entry->d_name, depth+1);
		}
		else {
			printf("%*s%s\n",depth*4," ",entry->d_name);
		}
	}
	chdir("..");
	closedir(d);
}

int main(int argc, char **argv){
	char dir[255];
	char *pdir = dir;
	getcwd(dir, sizeof(dir));
	if(argc >= 2) {
		pdir = argv[1];
	}
	printf("扫描目录：%s\n", pdir);
	printDir(pdir, 0);
	exit(0);
}
