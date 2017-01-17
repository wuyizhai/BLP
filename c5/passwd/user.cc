#include <unistd.h>
#include "user.h"

User::User(string name, string password){
	this->name = name;
	this->password = password;
}

User::~User(){
}

void User::Persistence(){
}

char *User::ToString(){
	char *str = new char[20 + this->name.size() + this->password.size()];
	sprintf(str, "name: %s, password: %s\n", this->name.c_str(), this->password.c_str());
	return str;
}
