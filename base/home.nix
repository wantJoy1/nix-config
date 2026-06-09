{ config, lib, pkgs, osConfig, userName, ... }:

{
  home.username = userName;
  home.stateVersion = "25.11";

  home.packages = with pkgs; [
    fzf
    ripgrep
    fd
    bat
    eza
    lazygit
    msedit
  ];

  # Nushell-integrated tools (primary shell on all hosts); the home-manager
  # modules wire their Nushell init automatically.
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
    # systemPath is nix-darwin-only; NixOS exports PATH via the session.
    extraEnv = lib.optionalString (osConfig.environment ? systemPath) ''
      $env.PATH = ("${builtins.replaceStrings
        [ "$USER" "$HOME" ]
        [ config.home.username config.home.homeDirectory ]
        osConfig.environment.systemPath}" | split row (char esep))
    '';
  };
}
