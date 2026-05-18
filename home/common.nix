{ userName, ... }:

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
  };
}
