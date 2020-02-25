#!/bin/sh
#
# cowpatch.sh, by Rich Felker
#
# Permission to use, copy, modify, and/or distribute this software for
# any purpose with or without fee is hereby granted.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL
# WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE
# AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL
# DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA
# OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER
# TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
# PERFORMANCE OF THIS SOFTWARE.
#
# Take the above disclaimer seriously! This is an experimental tool
# still and does not yet take precautions against malformed/malicious
# patch files like patch(1) does. It may act out-of-tree and clobber
# stuff you didn't intend for it to clobber.
#

set -e

echo () { printf "%s\n" "$*" ; }

cow () {
test -h "$1" || return 0
if test -d "$1" ; then
case "$1" in
*/*) set -- "${1%/*}/" "${1##*/}" ;;
*) set -- "" "$1" ;;
esac
mkdir "$1$2.tmp.$$"
mv "$1$2" "$1.$2.orig"
mv "$1$2.tmp.$$" "$1$2"
( cd "$1$2" && ln -s ../".$2.orig"/* . )
else
cp "$1" "$1.tmp.$$"
mv "$1.tmp.$$" "$1"
fi
}

cowp () {
while test "$1" ; do
case "$1" in
*/*) set -- "${1#*/}" "$2${2:+/}${1%%/*}" ;;
*) set -- "" "$2${2:+/}$1" ;;
esac
cow "$2"
done
}

cowpatch () {

plev=0
OPTIND=1
while getopts ":p:i:RNE" opt ; do
test "$opt" = p && plev="$OPTARG"
done

while IFS= read -r l ; do
case "$l" in
+++*)
IFS=" 	" read -r junk pfile junk <<EOF
$l
EOF
i=0; while test "$i" -lt "$plev" ; do pfile=${pfile#*/}; i=$((i+1)) ; done
cowp "$pfile"
echo "$l"
;;
@@*)
echo "$l"
IFS=" " read -r junk i j junk <<EOF
$l
EOF
case "$i" in *,*) i=${i#*,} ;; *) i=1 ;; esac
case "$j" in *,*) j=${j#*,} ;; *) j=1 ;; esac
while test $i -gt 0 || test $j -gt 0 ; do
IFS= read -r l
echo "$l"
case "$l" in
+*) j=$((j-1)) ;;
-*) i=$((i-1)) ;;
*) i=$((i-1)) ; j=$((j-1)) ;;
esac
done ;;
*) echo "$l" ;;
esac
done

}

gotcmd=0
while getopts ":p:i:RNEI:S:" opt ; do
case "$opt" in
I) find "$OPTARG" -path "$OPTARG/*" -prune -exec sh -c 'ln -sf "$@" .' sh {} + ; gotcmd=1 ;;
S) cowp "$OPTARG" ; gotcmd=1 ;;
esac
done
test "$gotcmd" -eq 0 || exit 0

cowpatch "$@" | patch "$@"
