{ ... }:

{
  imports = [ ./hardware.nix ];

  networking.hostName = "SurfacePro8";

  # Offload builds to HX100G over Tailscale. The nix-daemon (root) connects with
  # a dedicated key on HX100G's non-tailscale openssh port; install the matching
  # private key at sshKey (see repo docs) once.
  nix = {
    distributedBuilds = true;
    settings.builders-use-substitutes = true;
    buildMachines = [
      {
        hostName = "hx100g-1";
        sshUser = "root";
        sshKey = "/root/.ssh/nix-remote-builder";
        protocol = "ssh-ng";
        systems = [ "x86_64-linux" ];
        maxJobs = 8;
        speedFactor = 2;
        supportedFeatures = [
          "big-parallel"
          "kvm"
          "nixos-test"
          "benchmark"
        ];
      }
    ];
  };

  # nix-daemon runs as root; point root's ssh at HX100G's openssh port (22 is
  # taken by Tailscale SSH) and trust-on-first-use for the host key.
  programs.ssh.extraConfig = ''
    Host hx100g-1
      Port 2201
      StrictHostKeyChecking accept-new
  '';

  # Cameras via the libcamera softISP path, not `hardware.ipu6`: Intel's
  # proprietary HAL has no tuning for the Pro 8's ov5693/ov13858 sensors and only
  # crash-loops, so the linux-surface kernel's IPU6 ISYS drivers feed libcamera,
  # which PipeWire exposes through its built-in libcamera SPA plugin. Hide the raw
  # ISYS v4l2 nodes so apps pick those cameras, not the unusable raw Bayer nodes.
  services.pipewire.wireplumber.extraConfig."10-ipu6-hide-raw-v4l2" = {
    "monitor.v4l2.rules" = [
      {
        matches = [ { "device.product.name" = "ipu6"; } ];
        actions = {
          "update-props" = {
            "device.disabled" = true;
          };
        };
      }
    ];
  };

  # Pin to the release of the initial install; do not change post-install.
  system.stateVersion = "25.11";
}
