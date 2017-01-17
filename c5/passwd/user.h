#ifndef __USER_H__
#define __USER_H__ 1

#include <string>
#include <stdlib.h>
#include <stdio.h>

using namespace std;
class User {
	private:
		string name;
		string password;
	public:
		User(string name, string password);
		~User();
		void Persistence();
		char * ToString();
};

#endif
