{ stdenv, fetchurl, fetchzip, makeFontsConf, texlive, unzip }:
let
  tex = texlive.combine {
    inherit (texlive) scheme-basic xetex xetex-def euenc bidi latexmk polyglossia extsizes xcolor ms;
  };

  ezraFont = stdenv.mkDerivation rec {
    version = "251";
    name = "EzraSIL${version}";
    src = fetchzip {
      url = "http://scripts.sil.org/cms/scripts/render_download.php?format=file&media_id=EzraSIL251.zip&filename=EzraSIL${version}.zip";
      name = "EzraSIL${version}.zip";
      sha256 = "1jbir312s5pw4rw8ylbpq0qpdg0x26kpzdb36dcsb496jwpn4flb";
    };

    installPhase = ''
      mkdir -p $out/share/fonts/
      cp *.ttf $out/share/fonts/
    '';
  };

  fontDev = name: sha256: stdenv.mkDerivation rec {
    inherit name;
    src = fetchurl {
      url = "https://sites.google.com/site/orlaeinayim/${name}.ttf";
      inherit sha256;
    };
    unpackPhase = ''
      mkdir -p ${name}
      cp $src ${name}
      cd ${name}
    '';

    doBuild = false;

    installPhase = ''
      mkdir -p $out/share/fonts/
      cp *.ttf $out/share/fonts/
    '';
  };

  shlomoFonts = [
    (fontDev "Shlomo" "0qn3r9qw54rqh7alxv3q4kps75q1ks15pvrcmqzivi917031d4jz")
    (fontDev "ShlomoLightBold" "05j08cysiqlmwah5hgg6mngqbgj1bigd2mjczvzz3q7gmacah2h1")
    (fontDev "ShlomoBold" "0b9knay8vvnbbk1bd42bimq2b6n29xrj5z0ql9b5s06jv432m0bc")
    (fontDev "ShlomoStam" "0dbx1a7k8nyd4m17g07hfihbdwpnfpph851shcqq6yvgp9flkkq7")
    (fontDev "ShlomosemiStam" "16z3yxhd4cgryzml6bjb8w5r3d2whqq359skp9bpdr7hfhk6c6rx")
  ];

  fonts = [ ] ++ shlomoFonts;

  torahConsonants = fetchzip {
    url = "https://www.tanach.us/TextFiles/Tanach.con.txt.zip";
    name = "Tanach.con";
    sha256 = "0si85kcv6g9bgdjfg6zhqjcqdpj5qs49b6zfdx2h2saq53kywybg";
    stripRoot = false;
  };

  torahAccents = fetchzip {
    url = "https://www.tanach.us/TextFiles/Tanach.acc.txt.zip";
    name = "Tanach.acc";
    sha256 = "1hwcyr0iray7163x6w2kb8731j46afvpbsxlssjavsg4lnf3jnbf";
    stripRoot = false;
  };

in { book, startChapter, startVerse, endChapter, endVerse }:
  stdenv.mkDerivation rec {
    name = "${book}_${startChapter}_${startVerse}_${endChapter}_${endVerse}";
    src = ./.;
    buildInputs = [
      tex
      torahAccents
      torahConsonants
    ];

    buildPhase = ''
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
          for i in $(seq "$((''${#1}+1))" $2); do
              printf '\xC2\xA0'
          done
      }

      get_verse() {
          set -e
          set -o pipefail

          TYPE=$1
          VERSE=$2
          CHAP=$3

          if [ "$TYPE" = "con" ]; then
            BOOK_FILE=${torahConsonants}/${book}.con.txt
          else
            BOOK_FILE=${torahAccents}/${book}.acc.txt
          fi

          header="$(printf '\xE2\x80\xAB\xC2\xA0')$(pad_to $VERSE 3)$(printf '\xD7\x83')$(pad_to $CHAP 3)$(printf '\xC2\xA0')"
          cat "$BOOK_FILE" | grep "^$header" | trim_verse "''${#header}"
          return $?
      }

      trim_verse() {
          x="$(tee)"
          if [[ ! -z $x ]]; then
              echo "''${x:$1:''${#x}-3}"
          fi
      }

      get_verses() {
          TYPE=$1

          c="${startChapter}"
          v="${startVerse}"
          while [ "$c" -le "${endChapter}" ]; do
              while [ "$v" -le "${endVerse}" ] || [ "$c" -lt "${endChapter}" ]; do
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
          BOOKHEB="$(book_heb ${book})"

          if [ "${startChapter}" -eq "${endChapter}" ]; then
              SEC="\\section*{$BOOKHEB \hebrewnumeral{${startChapter}}:\hebrewnumeral{${startVerse}}--\hebrewnumeral{${endVerse}}}"
          else
              SEC="\\section*{$BOOKHEB \hebrewnumeral{${startChapter}}:\hebrewnumeral{${startVerse}}--\hebrewnumeral{${endChapter}}:\hebrewnumeral{${endVerse}}}"
          fi

          cat template.tex
          echo "$SEC"
          get_verses acc
          echo -e "\n\pagebreak\n"
          echo "$SEC"
          echo "\begin{torah}"
          get_verses con
          echo "\end{torah}"
          echo "\end{document}"
      }

      make_tex > ${name}.tex
      cat ${name}.tex
      latexmk --xelatex "${name}.tex"
    '';

    installPhase = ''
      mkdir -p $out
      cp ${name}.pdf $out
    '';

    FONTCONFIG_FILE = makeFontsConf { fontDirectories = fonts; };
  }

