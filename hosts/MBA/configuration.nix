{ pkgs, userName, ... }:
{
  system.stateVersion = 6;
  system.primaryUser = userName;

  users.users.${userName} = {
    name = userName;
    home = "/Users/${userName}";
  };

  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.systemPackages = with pkgs; [
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
