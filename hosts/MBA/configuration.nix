{ pkgs, ... }:
{
  system.stateVersion = 6;
  system.primaryUser = "wantjoy";

  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.systemPackages = with pkgs; [
    git
    gh
    nushell
    claude-code
  ];

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = false;
      upgrade = false;
    };
    casks = [
      "firefox"
      "claude"
    ];
  };

  programs.zsh.enable = true;
}
