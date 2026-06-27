{ herdr, ... }:

{
  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [ herdr.overlays.default ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
