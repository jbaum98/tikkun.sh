#!/usr/bin/env bash

pad_to() {
    echo -n "$1"
    for i in $(seq "$((${#1}+1))" $2); do
        printf '\xC2\xA0'
    done
}

get_verse() {
    set -e
    set -o pipefail

    BOOK=$1
    TYPE=$2
    CHAP=$3
    VERSE=$4
    cat "$BASE/data/$BOOK.$TYPE.txt" | grep "^$(printf '\xE2\x80\xAB\xC2\xA0')$(pad_to $VERSE 3)$(printf '\xD7\x83')$(pad_to $CHAP 3)$(printf '\xC2\xA0')" | trim_verse
    return $?
}

trim_verse() {
    x="$(tee)"
    if [[ ! -z $x ]]; then
        echo "${x:10:-3}"
    fi
}

get_verses() {
    BOOK=$1
    TYPE=$2
    STARTCHAP=$3
    STARTVERSE=$4
    ENDCHAP=$5
    ENDVERSE=$6


    c="$STARTCHAP"
    v="$STARTVERSE"
    while [ "$c" -le "$ENDCHAP" ]; do
        while [ "$v" -le "$ENDVERSE" ] || [ "$c" -lt "$ENDCHAP" ]; do
            verse=$(get_verse "$BOOK" "$TYPE" "$c" "$v") || break
            verse=$(echo $verse | sed 's/\xe2\x80\xaa.*\xe2\x80\xac//g') # filter notes
            verse=$(echo $verse | sed 's/ \xd7\xa4$/\\par /g' ) # Line break on peh
            if [ "$TYPE" != "con" ]; then
                echo -n "\\pnum{$v}"
            fi
            echo $verse
            v=$[$v+1]
        done
        c=$[$c+1]
        v="1"
    done
}

get_verses $@
