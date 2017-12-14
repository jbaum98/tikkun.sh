{ fetchzip, unzip } :
fetchzip {
  url = "https://www.tanach.us/TextFiles/Tanach.con.txt.zip";
  name = "Tanach.con";
  sha256 = "0si85kcv6g9bgdjfg6zhqjcqdpj5qs49b6zfdx2h2saq53kywybg";
  stripRoot = false;
}
