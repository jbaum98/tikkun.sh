#!/usr/bin/env bash

export BASE="$(dirname "$0")"

export BOOK=$1
export STARTCHAP=$2
export STARTVERSE=$3
export ENDCHAP=$4
export ENDVERSE=$5

book_heb() {
    case "$1" in
        Genesis)     echo -n "בראשית";;
        Exodus)      echo -n "שמות";;
        Leviticus)   echo -n "ויקרא";;
        Numbers)     echo -n "במדבר";;
        Deuteronomy) echo -n "דברים";;
    esac
}

pad_to() {
    echo -n "$1"
    for i in $(seq "$((${#1}+1))" $2); do
        printf '\xC2\xA0'
    done
}

get_verse() {
    set -e
    set -o pipefail

    TYPE=$1
    CHAP=$2
    VERSE=$3

    header="$(printf '\xE2\x80\xAB\xC2\xA0')$(pad_to $VERSE 3)$(printf '\xD7\x83')$(pad_to $CHAP 3)$(printf '\xC2\xA0')"
    cat "$BASE/data/$BOOK.$TYPE.txt" | grep "^$header" | trim_verse "${#header}"
    return $?
}

trim_verse() {
    x="$(tee)"
    if [[ ! -z $x ]]; then
        echo "${x:$1:${#x}-3}"
    fi
}

get_verses() {
    TYPE=$1

    c="$STARTCHAP"
    v="$STARTVERSE"
    while [ "$c" -le "$ENDCHAP" ]; do
        while [ "$v" -le "$ENDVERSE" ] || [ "$c" -lt "$ENDCHAP" ]; do
            verse=$(get_verse "$TYPE" "$c" "$v") || break
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

make_tex() {
    BOOKHEB="$(book_heb $BOOK)"

    if [ "$STARTCHAP" -eq "$ENDCHAP" ]; then
        SEC="\section*{$BOOKHEB \hebrewnumeral{$STARTCHAP}:\hebrewnumeral{$STARTVERSE}--\hebrewnumeral{$ENDVERSE}}"
    else
        SEC="\section*{$BOOKHEB \hebrewnumeral{$STARTCHAP}:\hebrewnumeral{$STARTVERSE}--\hebrewnumeral{$ENDCHAP}:\hebrewnumeral{$ENDVERSE}}"
    fi

    cat $BASE/template.tex
    echo $SEC
    get_verses acc
    echo -e "\n\pagebreak\n"
    echo $SEC
    echo "\begin{torah}"
    get_verses con
    echo "\end{torah}"
    echo "\end{document}"
}


main() {
    NAME="${BOOK}_${STARTCHAP}_${STARTVERSE}_${ENDCHAP}_${ENDVERSE}"
    TMP=$(mktemp --tmpdir -d torah-makerXXXXXX)

    make_tex > "$TMP/$NAME.tex"
    pushd $TMP
    latexmk --xelatex "$NAME.tex"
    popd
    cp "$TMP/$NAME.pdf" .
    rm -rf $TMP
}

main
