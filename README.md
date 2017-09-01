# Torah Reading Maker

Creates beautiful Torah reading sheets.

## Getting Started

### Prerequisites

[The Nix Package Manger](https://nixos.org/nix) is used to manage dependencies and building of the sheets.
To install it, follow the instructions [here](https://nixos.org/nix/download.html).

### Installing

Clone this repository:

```sh
git clone https://github.com/jbaum98/torahreading-maker
```

### Creating Sheets

The simplest way to create a Torah reading sheet is to use `nix-build` to call the `mkTorah` fuction.
For example, to create a sheet with the first 10 verses of Genesis:

```sh
cd torahreading-maker
nix-build --argstr book Genesis --argstr startChapter 1 --argstr startVerse 1 --argstr endChapter 1 --argstr endVerse 10
open result/Genesis_1_1_1_10.pdf
```

<image src="https://user-images.githubusercontent.com/5283991/29955856-bc21ecbc-8eb0-11e7-802e-d3ee6905d013.jpg" width="1000px"></image>
<image src="https://user-images.githubusercontent.com/5283991/29955857-bc23bf7e-8eb0-11e7-826e-736cd74b97fa.jpg" width="1000px"></image>
