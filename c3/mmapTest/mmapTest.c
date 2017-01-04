#include <unistd.h>
#include <stdio.h>
#include <sys/stat.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <sys/types.h>

typedef struct {
	int id;
	char name[10];
} RECORD;

#define NRECORDS (100)

int main() {
	RECORD record, *maps;
	int f;
	FILE *fd;
	const char *path = "record.dat";

	fd = fopen(path, "w+");
	for(int i=0;i<NRECORDS; ++i) {
		record.id=i;
		sprintf(record.name, "record_%d", i);
		fwrite(&record, sizeof(record), 1, fd);
	}
	fclose(fd);

	//使用fseek定位并修改记录
	fd = fopen(path, "r+");
	fseek(fd, 50*sizeof(record), SEEK_SET);
	fread(&record, sizeof(record), 1, fd);
	record.id = 101;
	sprintf(record.name, "record_%d", record.id);
	fseek(fd, 50*sizeof(record), SEEK_SET);
	fwrite(&record, sizeof(record), 1, fd);
	
	//使用mmap修改记录
	f = open(path, O_RDWR);
	maps = (RECORD *)mmap(0, NRECORDS*sizeof(record), PROT_READ | PROT_WRITE, MAP_SHARED, f, 0);
	maps[60].id=102;
	sprintf(maps[60].name, "record_%d", maps[60].id);
	msync(&maps[60], sizeof(record), MS_ASYNC);
	munmap(maps, NRECORDS*sizeof(record));
	close(f);

	exit(0);
}
