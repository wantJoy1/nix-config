{ userName, ... }:

{
  imports = [ ./common.nix ];

  home.homeDirectory = "/Users/${userName}";

  # ghostty itself is installed via Homebrew cask (nixpkgs has no darwin
  # build); the home-manager module still owns the declarative config.
  programs.ghostty = {
    enable = true;
    package = null;
  };

  programs.nushell.shellAliases.rebuild =
    "sudo darwin-rebuild switch --flake ~/Documents/nix-config#MBA";
}
