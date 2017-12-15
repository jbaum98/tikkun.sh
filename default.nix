{ stdenv, lib, callPackage, writeShellScriptBin, fetchurl, fetchzip, makeFontsConf, texlive, libxslt, unzip }:
let
  tex = texlive.combine {
    inherit (texlive) scheme-basic xetex xetex-def euenc bidi latexmk polyglossia extsizes xcolor ms;
  };

  fonts = callPackage ./shlomoFonts.nix {};

  torahXML = callPackage ./torahXML.nix {};

in writeShellScriptBin "mkTikkun" ''
  export FONTCONFIG_FILE=${makeFontsConf { fontDirectories = fonts; }};
  name="$1_$2_$3_$4_$5"
  xsltproc --param chapter $2 --param verse $3 --param lastchapter $4 --param lastverse $5 ${./XML2LaTeX.xsl.xml} ${torahXML}/Books/$1.xml > $name.tex
  ${tex}/bin/latexmk --xelatex $name.tex
''
