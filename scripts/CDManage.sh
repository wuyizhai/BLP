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
	unset x
	return 0
}

getConfirm() {
	while :; do
		echo -e "输入y或n: \c"
		read x
		case "$x" in
		y | Y) return 0;;
		n | N) return 1;;
		esac
	done
	unset x
}

setMenuChoice() {
	echo "请选择一个菜单："
	echo "a) 添加cd"
	echo "f) 查找cd"
	echo "q) 退出"
	read menu_choice
}

setRecordMenuChoice() {
	echo "请选择一个操作："
	echo "a) 添加歌曲"
	echo "l) 列出所有歌曲"
	echo "d) 删除歌曲"
	echo "x) 删除当前专辑"
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
	
	unset cdCatNum cdTitle cdType cdAuthor
	return 0
}

addTracks() {
	while [ "$track" != "q" ]; do
		tmp=$(grep -h $cdCatNum, $tracks_file 2> /dev/null)
		if [ -n "$tmp" ]; then
			trackNum=$(($(echo "$tmp" | tail -n 1 | cut -d ',' -f 2)+1))
			trackCount=$(echo "$tmp" | wc -l)
		else
			trackNum=1
			trackCount=0
		fi
		echo "当前专辑$cdCatNum包含"$trackCount"条歌曲,输入q结束编辑"
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
	
	unset tmp trackNum track trackCount
}

listTracks() {
	grep -h $cdCatNum, $tracks_file 1>$tmp_file 2> /dev/null
	cat $tmp_file | sed 's/,/\t/g' | awk -v cdCatNum="$cdCatNum" -v count="$(cat $tmp_file | wc -l)" 'BEGIN{
		print "当前专辑"cdCatNum"包含"count"条歌曲"
		print "  歌曲名称"
	}
	{
		print NR" "$3
	}' | more
}

insertRecord() {
	echo $* >> $cd_file
}

insertTrack() {
	echo $* >> $tracks_file
}

delRecord() {
	sed -i "/^$cdCatNum,/d" $cd_file
	unset track
	delTrack
}

delTrack() {
	sed -i "/^$cdCatNum,.*,$track/d" $tracks_file
}

findRecord() {
	echo -e "输入要查询的专辑内容： \c"
	read searchStr
	grep $searchStr $cd_file 1>$tmp_file 2> /dev/null
	lineCount=$(cat $tmp_file | wc -l)
	[ $lineCount -gt 0 ] && {
		cat $tmp_file | sed 's/,/\t/g' | awk 'BEGIN{
			print "   目录编号\t标题\t目录类型\t艺术家"
		}
		{
			print NR" "$0
		}' | more
		x=0
		while [ $x -lt 1 -o $x -gt $lineCount ];
		do
			echo "选择一个要编辑的专辑的下标（1 ~ "$lineCount"）："
			read x
			if ! grep '^[[:digit:]]*$' <<< "$x" 1>/dev/null 2>&1; then
				x=0
				continue
			fi
			if [ $x -ge 1 -a $x -le $lineCount ]; then
				cdCatNum=$(cat $tmp_file | sed -n "${x}p" | cut -d ',' -f 1)
				cat $tmp_file | sed -n "${x}p" | awk -F ',' '{
					printf("目录编号:%s\t标题:%s\n目录类型:%s\t艺术家:%s\n",$1,$2,$3,$4)
				}'
				while [ "$menu_choice" != "q" ];
				do
					setRecordMenuChoice
					case "$menu_choice" in
						a) addTracks;;
						l) listTracks;;
						d)	echo -e "请输入要删除的歌曲名称：\c"
							read tmp
							track=${tmp%%,*}
							echo -e "是否删除专辑"$cdCatNum"下的歌曲"$track"?\c"
							if getConfirm; then
								delTrack
								echo "歌曲"$track"已被删除"
							fi
							;;
						x) 	echo -e "是否删除专辑"$cdCatNum"?\c"
							if getConfirm; then
								delRecord
								echo "专辑"$cdCatNum"已被删除"
								break 2
							fi
							;;
						q) 	break 2;;
						*) echo "请输入正确的选项";;
					esac
				done
			fi
		done
	} || {
		echo "没有找到要查询的专辑信息！"
	}
	
	unset searchStr lineCount x cdCatNum tmp menu_choice track
}

while [ "$menu_choice" != "q" ];
do
	setMenuChoice
	case "$menu_choice" in
		a) addRecord;;
		f) findRecord;;
		q) exit 0;;
		*) echo "请输入正确的选项";;
	esac
done
unset menu_choice
exit 0
