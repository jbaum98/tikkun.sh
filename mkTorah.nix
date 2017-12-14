{ stdenv, lib, callPackage, fetchurl, fetchzip, makeFontsConf, texlive, libxslt, unzip }:
let
  tex = texlive.combine {
    inherit (texlive) scheme-basic xetex xetex-def euenc bidi latexmk polyglossia extsizes xcolor ms;
  };

  fonts = callPackage ./shlomoFonts.nix {};

in { book, startChapter, startVerse, endChapter, endVerse }:
  stdenv.mkDerivation rec {
    name = "${book}_${startChapter}_${startVerse}_${endChapter}_${endVerse}";

    src = lib.sourceFilesBySuffices ./. [".cls"];

    buildInputs = [
      tex
      libxslt
    ];

  torahXML = callPackage ./torahXML.nix {};
  bookFile = "${torahXML}/Books/${book}.xml";

  buildPhase = ''
    xsltproc --param chapter ${startChapter} --param verse ${startVerse} --param lastchapter ${endChapter} --param lastverse ${endVerse} ${./XML2LaTeX.xsl.xml} ${bookFile} > ${name}.tex
    latexmk --xelatex "${name}.tex"
  '';

  installPhase = ''
    mkdir -p $out
    cp ${name}.pdf $out
  '';

  FONTCONFIG_FILE = makeFontsConf { fontDirectories = fonts; };
}

