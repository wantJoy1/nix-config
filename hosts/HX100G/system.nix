{ ... }:

{
  imports = [ ./hardware.nix ];

  networking.hostName = "HX100G";

  services.openssh.enable = true;

  # Pin to the release of the initial install; do not change post-install.
  system.stateVersion = "25.11";
}
