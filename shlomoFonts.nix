{ stdenv, fetchurl }:
let
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
in [
  (fontDev "Shlomo" "0qn3r9qw54rqh7alxv3q4kps75q1ks15pvrcmqzivi917031d4jz")
  (fontDev "ShlomoLightBold" "05j08cysiqlmwah5hgg6mngqbgj1bigd2mjczvzz3q7gmacah2h1")
  (fontDev "ShlomoBold" "0b9knay8vvnbbk1bd42bimq2b6n29xrj5z0ql9b5s06jv432m0bc")
  (fontDev "ShlomoStam" "0dbx1a7k8nyd4m17g07hfihbdwpnfpph851shcqq6yvgp9flkkq7")
  (fontDev "ShlomosemiStam" "16z3yxhd4cgryzml6bjb8w5r3d2whqq359skp9bpdr7hfhk6c6rx")
  ]
