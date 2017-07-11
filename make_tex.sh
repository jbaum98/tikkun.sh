#!/usr/bin/env bash

BOOK=$1
STARTCHAP=$2
STARTVERSE=$3
ENDCHAP=$4
ENDVERSE=$5

BOOKHEB=$($BASE/book_heb.sh $BOOK)

if [ "$STARTCHAP" -eq "$ENDCHAP" ]; then
    SEC="\section*{$BOOKHEB \hebrewnumeral{$STARTCHAP}:\hebrewnumeral{$STARTVERSE}--\hebrewnumeral{$ENDVERSE}}"
else
    SEC="\section*{$BOOKHEB \hebrewnumeral{$STARTCHAP}:\hebrewnumeral{$STARTVERSE}--\hebrewnumeral{$ENDCHAP}:\hebrewnumeral{$ENDVERSE}}"
fi

cat $BASE/template.tex
echo $SEC
$BASE/get_verse.sh $BOOK acc $STARTCHAP $STARTVERSE $ENDCHAP $ENDVERSE
echo -e "\n\pagebreak\n"
echo $SEC
echo "\begin{torah}"
$BASE/get_verse.sh $BOOK con $STARTCHAP $STARTVERSE $ENDCHAP $ENDVERSE
echo "\end{torah}"
echo "\end{document}"

