#/bin/bash

signals1=(ckFetch stbFetchA stbFetchB ckAuto1 stbAuto1 ckAuto2 stbAuto2 ckInd stbInd)
signals2=(ck1 stb1 ck2 stb2 ck3 stb3 ck4 stb4)

for no in 1 2; do
	if [ "$no" == "1" ]; then signals=("${signals1[@]}"); fi
	if [ "$no" == "2" ]; then signals=("${signals2[@]}"); fi

	echo -n "FILE "
	for name in "${signals[@]}"; do
		echo -n "| $name "
	done
	echo ""

	echo -n "---"
	for name in "${signals[@]}"; do
		echo -n "|----"
	done
	echo ""

	ls -1 *.v | while read filename
	do
		if [ "${filename:0:4}" != "PDP8" ]; then
			printf '%-25s' "$filename "
			for name in "${signals[@]}"; do
				cnt=$(grep -c $name $filename)
				cnt=$(( $cnt -1 ))
				if [ "$cnt" -lt "1" ]; then cnt=""; fi
				echo -n "| $cnt "
			done
			echo ""
		fi
	done

	echo ""
	echo ""
done
