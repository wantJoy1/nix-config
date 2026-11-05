{
  lib,
  fetchurl,
  runCommand,
  unzip,
}:

let
  driverZip = fetchurl {
    url = "https://dlcdnets.asus.com/pub/ASUS/mb/08WIRELESS/DRV_WiFi_MTK_MT7925_27_TP_W11_64_V5706054_20260706R.zip";
    hash = "sha256-9CHj5up/ozXrs/tw129VBwn+L4vVJjPVGOS0K/oCGcs=";
  };
  blobOffset = "500236";
  blobSize = "571349";
in
runCommand "mt7927-bt-firmware-20260611"
  {
    nativeBuildInputs = [ unzip ];
    meta.license = lib.licenses.unfree;
  }
  ''
    unzip -q ${driverZip} mtkwlan.dat
    install -d $out/lib/firmware/mediatek/mt7927
    dd if=mtkwlan.dat of=$out/lib/firmware/mediatek/mt7927/BT_RAM_CODE_MT6639_2_1_hdr.bin \
      bs=1 skip=${blobOffset} count=${blobSize} status=none
  ''
