{ ... }:

{
  imports = [ ./hardware.nix ];

  networking.hostName = "GPDP3";

  system.stateVersion = "25.11";
}
