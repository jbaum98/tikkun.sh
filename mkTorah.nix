{ stdenv, callPackage, fetchurl, fetchzip, makeFontsConf, texlive, unzip }:
let
  tex = texlive.combine {
    inherit (texlive) scheme-basic xetex xetex-def euenc bidi latexmk polyglossia extsizes xcolor ms;
  };

  fonts = callPackage ./shlomoFonts.nix {};

in { book, startChapter, startVerse, endChapter, endVerse }:
  stdenv.mkDerivation rec {
    name = "${book}_${startChapter}_${startVerse}_${endChapter}_${endVerse}";
    src = ./.;
    buildInputs = [
      tex
    ];

  torahAccents = callPackage ./torahAccents.nix {};
  torahConsonants = callPackage ./torahConsonants.nix {};

  buildPhase = ''
    source ${./torah.sh}
    make_tex ${book} ${startChapter} ${startVerse} ${endChapter} ${endVerse} > ${name}.tex
    latexmk --xelatex "${name}.tex"
  '';

  installPhase = ''
    mkdir -p $out
    cp ${name}.pdf $out
  '';

  FONTCONFIG_FILE = makeFontsConf { fontDirectories = fonts; };
}

