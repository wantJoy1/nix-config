{
  pkgs,
  lib,
  userName,
  herdr,
  ...
}:

{
  nixpkgs = {
    config.allowUnfree = true;
    overlays = [ herdr.overlays.default ];
  };
  nix = {
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    optimise.automatic = true;
  };

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    # mkDefault so a host can override (e.g. the linux-surface kernel on SurfacePro8).
    kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
  };

  networking.networkmanager.enable = true;

  # eno1 と wlp6s0 が同一セグメント (192.168.0.0/24) に居るため、Linux の弱い
  # ホストモデルのままだと ARP flux が起きる。wlp6s0 の IP に対しても eno1 側で
  # ARP 応答してしまい、ルータが「その IP は有線ポートの先」と学習して無線宛の
  # IPv4 をケーブル側へ送ってしまう (結果、無線だけだと IPv4 が通らない)。
  # ARP 応答は受信インターフェース上の自分のアドレスに限定し、送信元アドレスは
  # 送信インターフェースのものを使うようにする。
  boot.kernel.sysctl = {
    "net.ipv4.conf.all.arp_ignore" = 1;
    "net.ipv4.conf.all.arp_announce" = 2;
    "net.ipv4.conf.default.arp_ignore" = 1;
    "net.ipv4.conf.default.arp_announce" = 2;
  };

  time.timeZone = "Asia/Tokyo";

  i18n = {
    defaultLocale = "ja_JP.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "ja_JP.UTF-8";
      LC_IDENTIFICATION = "ja_JP.UTF-8";
      LC_MEASUREMENT = "ja_JP.UTF-8";
      LC_MONETARY = "ja_JP.UTF-8";
      LC_NAME = "ja_JP.UTF-8";
      LC_NUMERIC = "ja_JP.UTF-8";
      LC_PAPER = "ja_JP.UTF-8";
      LC_TELEPHONE = "ja_JP.UTF-8";
      LC_TIME = "ja_JP.UTF-8";
    };
    inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5 = {
        addons = with pkgs; [
          fcitx5-mozc
          fcitx5-skk
        ];
        waylandFrontend = true;
        settings.addons.skk.globalSection.InitialInputMode = "Latin";
      };
    };
  };

  services = {
    tailscale.enable = true;
    displayManager.sddm.enable = true;
    desktopManager.plasma6.enable = true;
    xserver.xkb = {
      layout = "us";
      variant = "";
    };
    printing.enable = true;
    pulseaudio.enable = false;
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
    };
  };

  programs = {
    kdeconnect.enable = true;
    steam = {
      enable = true;
      extraCompatPackages = [ pkgs.proton-ge-bin ];
      fontPackages = [ pkgs.noto-fonts-cjk-sans ];
    };
  };

  virtualisation.waydroid.enable = true;

  security.rtkit.enable = true;

  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    keyboard.qmk.enable = true;
  };

  users.users.${userName} = {
    isNormalUser = true;
    description = userName;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.nushell;
  };
  environment.shells = [ pkgs.nushell ];

  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
      udev-gothic-nf
    ];
    fontconfig.defaultFonts = {
      serif = [
        "Noto Serif CJK JP"
        "Noto Serif"
      ];
      sansSerif = [
        "Noto Sans CJK JP"
        "Noto Sans"
      ];
      monospace = [
        "UDEV Gothic NF"
        "Noto Sans Mono CJK JP"
        "Noto Sans Mono"
      ];
      emoji = [ "Noto Color Emoji" ];
    };
  };
}
