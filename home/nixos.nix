{ pkgs, userName, ... }:

{
  imports = [ ./common.nix ];

  home.homeDirectory = "/home/${userName}";

  home.packages = with pkgs; [
    obsidian
    claude-code
    kdePackages.kate
  ];

  programs.firefox = {
    enable = true;
    configPath = ".config/mozilla/firefox";
  };

  programs.nushell = {
    shellAliases.rebuild =
      "sudo nixos-rebuild switch --flake ~/Documents/nix-config#MinibookXN100";
    environmentVariables.EDITOR = "kate";
  };

  programs.plasma = {
    enable = true;
    workspace.lookAndFeel = "org.kde.breezedark.desktop";
    configFile.kxkbrc.Layout = {
      Options = "ctrl:nocaps";
      ResetOldOptions = true;
    };
  };

  xdg.configFile."fcitx5/profile".text = ''
    [Groups/0]
    Name=デフォルト
    Default Layout=us-dvorak
    DefaultIM=skk

    [Groups/0/Items/0]
    Name=skk
    Layout=

    [GroupOrder]
    0=デフォルト
  '';

  programs.konsole = {
    enable = true;
    defaultProfile = "Nushell";
    profiles.Nushell = {
      name = "Nushell";
      command = "${pkgs.nushell}/bin/nu";
    };
  };
}
