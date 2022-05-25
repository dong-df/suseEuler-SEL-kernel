#!/bin/bash
#
# Copyright (c) 2022 Yunche Information Technology (Shenzhen) Co., Ltd.
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.
#

# This script create patches from mainline kernel KVER, for use in SUSE kernel-source package
# This script shall be run in a stable tree repo, i.e. https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git
# Usage example: $0 5.10 1 81
# Which generates all patches from 5.10.1 to 5.10.81, and a series file, that can be used to 
# patch a 5.10 source tree to 5.10.81.

# The major version
KVER=$1
# The minor version to start with
KSTART=$2
# The minor version to end with
KEND=$3
# The dir to save the created patches, relative to this script
PATCHDIR=patches.stable
# Bug ID for tracking stable kernel backporting
BUGID=bsn#19

# For each minor release generate the patches
for v in $(eval echo {$KSTART..$KEND}); do
	if [ $v = "1" ]; then
		VLAST=$KVER
	else
		VLAST=$KVER.$((v-1))
	fi
	VTHIS=$KVER.$v

	git format-patch v$VLAST..v$VTHIS -o $PATCHDIR/$VTHIS \
		--no-numbered --no-renames --signoff \
		--add-header="References: $BUGID" \
		--add-header="Patch-mainline: v$VTHIS"

	cd $PATCHDIR/$VTHIS
	for f in *.patch; do
		mv "$f" $(echo $f | sed -e "s|^0|v$VTHIS-0|")
	done

	# Some patches have "References:" line in their commit messages, which may
	# interfere with the "References:" header and make some scripts not happy.
	# So we check for such lines below 10th line and change it a little bit.
	sed -i -E -e '1s|^From ([0-9a-z]{40}) (.*)|Git-commit: \1|' \
			-e '10,$s|^References:|  References:|' *.patch

	mv *.patch ..
	cd -
	rm -rf $PATCHDIR/$VTHIS
done

ls -v $PATCHDIR/*.patch > $PATCHDIR/series

