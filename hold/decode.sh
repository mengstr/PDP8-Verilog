#!/bin/bash

declare -a dict

while IFS=$'\t' read -r key value1 value2; do
    dict[$key]="$value1 ($value2)"
done < ALLOPS.txt


while read line; do
	op=${line:(-4)}
	echo $line ";" "${dict[op]}"
done