{ fetchzip, unzip }:
fetchzip {
  url = "https://www.tanach.us/TextFiles/Tanach.acc.txt.zip";
  name = "Tanach.acc";
  sha256 = "1hwcyr0iray7163x6w2kb8731j46afvpbsxlssjavsg4lnf3jnbf";
  stripRoot = false;
}
