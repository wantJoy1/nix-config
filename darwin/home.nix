{ config, pkgs, osConfig, userName, ... }:

{
  home.homeDirectory = osConfig.users.users.${userName}.home;

  # ghostty itself is installed via Homebrew cask (nixpkgs has no darwin
  # build); the home-manager module still owns the declarative config.
  programs.ghostty = {
    enable = true;
    package = null;
    settings = {
      command = "${pkgs.nushell}/bin/nu";
      "auto-update" = "download";
    };
  };

  programs.nushell.shellAliases.rebuild =
    "sudo /run/current-system/sw/bin/darwin-rebuild switch --flake ${config.home.homeDirectory}/Documents/nix-config#MBA";
}
