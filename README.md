# nix-config

NixOS flake-based 個人設定。`/etc/nixos/` を使わず `~/Documents/nix-config` 配下で完結する構成。

## Bootstrap

private repo なので `gh` 経由で取得する。クローン先パスは固定 (`home.nix` の rebuild alias が参照)。

```sh
nix-shell -p gh
gh auth login
gh repo clone wantJoy1/nix-config ~/Documents/nix-config
```

## 再インストール時

ディスク UUID やカーネルモジュール構成が変わるため、hardware-configuration を作り直す。

```sh
nixos-generate-config --show-hardware-config > hosts/<hostname>/hardware-configuration.nix
```
