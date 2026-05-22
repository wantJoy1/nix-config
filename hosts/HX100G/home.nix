{ ... }:

{
  xdg.configFile."fcitx5/profile".text = ''
    [Groups/0]
    Name=デフォルト
    Default Layout=us
    DefaultIM=skk

    [Groups/0/Items/0]
    Name=skk
    Layout=

    [GroupOrder]
    0=デフォルト
  '';

  # Suspend/resume is broken on this machine; disable powerdevil's idle
  # auto-suspend until the wake bug is investigated.
  programs.plasma.powerdevil.AC.autoSuspend.action = "nothing";

  # TEMPORARY: shortened to reproduce the display-off wake bug quickly.
  # Revert (remove this line) once the root cause is identified.
  programs.plasma.powerdevil.AC.turnOffDisplay.idleTimeout = 120;
}
