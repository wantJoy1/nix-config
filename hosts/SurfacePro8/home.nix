{ ... }:

{
  xdg.configFile."fcitx5/profile".text = ''
    [Groups/0]
    Name=デフォルト
    Default Layout=jp-dvorak
    DefaultIM=skk

    [Groups/0/Items/0]
    Name=skk
    Layout=

    [GroupOrder]
    0=デフォルト
  '';
}
