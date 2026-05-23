{ ... }:

{
  imports = [ ./hardware.nix ];

  boot.kernelPatches = [{
    name = "chuwi-minibook-x-panel-orientation";
    patch = ./kernel-patches/chuwi-minibook-x-panel-orientation.patch;
  }];

  networking.hostName = "MinibookXN100";

  # Pin to the release of the initial install; do not change post-install.
  system.stateVersion = "25.11";
}
