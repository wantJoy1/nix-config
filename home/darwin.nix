{ pkgs, userName, ... }:

{
  imports = [ ./common.nix ];

  home.username = userName;
  home.homeDirectory = "/Users/${userName}";
  home.stateVersion = "25.11";

  programs.nushell = {
    enable = true;
    shellAliases.rebuild = "sudo darwin-rebuild switch --flake ~/Documents/nix-config#MBA";
    extraConfig = "$env.config.show_banner = false";
  };
}
