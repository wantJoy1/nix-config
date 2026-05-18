{ ... }:

{
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
}
