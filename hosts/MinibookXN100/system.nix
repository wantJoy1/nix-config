{ ... }:

{
  imports = [ ./hardware.nix ];

  boot.kernelPatches = [{
    name = "chuwi-minibook-x-panel-orientation";
    patch = ./kernel-patches/chuwi-minibook-x-panel-orientation.patch;
  }];

  # systemd-boot menu has no rotation API; hide it. Hold a key at boot to show.
  boot.loader.timeout = 0;

  networking.hostName = "MinibookXN100";

  # Pin to the release of the initial install; do not change post-install.
  system.stateVersion = "25.11";
}
