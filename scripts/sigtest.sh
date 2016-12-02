#!/bin/bash
filename=/tmp/tmp_$$
trap 'rm -f $filename' INT
echo 正在创建文件$filename
date > $filename

while [ -f $filename ]; do
	echo "文件$filename存在"
	sleep 1
done
echo "文件$filename已删除"

trap - INT
echo 正在创建文件$filename
date > $filename

while [ -f $filename ]; do
        echo "文件$filename存在"
        sleep 1
done
echo "不会执行到这里"
exit 0
