# firefox-gallery-dl

Firefox の右クリック (ページ / リンク / 選択テキスト) の URL に対し、
native messaging 経由でホストの `gallery-dl` を実行する WebExtension。

## アーキテクチャ

```
右クリック → 拡張 (URL 抽出)
          → native messaging (connectNative + port)
          → host.nu
          → gallery-dl -- <url>
```

拡張は **URL のみ**を渡す。DL 先 / cookie / 命名 / サイト別ルールは
`nixos/gallery-dl/config.json` が所有し、拡張は実行設定に関与しない。

## 設計判断

| 項目 | 決定 | 理由 |
|---|---|---|
| 配布 | AMO self-sign + 通常版 Firefox | 通常版は未署名拡張を拒否 (policies の `file://` でも署名チェックは走る) |
| 拡張形式 | MV3 非永続 background (event page) | Firefox は `background.scripts`。`service_worker` 非対応 |
| メッセージング | connection-based (`connectNative` + port) | 「開始」+「完了/失敗」を両方通知するため。`sendNativeMessage` は 1 往復のみで不可 |
| host 言語 | Nushell | 長さ prefix を `dd bs=1` で正確に読み、`do {…} \| complete` で gallery-dl の出力を通信路から隔離しつつ stderr を失敗通知に流用 |
| ビルド | TypeScript → `deno bundle --format iife` | 出力を IIFE にして classic background script として読ませる (top-level `export` を残さない)。esbuild 不要 |

## 確定値 (複数ファイルで一致が必須)

- 拡張 ID: `gallery-dl-context@wantjoy1.github.io` (`manifest.json` / `default.nix` / native host の `allowed_extensions`)
- Native Host 名: `org.wantjoy.gallery_dl`

## バージョン更新手順 (要 AMO API 鍵)

拡張を変更したら `extension/` で:

1. `deno task test` / `deno task check` で確認。
2. `manifest.json` の `version` を上げる (AMO は同一バージョン再署名を拒否)。
3. `deno task bundle` で `background.js` を生成。
4. 署名 (自己配布 unlisted。ソースは同梱しない):
   ```
   web-ext sign --channel=unlisted --api-key=… --api-secret=… \
     --ignore-files background.ts background.test.ts deno.json deno.lock
   ```
5. `mv web-ext-artifacts/*.xpi ../gallery-dl-context.xpi` → `git add` (flake は git 追跡ファイルのみ参照)。
6. `nixos-rebuild switch` 後、Firefox を再起動してポリシーを再読込。

## 留意点

- cookie は config の `"cookies": ["firefox"]`。ロックは gallery-dl 側が処理する。
- 中断 UI は無い。停止するには gallery-dl プロセスを kill する (`pkill -f gallery-dl-wrapped`)。DL は archive で再開可能。
