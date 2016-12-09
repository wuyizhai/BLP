#!/bin/bash

cd_file="cds"
tracks_file="tracks"
tmp_file="/tmp/cdManaer_$$"
tmp_file2="/tmp/cdManaer_$$_2"
trap 'rm -f $tmp_file $tmp_file2' EXIT

getReturn() {
	echo -e "按任意健继续... \c"
	read x
	unset x
	return 0
}

getConfirm() {
	dialog --yesno "$1" 15 30
	return $?
}

setMenuChoice() {
	dialog --menu "请选择一个菜单：" 15 30 3 "a" "添加cd" "f" "查找cd" "q" "退出" 2>$tmp_file
	if [ "$?" != 0 ]; then
		menu_choice=q
	else
		menu_choice=$(cat $tmp_file)
	fi
}

setRecordMenuChoice() {
	dialog --menu "$*\n请选择一个操作：" 15 40 5 "a" "添加歌曲" "l" "列出所有歌曲" "d" "删除歌曲" "x" "删除当前专辑" "q" "退出" 2>$tmp_file2
	if [ "$?" != 0 ]; then
		menu_choice=q
	else
		menu_choice=$(cat $tmp_file2)
	fi
}

addRecord() {
	dialog --nocancel --inputbox "请输入目录编号" 9 30 2>$tmp_file
	cdCatNum=$(cat $tmp_file)
	cdCatNum=${cdCatNum%%,*}

	dialog --nocancel --inputbox "请输入标题" 9 30 2>$tmp_file
	cdTitle=$(cat $tmp_file)
      cdTitle=${cdTitle%%,*}

	dialog --nocancel --inputbox "请输入曲目类型" 9 30 2>$tmp_file
	cdType=$(cat $tmp_file)
      cdType=${cdType%%,*}

	dialog --nocancel --inputbox "请输入艺术家" 9 30 2>$tmp_file
	cdAuthor=$(cat $tmp_file)
      cdAuthor=${cdAuthor%%,*}

	insertRecord $cdCatNum,$cdTitle,$cdType,$cdAuthor
	
	if getConfirm "是否现在添加歌曲信息？"; then
		addTracks
	fi
	
	unset cdCatNum cdTitle cdType cdAuthor
	return 0
}

addTracks() {
	while [ "$?" = "0" ]; do
		tmp=$(grep -h $cdCatNum, $tracks_file 2> /dev/null)
		if [ -n "$tmp" ]; then
			trackNum=$(($(echo "$tmp" | tail -n 1 | cut -d ',' -f 2)+1))
			trackCount=$(echo "$tmp" | wc -l)
		else
			trackNum=1
			trackCount=0
		fi
		dialog --nocancel --inputbox "当前专辑$cdCatNum包含"$trackCount"条歌曲，请输入歌曲名称： " 9 30 2>$tmp_file
		tmp=$(cat $tmp_file)
		track=${tmp%%,*}
		if [ -n "$track" ]; then
			insertTrack $cdCatNum,$trackNum,$track
			trackNum=$((trackNum+1))
			getConfirm "是否继续添加歌曲信息？"
		fi
	done
	
	unset tmp trackNum track trackCount
}

listTracks() {
	grep -h $cdCatNum, $tracks_file 1>$tmp_file2 2> /dev/null
	if [ $(cat $tmp_file2 | wc -l) -eq 0 ]; then
		dialog --msgbox "当前专辑$cdCatNum包含0条歌曲" 15 20
	else
		dialog --nocancel --menu "当前专辑$cdCatNum包含$(cat $tmp_file2 | wc -l)条歌曲" 15 30 6 $(cat $tmp_file2 | cut -d ',' -f 3 | awk 			'{
			print NR" "$1
		}')
	fi
}

insertRecord() {
	echo $* >> $cd_file
}

insertTrack() {
	echo $* >> $tracks_file
}

delRecord() {
	sed -i "/$cdCatNum,/d" $cd_file
	unset track
	delTrack
}

delTrack() {
	sed -i "/$cdCatNum,.*,$track/d" $tracks_file
}

findRecord() {
	dialog --nocancel --inputbox "输入要查询的专辑内容：" 9 30 2>$tmp_file2
	searchStr=$(cat $tmp_file2)
      searchStr=${searchStr%%,*}
	grep $searchStr $cd_file 1>$tmp_file 2> /dev/null
	lineCount=$(cat $tmp_file | wc -l)
	[ $lineCount -gt 0 ] && {
		dialog --nocancel --menu "选择一个要编辑的专辑" 15 50 6 $(cat $tmp_file | sed 's/,/\t/g' | awk '{
			print NR" "$1
		}') 2>$tmp_file2
		x=$(cat $tmp_file2)
     		x=${x%%,*}
     		
		cdCatNum=$(cat $tmp_file | sed -n "${x}p" | cut -d ',' -f 1)
		while [ "$menu_choice" != "q" ];
		do
			setRecordMenuChoice $(cat $tmp_file | sed -n "${x}p" | awk -F ',' '{
				printf("目录编号:%s\t标题:%s\n目录类型:%s\t艺术家:%s\n",$1,$2,$3,$4)
			}')
			case "$menu_choice" in
				a) addTracks;;
				l) listTracks;;
				d)	dialog --nocancel --inputbox "请输入要删除的歌曲名称：" 9 30 2>$tmp_file2
					tmp=$(cat $tmp_file2)
					track=${tmp%%,*}
					if getConfirm "是否删除专辑"$cdCatNum"下的歌曲"$track"?"; then
						delTrack
						dialog --msgbox "歌曲"$track"已被删除" 15 20
					fi
					;;
				x) 	if getConfirm "是否删除专辑"$cdCatNum"?"; then
						delRecord
						dialog --msgbox "专辑"$cdCatNum"已被删除" 15 20
						break
					fi
					;;
				q) 	break;;
				*) ;;
			esac
		done
	} || {
		dialog --msgbox "没有找到要查询的专辑信息！" 15 20
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
		*) ;;
	esac
done
unset menu_choice
