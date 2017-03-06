#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <term.h>
#include <curses.h>
#include <termios.h>

int getChoice(const char **);

int main(){
	const char *menus[] = {
		"a-添加",
		"d-删除",
		"q-退出",
		NULL
	};
	int choice = 0;
	struct termios oldTermios, newTermios;
	
	tcgetattr(fileno(stdout), &oldTermios);
	newTermios=oldTermios;
	newTermios.c_lflag &= ~ECHO;
	newTermios.c_lflag &= ~ICANON;
	newTermios.c_cc[VMIN] = 1;
	newTermios.c_cc[VTIME] = 0;
	newTermios.c_lflag &= ~ISIG;
	tcsetattr(fileno(stdout), TCSANOW, &newTermios);

	while(choice != 'q') {
		choice = getChoice(menus);
		printf("你选择了%c\n", choice);
		sleep(1);
	}

	tcsetattr(fileno(stdout), TCSANOW, &oldTermios);

	exit(0);
}

int getChoice(const char **menus) {
	char *clear, *cursor;
	int scrennRow, scrennCol=10;
	const char **option = menus;
	int choice, selected=0;

	setupterm(NULL, fileno(stdout), (int *)0);
	clear = tigetstr((char *)"clear");
	putp(clear);

	cursor = tigetstr((char *)"cup");
	scrennRow = 4;
	putp(tparm(cursor, scrennRow, scrennCol));

	printf("请选择一个菜单:\n");
	while(*option) {
		scrennRow += 2;
		putp(tparm(cursor, scrennRow, scrennCol));
		printf("%s\n", *option++);
	}

	while(!selected) {
		do{
			choice = fgetc(stdin);
		}while(choice == '\n' || choice == '\r');
		option = menus;
		while(*option) {
			if(**option == choice) {
				selected = 1;
				break;
			}
			option ++;
		}
		if(!selected) {
			scrennRow++;
			putp(tparm(cursor, scrennRow, scrennCol));
			printf("请输入正确选项\n");
		}
	}
	putp(clear);

	return choice;
}


