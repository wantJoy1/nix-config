{ pkgs, ... }:

let
  # Kamoso bundles no PipeWire GStreamer plugin, so its GstDeviceMonitor can't see
  # the libcamera softISP cameras (system.nix). Add libgstpipewire.so to its path.
  kamoso = pkgs.symlinkJoin {
    name = "kamoso-pipewire";
    paths = [ pkgs.kdePackages.kamoso ];
    nativeBuildInputs = [ pkgs.makeBinaryWrapper ];
    postBuild = ''
      wrapProgram $out/bin/kamoso \
        --prefix GST_PLUGIN_SYSTEM_PATH_1_0 : ${pkgs.pipewire}/lib/gstreamer-1.0
    '';
  };
in
{
  home.packages = [ kamoso ];

  xdg.configFile."fcitx5/profile".text = ''
    [Groups/0]
    Name=デフォルト
    Default Layout=jp-dvorak
    DefaultIM=skk

    [Groups/0/Items/0]
    Name=skk
    Layout=

    [GroupOrder]
    0=デフォルト
  '';
}
