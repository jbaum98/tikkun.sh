#!/usr/bin/env bash

export BASE="$(dirname "$0")"

BOOK=$1
STARTCHAP=$2
STARTVERSE=$3
ENDCHAP=$4
ENDVERSE=$5

NAME="${BOOK}_${STARTCHAP}_${STARTVERSE}_${ENDCHAP}_${ENDVERSE}"
TMP=$(mktemp --tmpdir -d torah-makerXXXXXX)


$BASE/make_tex.sh $@ > "$TMP/$NAME.tex"
pushd $TMP
latexmk --xelatex "$NAME.tex"
popd
cp "$TMP/$NAME.pdf" .
rm -rf $TMP
