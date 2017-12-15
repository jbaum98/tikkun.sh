# Tikkun.sh

Create beautiful Torah reading sheets from the command line.

## Getting Started

### Prerequisites

[The Nix Package Manger](https://nixos.org/nix) is used to manage dependencies and compilation.
To install it, follow the instructions [here](https://nixos.org/nix/download.html).

### Installing

Clone this repository:

```sh
git clone https://github.com/jbaum98/torahreading-maker
```

### Creating Sheets

#### Using Nix

The simplest way to create a Torah reading sheet is to use `nix-build` to call the `mkTorah` fuction.
For example, to create a sheet with the first 10 verses of Genesis:

```sh
cd torahreading-maker
nix-build --expr "with import <nixpkgs> {}; pkgs.callPackage ./mkTorah.nix {}" --argstr book Genesis --argstr startChapter 1 --argstr startVerse 1 --argstr endChapter 1 --argstr endVerse 10
```

This has the advantage of automatically caching the result in case you build the same set of verses twice.
It also does the build in a temporary directory and produces no temporary files.

#### Using the script

You can also install a script using `nix-env -i` from this directory.
Then you can run it as.

```sh
mkTikkun Genesis 1 1 1 10
```

This will produce the same pdf as the example above, but will produce the TeX file
and run TeX in the current directory.

<image src="https://user-images.githubusercontent.com/5283991/34024730-d160a986-e119-11e7-9cbe-9da1ee9b9036.jpg" width="1000px"></image>
<image src="https://user-images.githubusercontent.com/5283991/34024732-d47ca1f6-e119-11e7-87b9-fc085350bb0e.jpg" width="1000px"></image>

# License

This project is licensed under the MIT License - see the [LICENSE.txt](LICENSE.txt) file for details

# Acknowledgements

- The Hebrew unicode XML files are downloaded from https://www.tanach.us and transformed using XSLT templates
  based on the ones they provide.
- [libxslt](http://xmlsoft.org/libxslt/) is used to parse and transform the XML files to produce TeX files.
- The font family is [Shlomo](https://sites.google.com/site/orlaeinayim/introduction-to-fonts-with-hebrew-cantillation-marks),
  a modified version of [Ezra SIL](http://scripts.sil.org/cms/scripts/page.php?site_id=nrsi&id=EzraSIL_Home) designed to make it
  easier to distingiush between similar looking Hebrew letters such as ג and נ or ד and ר.
