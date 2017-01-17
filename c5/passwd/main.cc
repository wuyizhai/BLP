#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include "user.h"

int main(){
	User *user = new User("xxs", "123456");
	printf("%s", user->ToString());
	exit(0);
}
