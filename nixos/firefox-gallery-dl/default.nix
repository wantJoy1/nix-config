{ lib, pkgs, ... }:

let
  extensionId = "gallery-dl-context@wantjoy1.github.io";
  hostName = "org.wantjoy.gallery_dl";

  hostWrapper = pkgs.writeShellScript "gallery-dl-host-wrapper" ''
    export GALLERY_DL_BIN=${pkgs.gallery-dl}/bin/gallery-dl
    export PATH=${pkgs.coreutils}/bin:$PATH
    exec ${pkgs.nushell}/bin/nu ${./host.nu}
  '';

  xpi = ./gallery-dl-context.xpi;
in
{
  home.file.".mozilla/native-messaging-hosts/${hostName}.json".text = builtins.toJSON {
    name = hostName;
    description = "gallery-dl native messaging host";
    path = "${hostWrapper}";
    type = "stdio";
    allowed_extensions = [ extensionId ];
  };

  programs.firefox.policies.ExtensionSettings = lib.mkIf (builtins.pathExists xpi) {
    ${extensionId} = {
      installation_mode = "force_installed";
      install_url = "file://${xpi}";
    };
  };
}
