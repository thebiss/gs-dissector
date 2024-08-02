#!/usr/bin/env bash
# thanks to: https://stackoverflow.com/questions/14410478/can-ngrams-be-generated-in-bash

((n=${1:-0})) || exit 1

declare -A ngrams

while read -ra line; do
        for ((i = 0; i < ${#line[@]}; i++)); do
                ((ngrams[${line[@]:i:n}]++))
        done
done 

for i in "${!ngrams[@]}"; do
        count="${ngrams[$i]}"
        [ "$count" == "1" ] && continue
        printf '%d\t"%s"\n' "${count}" "$i"
done
