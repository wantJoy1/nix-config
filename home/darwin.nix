{ userName, ... }:

{
  imports = [ ./common.nix ];

  home.homeDirectory = "/Users/${userName}";

  programs.nushell.shellAliases.rebuild =
    "sudo darwin-rebuild switch --flake ~/Documents/nix-config#MBA";
}
