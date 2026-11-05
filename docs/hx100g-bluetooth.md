# HX100G の Bluetooth (MT7927)

BT 側 (USB `0e8d:6639`) は `mediatek/mt7927/BT_RAM_CODE_MT6639_2_1_hdr.bin` を要求するが、linux-firmware には Wi-Fi 側のブロブしか無い。無いと `Failed to load firmware file (-2)` と USB リセットを繰り返し、`hci0` が上がらない。

`pkgs/mt7927-bt-firmware` は ASUS 配布の Windows ドライバ ZIP 内の `mtkwlan.dat` からブロブを切り出している。再配布の許可は確認できないので `unfree` 扱い。

linux-firmware への追加は MediaTek 本人の提出待ち ([MR !946](https://gitlab.com/kernel-firmware/linux-firmware/-/merge_requests/946) は close)。上流に入ったらパッケージごと消す。

## ZIP を更新するとき

`mtkwlan.dat` のエントリは、NUL 終端の名前、NUL パディング、14 桁のビルド日時、4 バイト境界に揃えた LE u32 の offset と size の順に並ぶ。`blobOffset` と `blobSize` はここから取り直す。

## 注意

- ブロブの無い世代へ戻すとリセットループが再発する。チップが固まって `lsusb` から消えたら、BIOS の ErP を有効にするか電源を抜いて待機電力を切る。
- ZIP も未圧縮の出力もシステムの closure に含まれないので、GC 後の再ビルドには ASUS の配布 URL が要る。
