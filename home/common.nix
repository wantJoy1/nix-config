{ config, lib, osConfig, userName, ... }:

{
  home.username = userName;
  home.stateVersion = "25.11";

  programs.git = {
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

  programs.nushell = {
    enable = true;
    extraConfig = "$env.config.show_banner = false";
    # systemPath is nix-darwin-only; NixOS exports PATH via the session.
    extraEnv = lib.optionalString (osConfig.environment ? systemPath) ''
      $env.PATH = ("${builtins.replaceStrings
        [ "$USER" "$HOME" ]
        [ config.home.username config.home.homeDirectory ]
        osConfig.environment.systemPath}" | split row (char esep))
    '';
  };
}
