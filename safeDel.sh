#!/bin/bash/env bash

USAGE="usage: $0 A script to safely delete files by moving them to the trashcan in Linux " 
trash_directory="$HOME/.trashCan"
NAME="Elizabeth Akpan"
STUDENT_ID="S1719014"
working_directory=$(pwd)

trash_can(){
	echo $NAME
	echo $STUDENT_ID
	echo "--------------------------------------"
	if [[ ! -d $trash_directory ]]; then
		mkdir $trash_directory
		echo "A new .trashCan directory has been created"
	else 
		echo "You are now in the trashCan directory"
	fi
}

trash_can

safeDel(){
	cd $working_directory	
	mv $@ $trash_directory
	if [[ $? -eq 0 ]] ; then
		echo "The file(s) has been moved to the trashCan directory"
	else
		echo "Moving the file to the trashCan directory was unsuccessful"
	fi
}

list(){
	if [ "$(ls -A $trash_directory)" ]; then
		echo "The trashcan has the following files: " 
		format="%15s%10s %-s\n"
		printf "$format" "File Name" "Size" "Type"
		printf "$format" "---------" "----" "----"
		for f in $trash_directory/* ; do
			fileF=$(basename $f)
			sizeF=$(wc -c<"$f")
			typeF=$(file --mime-type -b "$f")
			printf "$format" $fileF $sizeF $typeF
		done	
	else	
		echo "The trashcan directory $trash_directory, is Empty"
	fi
}

recover(){
	list
	read -p "Enter the file you will like to move to the current directory: " fileName
	current_file="$trash_directory/$fileName"
	if [ -e  $current_file ] ; then
		mv $current_file $working_directory
		echo "Your file has been moved successfully!"
	else
		echo "The file does not exist in this directory."
	fi
}

recoverR(){
	current_file="$trash_directory/$1"
	if [ -e  $current_file ] ; then
		mv $current_file $working_directory
		echo "The file has been moved successfully!"
	else
		echo "The file does not exist in this directory."
	fi
}

delete(){
	list
	for i in $trash_directory/* ; do
		echo "Are you sure you want to permanently delete this file?" $i "Yes/No"
		read fileDel
		case "$fileDel" in
			Y|y|yes|Yes|YES) 
				rm $i;;
			N|n|no|No|NO) 
				echo "File has not been deleted.";;
		esac
	done
}

totalUsage(){
	echo "Total usage of the trashCan directory in bytes is: "
	size=$(du -b $trash_directory | tr -d "$trash_directory" )
	size=$((size-4096))
	echo "$size"

	if [ $size > 1024 ] ; then
		echo "Warning!!! The disk Usage in the .trashCan directory exceeds 1KBytes"
	fi
}

monitor(){
	bash monitor.sh
}


kill(){
	kill monitor
}

trap trapCtrlC SIGINT

trap trapEndScript EXIT

trapCtrlC(){
    exit 130
}

trapEndScript(){
    echo -e "\r\nGoodbye $NAME!"
}

while getopts :lr:dtmk args #options
do
  case $args in
     l) list ;;
     r) recoverR $OPTARG;;
     d) delete ;; 
     t) totalUsage ;; 
     m) monitor ;; 
     k) kill ;;     
     :) echo "data missing, option -$OPTARG";;
    \?) echo "$USAGE";;
  esac
done

((pos = OPTIND - 1))
shift $pos

PS3='option> '

if (( $# == 0 ))
then if (( $OPTIND == 1 )) 
 then select menu_list in list recover delete total monitor kill exit
      do case $menu_list in
         "list") list ;;
         "recover") recover ;;
         "delete") delete ;;
         "total") totalUsage ;;
         "monitor") monitor ;;
         "kill") kill ;;
         "exit") exit 0;;
         *) echo "unknown option";;
         esac
      done
 fi
else 
	safeDel $@
fi
