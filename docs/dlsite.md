# DLsite のゲーム — メモ

## 経路は3つある

| 経路 | 対象 | 入口 |
| --- | --- | --- |
| Wine | Windows exe 全般 | `dlsite-run` |
| エンジン別ネイティブ | ツクール MV/MZ・2000/2003、Ren'Py、NScripter | `nw` / `easyrpg-player` / `renpy` / `onscripter` |
| Waydroid | Android 版が併売されている作品 | `waydroid` |

ツクール XP/VX/VX Ace のネイティブ実装 (mkxp-z) は nixpkgs に無いので Wine で動かす。

## Wine

`wineWow64Packages.stagingFull` は新 WoW64 (64bit 単一ビルド)。`WINEARCH=win32` は
`not supported in wow64 mode` で弾かれるが、win64 prefix のまま 32bit exe を実行できる
(Wine 11.14 で `syswow64\cmd.exe` = PE machine 014c の起動を確認)。DLsite 作品の大半が
32bit なので、ここが崩れると全部動かない。

prefix は作成時のシステムロケールから ANSI コードページを決める。`LANG=ja_JP.UTF-8` で作れば
CP932 になる (`HKCU\Software\Wine\Fonts\Codepages` = `932,932`)。

Wine は prefix 生成時に `drive_c/users/<user>/` の Desktop / Documents / Downloads / Music /
Pictures / Videos を実ホームへの symlink にする (Wine 11.14 で確認)。放置するとセーブデータが
実ホームに散る。

## フォント

Wine はシステムの fontconfig フォントを自動で取り込み、`HKCU\Software\Wine\Fonts\External Fonts`
に登録する。`noto-fonts-cjk-sans` / `noto-fonts-cjk-serif` は既に入っているので**フォント
パッケージの追加は要らない**。必要なのは prefix ごとの `FontSubstitutes` だけ。

### 効かなかった方法（再挑戦しないこと）

- **prefix の `drive_c/windows/Fonts` に symlink** — `wineboot --update` 後も
  `HKLM\…\CurrentVersion\Fonts` にも External Fonts にも載らない。取り込み経路は fontconfig 側だけ。
- **IPA フォント (`ipafont`)** — MS ゴシック系と 1:1 対応する書体だが、本文には効くのに
  **メニューバーが豆腐のまま**。UI フォント経路で解決されない。Noto に置換すると解消する。
- **`Tahoma` の FontSubstitutes** — Wine が Tahoma を同梱しているため無効。
  FontSubstitutes は「存在しない書体」にしか効かない。
- **`FontLink\SystemLink`** — `Tahoma` に `Noto Sans CJK JP` を REG_MULTI_SZ で登録しても
  (書体名のみ / `Z:\…\NotoSansCJK-VF.otf.ttc,書体名` の両形式とも) Wine 11.14 では描画が変わらない。

### 残る既知の穴

ゲームが `Tahoma` / `Arial` を明示指定して日本語を描くと豆腐になる。本物の Windows は
フォントリンクで補うが、上記のとおり Wine 側の代替手段が無い。日本語フォント名を指定する
作品 (大半) と、`MS Shell Dlg → MS UI Gothic` を経由する標準ダイアログ・メニューは問題ない。

## ファイルマネージャからの起動

Wine は `wine.desktop` を同梱しており、これが `application/x-ms-dos-executable` を掴む。
`wine.desktop` は常に既定 prefix (`~/.wine`) で実行するため、Dolphin でダブルクリックすると
フォント置換の無い prefix が作られ、しかもそこは Documents / Desktop 等が実ホームへの
symlink のままになる。`xdg.mimeApps` で上書きしておく。

## Waydroid

`psi=1` カーネルパラメータが入るので、有効化後の初回は**再起動してから** `sudo waydroid init`。
system image はここで実行時にダウンロードされる (宣言的ではない)。

## ツクール MV / MZ

同梱の Windows 版 NW.js を使わず、`package.json` のあるディレクトリを Linux 版に渡す。

```sh
nw ~/Games/<作品>/
```

## 出典

- [Wine `FontSubstitutes` / フォント解決](https://gitlab.winehq.org/wine/wine/-/blob/master/dlls/win32u/font.c)
- [New WoW64 (Wine 10.0 release notes)](https://gitlab.winehq.org/wine/wine/-/wikis/Wow64)
- [nixpkgs: `wineWowPackages` は非推奨、`wineWow64Packages` を使う](https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/top-level/aliases.nix)
- [Waydroid](https://docs.waydro.id/)
