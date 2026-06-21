{ ... }:

{
  imports = [ ./hardware.nix ];

  networking.hostName = "SurfacePro8";

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
