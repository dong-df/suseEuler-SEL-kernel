#!/bin/bash
#
# After run generate-mainline-patches.sh, let's remove patch if it was
# already in relevant stable kernel.
#
# The mainline-patch-files records all mainline patches's name, and it
# can be created like "ls patches.mainline/*|cat > mainline-patch-files"
#
# TODO: improve the checking of duplicated patch

. ./scripts/common_lib.sh

i=0
CURR_PWD=$PWD
START_STABLE_VERSION=v5.10
END_STABLE_VERSION=v5.10.83
count=$(wc -l mainline-patch-files | awk '{print $1}')
while read -r line; do
	i=$[$i+1]

	echo $line
	SUBJECT=$(ext_subject $line)
	echo $SUBJECT
	EXISTED=$(subject_existed "$SUBJECT")
	if [ -n "$EXISTED" ]; then
		echo "rm $line"
		rm $line
	fi
	echo $i/$count
done < mainline-patch-files
