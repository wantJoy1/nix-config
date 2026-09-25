{ lib, pkgs, ... }:

let
  openExe = pkgs.writeShellScript "dlsite-open-exe" ''
    export DLSITE_TARGET="$1"
    exec ${lib.getExe pkgs.nushell} --no-config-file \
      --commands 'source ${./dlsite.nu}; dlsite-run $env.DLSITE_TARGET'
  '';
in
{
  home.packages = with pkgs; [
    wineWow64Packages.stagingFull
    winetricks
    unar

    easyrpg-player
    nwjs
    onscripter
    renpy
  ];

  programs.nushell.extraConfig = builtins.readFile ./dlsite.nu;

  xdg = {
    desktopEntries.dlsite-run = {
      name = "DLsite (作品ごとの prefix)";
      exec = "${openExe} %f";
      mimeType = [ "application/x-ms-dos-executable" ];
      noDisplay = true;
    };

    mimeApps.defaultApplications."application/x-ms-dos-executable" = "dlsite-run.desktop";
  };
}
