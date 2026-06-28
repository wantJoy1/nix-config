{ config, pkgs, osConfig, userName, ... }:

{
  home.homeDirectory = osConfig.users.users.${userName}.home;

  home.packages = with pkgs; [
    # TODO: 一部はクロスプラットフォームかもしれず base/home.nix へ移せる可能性あり。要整理。
    obsidian
    claude-code
    opencode
    herdr
    kdePackages.kate
  ];

  programs.firefox = {
    enable = true;
    configPath = ".config/mozilla/firefox";
  };

  programs.nushell = {
    shellAliases.rebuild =
      "sudo nixos-rebuild switch --flake ${config.home.homeDirectory}/Documents/nix-config#${osConfig.networking.hostName}";
    environmentVariables.EDITOR = "kate";
  };

  programs.plasma = {
    enable = true;
    workspace.lookAndFeel = "org.kde.breezedark.desktop";
    configFile.kxkbrc.Layout = {
      Options = "ctrl:nocaps";
      ResetOldOptions = true;
    };
    configFile.kwinrc.Wayland.InputMethod = {
      value = "/run/current-system/sw/share/applications/fcitx5-wayland-launcher.desktop";
      immutable = true;
    };
  };

  programs.konsole = {
    enable = true;
    defaultProfile = "Nushell";
    profiles.Nushell = {
      name = "Nushell";
      command = "${pkgs.nushell}/bin/nu";
    };
  };
}
