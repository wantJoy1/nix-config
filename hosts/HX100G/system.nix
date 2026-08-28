{ ... }:

{
  imports = [ ./hardware.nix ];

  networking.hostName = "HX100G";

  # Tailscale SSH intercepts tailnet port 22, so distributed builds can't use
  # openssh key auth there. Expose a second port that reaches openssh directly.
  services.openssh = {
    enable = true;
    ports = [
      22
      2201
    ];
  };

  # Accept the SurfacePro8 nix-daemon (root) builder key for remote builds.
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAoiAVaaxxhBouZsVGT9Fpt3kLe5yb2TEvf1aUcMkcNQ nix-remote-builder@SurfacePro8"
  ];

  # Pin to the release of the initial install; do not change post-install.
  system.stateVersion = "25.11";
}
