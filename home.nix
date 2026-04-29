{ pkgs, ... }:

{
  home.username = "kf";
  home.homeDirectory = "/home/kf";
  home.stateVersion = "25.11";

  programs.konsole = {
    enable = true;
    defaultProfile = "Nushell";
    profiles.Nushell = {
      name = "Nushell";
      command = "${pkgs.nushell}/bin/nu";
    };
  };
}
