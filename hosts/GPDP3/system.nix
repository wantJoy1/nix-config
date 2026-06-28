{ ... }:

{
  imports = [ ./hardware.nix ];

  boot.kernelPatches = [
    {
      name = "gpd-pocket-3-panel-orientation";
      patch = ./kernel-patches/gpd-pocket-3-panel-orientation.patch;
    }
  ];

  # systemd-boot menu has no rotation API; hide it. Hold a key at boot to show.
  boot.loader.timeout = 0;

  networking.hostName = "GPDP3";

  system.stateVersion = "25.11";
}
