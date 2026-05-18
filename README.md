# nix-config

NixOS と macOS（nix-darwin）の個人設定を 1 つの flake で管理。

## 構成

```
flake.nix                                   # 両 OS 共通入口
flake.lock
home.nix                                    # NixOS 用 home-manager 設定（kf）
hosts/
  MinibookXN100/                            # NixOS, x86_64-linux
    configuration.nix
    hardware-configuration.nix
  MBA/                                      # nix-darwin, aarch64-darwin
    configuration.nix
```

Mac 側の GUI アプリ（Firefox, Claude Desktop）は `homebrew.casks` で宣言。Homebrew そのものは事前インストールが必要（nix-darwin はパッケージ管理のみ）。

## Bootstrap (NixOS)

private repo なので `gh` 経由で取得する。クローン先パスは固定 (`home.nix` の rebuild alias が参照)。

```sh
nix-shell -p gh
gh auth login
gh repo clone wantJoy1/nix-config ~/Documents/nix-config
```

### 再インストール時

ディスク UUID やカーネルモジュール構成が変わるため、hardware-configuration を作り直す。

```sh
nixos-generate-config --show-hardware-config > hosts/<hostname>/hardware-configuration.nix
```

## Bootstrap (macOS, nix-darwin)

「すべてのコンテンツと設定を消去」した直後の Mac を想定。

### 前提

- セットアップアシスタントで **短い名前を `wantjoy`** にして初回ユーザーを作成済み
- 管理者権限のあるアカウントでログイン中

### 1. Nix をインストール

```sh
sh <(curl -L https://nixos.org/nix/install) --daemon
```

完了後、新しいシェルを開く。

### 2. Homebrew をインストール

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Apple Silicon の場合 `/opt/homebrew/bin/brew` に入る。`.zprofile` 設定はスキップ（nix-darwin は brew をフルパスで呼ぶし、Nushell ユーザーなので zsh 設定は不要）。

### 3. このリポジトリを clone

```sh
nix-shell -p gh --extra-experimental-features 'nix-command flakes'
gh auth login
gh repo clone wantJoy1/nix-config ~/Documents/nix-config
cd ~/Documents/nix-config
```

### 4. hostname を設定

flake のホストキー（`MBA`）と一致させる。

```sh
sudo scutil --set LocalHostName MBA
sudo scutil --set ComputerName MBA
sudo scutil --set HostName MBA
```

### 5. nix-darwin をブートストラップ＆設定適用

```sh
sudo nix run --extra-experimental-features 'nix-command flakes' \
  nix-darwin/master#darwin-rebuild -- switch --flake .#MBA
```

**初回 switch でよくあるエラー**: `/etc/bashrc`, `/etc/zshrc`, `/etc/nix/nix.conf` が既存だと弾かれる。出たら以下でリネームしてから再実行：

```sh
sudo mv /etc/bashrc /etc/bashrc.before-nix-darwin
sudo mv /etc/zshrc /etc/zshrc.before-nix-darwin
sudo mv /etc/nix/nix.conf /etc/nix/nix.conf.before-nix-darwin
```

### 6. 動作確認

```sh
which git gh nu claude       # /run/current-system/sw/bin/...
ls /Applications/Firefox.app /Applications/Claude.app
```

## 日常の運用

NixOS:

```sh
sudo nixos-rebuild switch --flake .#MinibookXN100
```

macOS:

```sh
sudo darwin-rebuild switch --flake .#MBA
```

flake.lock 更新:

```sh
nix flake update
```
