{ ... }:

{
  imports = [ ./hardware.nix ];

  networking.hostName = "HX100G";

  # Pin to the release of the initial install; do not change post-install.
  system.stateVersion = "25.11";
}
