cmake_minimum_required (VERSION 2.6)
project (screenMenu)
set (Passwd_VERSION_MAJOR 1)
set (Passwd_VERSION_MINOR 0)

#允许gdb调试
set(CMAKE_BUILD_TYPE "Debug")
set(CMAKE_CXX_FLAGS_DEBUG "$ENV{CXXFLAGS} -O0 -Wall -g -ggdb")
set(CMAKE_CXX_FLAGS_RELEASE "$ENV{CXXFLAGS} -O3 -Wall")

#添加C++11支持及其他选项
set(CMAKE_CXX_FLAGS "-std=c++0x ${CMAKE_CXX_FLAGS} -g -ftest-coverage -fprofile-arcs -Wno-deprecated")
##set(CMAKE_CXX_FLAGS "-std=c++0x ${CMAKE_CXX_FLAGS -g -ftest-coverage -fprofile-arcs"})

include_directories(${PROJECT_SOURCE_DIR}/include)
AUX_SOURCE_DIRECTORY(. DIR_MAIN)
add_executable(${PROJECT_NAME} ${DIR_MAIN})

#添加C++11编译选项,但是只有CMAKE 3.1支持
##target_compile_features(mmseg PRIVATE cxx_range_for)

#AUX_SOURCE_DIRECTORY("src" DIR_SRCS)
#add_library(src SHARED ${DIR_SRCS})
#target_link_libraries(${PROJECT_NAME} src)

target_link_libraries(${PROJECT_NAME} ncurses)
