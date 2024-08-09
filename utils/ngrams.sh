#!/usr/bin/env bash
# thanks to: https://stackoverflow.com/questions/14410478/can-ngrams-be-generated-in-bash
#set -eo pipefail

function fail
{
        echo $@;
        exit -1;
}

((n=${1:-0})) || fail "ngrams # filename"
_inputfile=${2:-}
[ -f "${_inputfile}" ] || fail "cannot open file $_inputfile"


declare -A ngrams
declare -a line
declare -i lineno

exec 3< "$_inputfile"
lineno=0
while read -ra line <&3; do
        (( lineno++ ))
        items=${#line[@]}
        # echo "Line ${lineno} has ${items} tokens"
        # this was sliding off the end, collecting items smaller than the n-grame
        for ((i = 0; i < (items - n + 1); i++)); do
                # echo "  curitem = ${line[@]:i:n}"
                ((ngrams[${line[@]:i:n}]++))
        done
done
# close the file
exec 3>&-

for i in "${!ngrams[@]}"; do
        count="${ngrams[$i]}"
        [ "$count" == "1" ] && continue
        printf '%d\t"%s"\n' "${count}" "$i"
done | sort -nr

