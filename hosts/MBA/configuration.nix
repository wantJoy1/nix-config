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

  security.pam.services.sudo_local.touchIdAuth = true;

  system.defaults = {
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      AppleShowAllExtensions = true;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
    };
    finder.AppleShowAllExtensions = true;
    dock = {
      autohide = true;
      autohide-delay = 0.0;
      show-recents = false;
      mru-spaces = false;
      minimize-to-application = true;
      orientation = "left";
      persistent-apps = [
        "/Applications/Firefox.app"
        "/Applications/Claude.app"
        "/Applications/Ghostty.app"
        "/System/Applications/System Settings.app"
      ];
    };
  };

  nix.gc = {
    automatic = true;
    interval = { Weekday = 0; Hour = 3; Minute = 0; };
    options = "--delete-older-than 30d";
  };

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = false;
      upgrade = false;
    };
    casks = [
      "firefox"
      "claude"
      "ghostty"
    ];
  };

  programs.zsh.enable = true;
}
