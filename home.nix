{ pkgs, ... }:

{
  home.username = "kf";
  home.homeDirectory = "/home/kf";
  home.stateVersion = "25.11";

  home.packages = with pkgs; [
    obsidian
    claude-code
  ];

  programs.git = {
    enable = true;
    settings.user = {
      name = "wantJoy1";
      email = "wantjoy1@gmail.com";
    };
  };

  programs.nushell.enable = true;

  programs.plasma.enable = true;

  programs.konsole = {
    enable = true;
    defaultProfile = "Nushell";
    profiles.Nushell = {
      name = "Nushell";
      command = "${pkgs.nushell}/bin/nu";
    };
  };
}
