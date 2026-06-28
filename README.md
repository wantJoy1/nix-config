# nix-config

NixOS の個人設定を 1 つの flake で管理。

## 構成

2 軸 layer モデル：

- **scope**（合成順、後ほど具体・前を上書き）：`base/` → `nixos/` → `hosts/<NAME>/`
- **concern**：`system.nix`（NixOS module）／ `home.nix`（home-manager module）

合成は `flake.nix` の各ホストブロックで宣言。各 layer dir は必要な concern のファイルだけ持つ。

## Bootstrap (NixOS)

クローン先パスは `~/Documents/nix-config` 固定（rebuild alias がハードコード）。

```sh
nix-shell -p git
git clone https://github.com/wantJoy1/nix-config ~/Documents/nix-config
```

### 再インストール時

インストーラー生成の `/etc/nixos/hardware-configuration.nix` には USB ブート前提のモジュール (`usb_storage`, `sd_mod` 等) が混ざるので、実機で `nixos-generate-config` を回した出力で差し替える。

```sh
nixos-generate-config --show-hardware-config > hosts/<hostname>/hardware.nix
```

### 新規ホストを追加

NixOS を最小構成でインストール・ユーザー作成済み、上記 Bootstrap で clone 済みの状態から：

1. hardware.nix を生成：

   ```sh
   mkdir hosts/<NAME>
   nixos-generate-config --show-hardware-config > hosts/<NAME>/hardware.nix
   ```

2. `hosts/<NAME>/system.nix` を作成（既存ホストをコピーして `hostName` と `stateVersion` を調整）。

3. `flake.nix` に `nixosConfigurations.<NAME>` エントリを追加（同じく既存ホストのブロックをコピー）。

4. 新規ファイルを `git add` する（flake は git-tracked なファイルしか見ない）：

   ```sh
   git add hosts/<NAME>/ flake.nix
   ```

5. 適用：

   ```sh
   sudo nixos-rebuild switch --flake .#<NAME>
   ```

## 日常の運用

```sh
sudo nixos-rebuild switch --flake .#MinibookXN100
```

flake.lock 更新:

```sh
nix flake update
```
