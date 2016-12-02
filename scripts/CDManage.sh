#!/bin/bash

#
variableTable() {
	if [ -n "$1" -a -n "$2" ]; then
		if [ "$2" = "null"  ]; then
			unset $1
		else
			eval $1="$2"
		fi
	elif [ -n "$1" ]; then
		eval tmpVar='$'$1
		echo $tmpVar
		unset tmpVar
	fi
	return
}

cd_file="cds"
tracks_file="tracks"
tmp_file="/tmp/cdManaer_$$"
trap 'rm -f $tmp_file' EXIT

getReturn() {
	echo -e "按任意健继续... \c"
	read x
	return 0
}

getConfirm() {
	echo -e "输入y或n: \c"
	while :; do
		read x
		case "$x" in
		y | Y) return 0;;
		n | N) return 1;;
		esac
	done
}

setMenuChoice() {
	echo "请选择一个菜单："
	echo "a) 添加cd"
	echo "f) 查找cd"
	echo "q) 退出"
	read menu_choice
}

addRecord() {
	echo -e "请输入目录编号"
	read tmp
	cdCatNum=${tmp%%,*}

	echo -e "请输入标题"
      read tmp
      cdTitle=${tmp%%,*}

	echo -e "请输入曲目类型"
      read tmp
      cdType=${tmp%%,*}

	echo -e "请输入艺术家"
      read tmp
      cdAuthor=${tmp%%,*}

	insertRecord $cdCatNum,$cdTitle,$cdType,$cdAuthor
	
	echo "是否现在添加歌曲信息？"
	if getConfirm; then
		addTracks
	fi
	
	unset cdCatNum
	unset cdTitle
	unset cdType
	unset cdAuthor
	return 0
}

addTracks() {
	while [ "$track" != "q" ]; do
		tmp=$(grep -ch $cdCatNum, $tracks_file 2> /dev/null)
		tmp=${tmp:-0}
		trackNum=$((tmp+1))
		echo "当前专辑$cdCatNum包含$tmp条歌曲,输入q结束编辑"
		echo -e "请输入歌曲名称： \c"
		read tmp
		track=${tmp%%,*}
		if [ -n "$track" ]; then
			if [ "$track" != "q" ]; then
				insertTrack $cdCatNum,$trackNum,$track
				trackNum=$((trackNum+1))
			fi
		fi
	done
}

insertRecord() {
	echo $* >> $cd_file
}

insertTrack() {
	echo $* >> $tracks_file
}

findRecord() {
	echo -e "输入要查询的专辑内容： \c"
	read searchStr
	grep $searchStr $cd_file 2> /dev/null | sed 's/,/\t/g' | awk 'BEGIN{
		print "   目录编号\t标题\t目录类型\t艺术家"
	}
	{
		print NR" "$0
	}' | more
}

setMenuChoice
case "$menu_choice" in
	a) addRecord;;
	f) findRecord;;
	q) exit 0;;
	*) echo "请输入正确的选项";;
esac
