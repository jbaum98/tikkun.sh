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
    for i in $(seq "$((${#1}+1))" "$2"); do
        printf '\xC2\xA0'
    done
}

findBookFile() {
    type="$1"
    book="$2"

    if [ "$type" = "con" ]; then
        echo -n "${torahConsonants}/${book}.con.txt"
    else
        echo -n "${torahAccents}/${book}.acc.txt"
    fi

}

get_verse() {
    if [ "$#" -ne 4 ]; then
       echo "Illegal number of parameters"
       return 1
    fi

    set -o pipefail

    type="$1"
    book="$2"
    chapter="$3"
    verse="$4"

    bookFile="$(findBookFile $type $book)
"
    header="$(printf '\xE2\x80\xAB\xC2\xA0')$(pad_to $verse 3)$(printf '\xD7\x83')$(pad_to $chapter 3)$(printf '\xC2\xA0')"
    cat $bookFile | grep "^$header" | trim_verse "${#header}"
    return $?
}

trim_verse() {
    x="$(tee)"
    if [[ ! -z "$x" ]]; then
        echo "${x:$1:-3}"
    fi
}

maxVerse() {
    type="$1"
    book="$2"
    chapter="$3"

    bookFile="$(findBookFile "$type" "$book")"

    header=$(printf '\xE2\x80\xAA')"xxxx  Chapter $chapter"
    line="$(cat "$bookFile" | grep "^$header")"
    [[ "$line" =~ ([0-9]+)[[:space:]]verses ]] && echo "${BASH_REMATCH[1]}"
}

get_verses() {
    if [ "$#" -ne 6 ]; then
        echo "Illegal number of parameters"
        return 1
    fi

    type="$1"
    book="$2"
    startChapter="$3"
    startVerse="$4"
    endChapter="$5"
    endVerse="$6"

    for c in $(seq "$startChapter" "$endChapter"); do
        if [ "$c" -eq "$startChapter" ]; then
            minV="$startVerse"
        else
            minV=1
        fi

        if [ "$c" -eq "$endChapter" ]; then
            maxV=$endVerse
        else
            maxV="$(maxVerse "$type" "$book" "$c")"
        fi

        for v in $(seq "$minV" "$maxV"); do
            verse="$(get_verse "$type" "$book" "$c" "$v")" || break
            verse="$(echo "$verse" | sed 's/\xe2\x80\xaa.*\xe2\x80\xac//g')" # filter notes
            #verse=$(echo "$verse" | sed 's/ \xd7\xa4$/\\par /g' ) # Line break on peh
            if [ "$type" != "con" ]; then
                echo -n "\\pnum{$v}"
            fi
            echo "$verse"
        done
    done
}

make_tex() {
    if [ "$#" -ne 5 ]; then
        echo "Illegal number of parameters"
        return 1
    fi

    book="$1"
    startChapter="$2"
    startVerse="$3"
    endChapter="$4"
    endVerse="$5"

    bookHeb=$(book_heb "$book")

    if [ "$startChapter" -eq "$endChapter" ]; then
        secLine="\\section*{$bookHeb \hebrewnumeral{$startChapter}:\hebrewnumeral{$startVerse}--\hebrewnumeral{$endVerse}}"
    else
        secLine="\\section*{$bookHeb \hebrewnumeral{$startChapter}:\hebrewnumeral{$startVerse}--\hebrewnumeral{$endChapter}:\hebrewnumeral{$endVerse}}"
    fi

    cat template.tex
    echo "$secLine"
    get_verses acc "$book" "$startChapter" "$startVerse" "$endChapter" "$endVerse"
    echo -e "\n\pagebreak\n"
    echo "$secLine"
    echo "\begin{torah}"
    get_verses con "$book" "$startChapter" "$startVerse" "$endChapter" "$endVerse"
    echo "\end{torah}"
    echo "\end{document}"
}
