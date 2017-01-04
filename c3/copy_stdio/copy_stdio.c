#include <stdio.h>

int main(){
	char buff[1024];
	FILE *in = fopen("file.in","r");
	FILE *out = fopen("file.out","w");

	while(fread(buff,sizeof(buff),1,in)>=1) {
		fwrite(buff,sizeof(buff),1,out);
	}
}
