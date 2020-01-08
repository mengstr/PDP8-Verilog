#!/bin/bash

declare -a dict

while IFS=$'\t' read -r key value1 value2; do
    dict[$key]="$value1 ($value2)"
done < allops.txt

while read line; do
	line="${line%"${line##*[![:space:]]}"}"
	op=${line:(-4)}
	[ "$op" -eq "$op" ] 2>/dev/null
	if [ $? -ne 0 ]; then
		echo $line
	else
		echo $line ";" "${dict[op]}" 
	fi
done
