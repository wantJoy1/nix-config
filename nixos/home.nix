{
  config,
  lib,
  pkgs,
  osConfig,
  userName,
  ...
}:

{
  home = {
    username = userName;
    homeDirectory = osConfig.users.users.${userName}.home;
    stateVersion = "25.11";

    packages = with pkgs; [
      fzf
      ripgrep
      fd
      bat
      eza
      lazygit
      nufmt
      (writers.writePython3Bin "pixiv-bookmark" {
        libraries = [ (python3Packages.toPythonModule gallery-dl) ];
      } (builtins.readFile ./gallery-dl/pixiv_bookmark.py))
      obsidian
      google-chrome
      claude-code
      opencode
      herdr
      kdePackages.kate
      kdePackages.konsole
    ];
  };

  programs = {
    atuin.enable = true;

    carapace.enable = true;

    firefox = {
      enable = true;
      configPath = ".config/mozilla/firefox";
    };

    gallery-dl = {
      enable = true;
      settings = lib.importJSON ./gallery-dl/config.json;
    };

    gh = {
      enable = true;
      settings.git_protocol = "https";
    };

    git = {
      enable = true;
      settings.user = {
        name = "wantJoy1";
        email = "wantjoy1@gmail.com";
      };
    };

    helix = {
      enable = true;
      settings.theme = "base16_transparent";
    };

    jujutsu = {
      enable = true;
      settings.user = {
        name = "wantJoy1";
        email = "wantjoy1@gmail.com";
      };
    };

    nushell = {
      enable = true;
      extraConfig = ''
        ${builtins.readFile ./nushell/custom.nu}
        ${builtins.readFile ./nushell/fanbox/fanbox_payments.nu}
      '';
      shellAliases.rebuild = "sudo nixos-rebuild switch --flake ${config.home.homeDirectory}/Documents/nix-config#${osConfig.networking.hostName}";
      environmentVariables.EDITOR = "hx";
    };

    plasma = {
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

    starship.enable = true;

    yt-dlp = {
      enable = true;
      extraConfig = builtins.readFile ./yt-dlp/config;
    };

    zoxide.enable = true;
  };
}
