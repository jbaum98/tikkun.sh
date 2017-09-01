{ nixpkgs ? import <nixpkgs> {}, book, startChapter, startVerse, endChapter, endVerse }:
with nixpkgs;
let mkTorah = pkgs.callPackage ./mkTorah.nix {};
in mkTorah { inherit book startChapter startVerse endChapter endVerse; }
