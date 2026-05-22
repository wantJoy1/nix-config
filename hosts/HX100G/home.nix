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

  # s2idle is broken on this machine: amdgpu's SMU IP block fails to
  # resume (`resume of IP block <smu> failed -62`), the GPU wedges, and
  # even ssh-initiated reboot fails afterwards. BIOS 0.18 (2023-09-25)
  # is the final firmware MinisForum publishes for HX100G — the SMU
  # firmware is bundled with it — and `amdgpu.dcdebugmask=0x10` was
  # tried as a kernel-side workaround and made no difference. Keep
  # auto-suspend off and do not manually suspend either. Display-off
  # (DPMS) works fine; don't conflate it with this bug.
  programs.plasma.powerdevil.AC.autoSuspend.action = "nothing";
}
