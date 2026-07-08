# firefox-gallery-dl

Firefox の右クリック (ページ / リンク / 画像 / 選択テキスト) で、その URL に対し
ホスト上の `gallery-dl` を実行する WebExtension。

## アーキテクチャ

```
右クリック → WebExtension (URL 抽出)
          → Native Messaging (connectNative + port)
          → host.nu
          → gallery-dl <url>
```

拡張は **URL のみ**を渡す。DL 先 / cookie / archive / サイト別ルールは
`nixos/gallery-dl/config.json` が所有し、拡張は実行設定に関与しない。

## 設計判断

| 項目 | 決定 | 理由 |
|---|---|---|
| 配布 | AMO self-sign + 通常版 Firefox | 通常版は未署名拡張を拒否 (policies の `file://` でも署名チェックは走る) |
| 拡張形式 | MV3 非永続 background (event page) | Firefox は `background.scripts`。`service_worker` 非対応 |
| メッセージング | connection-based (`connectNative` + port) | 「開始」+「完了/失敗」を両方通知するため。`sendNativeMessage` は 1 往復のみで不可 |
| host 言語 | Nushell | 長さ prefix を `dd bs=1` で正確に読み、`do {…} | complete` で gallery-dl の stdout を通信路から隔離 |
| ビルド | TypeScript → `deno bundle` | Deno 2.4+ で `bundle` 復活。esbuild 別途不要 |

## 確定値 (変更不可・複数ファイルで一致が必要)

- 拡張 ID: `gallery-dl-context@wantjoy1.github.io` (AMO submit 後は固定)
- Native Host 名: `org.wantjoy.gallery_dl`

## 残作業 (要 AMO アカウント)

1. `deno task bundle` で `background.js` を生成。
2. `web-ext sign --api-key=… --api-secret=…` で署名済み `.xpi` を取得 (バージョンは毎回上げる)。
3. `.xpi` を `gallery-dl-context.xpi` に置き `git add` (flake は git 追跡ファイルのみ参照)。
4. `nixos-rebuild switch`。

## 留意点

- `cookies.sqlite` のロックは gallery-dl 側が処理する。
- host は gallery-dl 終了まで待機するため、Firefox 終了で DL は中断する (許容)。
