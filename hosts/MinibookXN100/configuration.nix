{ ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # The DSI-1 panel is mounted with its right side physically up.
  # i915 ignores panel_orientation= for this DSI panel, so rotate the
  # framebuffer console directly (90° clockwise).
  boot.kernelParams = [ "fbcon=rotate:1" ];

  networking.hostName = "MinibookXN100";

  # Pin to the release of the initial install; do not change post-install.
  system.stateVersion = "25.11";
}
