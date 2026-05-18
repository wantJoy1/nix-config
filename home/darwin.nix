{ pkgs, userName, ... }:

{
  imports = [ ./common.nix ];

  home.homeDirectory = "/Users/${userName}";

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
    "sudo /run/current-system/sw/bin/darwin-rebuild switch --flake /Users/${userName}/Documents/nix-config#MBA";
}
