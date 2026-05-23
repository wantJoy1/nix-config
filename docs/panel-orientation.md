# Panel orientation — メモ

## KWin が DRM `panel_orientation` を honor する仕組み

[`OutputConfigurationStore::queryConfig`](https://invent.kde.org/plasma/kwin/-/blob/master/src/outputconfigurationstore.cpp) の transform 決定優先順位:

1. `~/.config/kwinoutputconfig.json` の保存値
2. kscreen daemon の change request
3. DRM `panel_orientation`

保存値が無ければ kernel patch だけで Plasma も自動回転する。

## 再現実験の落とし穴

KWin のデストラクタが必ず `save()` を呼ぶ。実行中に `kwinoutputconfig.json` を消しても shutdown 時に書き戻る。**fallback を効かせるには KWin 停止後に削除**。

## 出典

- [Wayland `wl_output.transform`](https://gitlab.freedesktop.org/wayland/wayland/-/blob/main/protocol/wayland.xml)
- [DRM `enum drm_panel_orientation`](https://gitlab.freedesktop.org/drm/kernel/-/blob/drm-next/include/drm/drm_connector.h)
- KWin panel_orientation 対応 MR: [!2081](https://invent.kde.org/plasma/kwin/-/merge_requests/2081)
- 現行 fallback ロジック: [commit 79490324](https://invent.kde.org/plasma/kwin/-/commit/7949032411153ebf9d87b0e936b1bc288df12b38) / [bug 485353](https://bugs.kde.org/show_bug.cgi?id=485353)
