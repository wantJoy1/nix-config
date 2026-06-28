{ config, lib, pkgs, osConfig, userName, ... }:

{
  home.username = userName;
  home.homeDirectory = osConfig.users.users.${userName}.home;
  home.stateVersion = "25.11";

  home.packages = with pkgs; [
    fzf
    ripgrep
    fd
    bat
    eza
    lazygit
    msedit
    nufmt
    (writers.writePython3Bin "pixiv-bookmark" {
      libraries = [ (python3Packages.toPythonModule gallery-dl) ];
    } (builtins.readFile ./gallery-dl/pixiv_bookmark.py))
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

  programs.carapace.enable = true;
  programs.atuin.enable = true;
  programs.zoxide.enable = true;
  programs.starship.enable = true;

  programs.git = {
    enable = true;
    settings.user = {
      name = "wantJoy1";
      email = "wantjoy1@gmail.com";
    };
  };

  programs.jujutsu = {
    enable = true;
    settings.user = {
      name = "wantJoy1";
      email = "wantjoy1@gmail.com";
    };
  };

  programs.gh = {
    enable = true;
    settings.git_protocol = "https";
  };

  programs.yt-dlp = {
    enable = true;
    extraConfig = builtins.readFile ./yt-dlp/config;
  };

  programs.gallery-dl = {
    enable = true;
    settings = lib.importJSON ./gallery-dl/config.json;
  };

  programs.nushell = {
    enable = true;
    extraConfig = builtins.readFile ./nushell/custom.nu;
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
