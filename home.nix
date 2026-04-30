{ pkgs, ... }:

{
  home.username = "kf";
  home.homeDirectory = "/home/kf";
  home.stateVersion = "25.11";

  home.packages = with pkgs; [
    obsidian
    claude-code
    kdePackages.kate
  ];

  programs.git = {
    enable = true;
    settings.user = {
      name = "wantJoy1";
      email = "wantjoy1@gmail.com";
    };
  };

  programs.nushell = {
    enable = true;
    shellAliases.rebuild = "sudo nixos-rebuild switch --flake /home/kf/Documents/nixos-config#MinibookXN100";
    environmentVariables.EDITOR = "kate";
    extraConfig = "$env.config.show_banner = false";
  };

  programs.gh = {
    enable = true;
    settings.git_protocol = "https";
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
