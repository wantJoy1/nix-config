{ pkgs, userName, ... }:
{
  system.stateVersion = 6;
  system.primaryUser = userName;

  users.users.${userName} = {
    name = userName;
    home = "/Users/${userName}";
  };

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
