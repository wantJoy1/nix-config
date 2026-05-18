{ pkgs, userName, ... }:
{
  system.stateVersion = 6;
  system.primaryUser = userName;

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
