/// <reference types="npm:@types/firefox-webext-browser" />

export const HOST = "org.wantjoy.gallery_dl";

interface HostMessage {
  status: "started" | "done" | "failed";
  code?: number;
  error?: string;
}

export const MENU_ITEMS: {
  id: string;
  title: string;
  contexts: browser.contextMenus.ContextType[];
}[] = [
  { id: "gallery-dl-page", title: "gallery-dl: このページ", contexts: ["page"] },
  { id: "gallery-dl-link", title: "gallery-dl: このリンク", contexts: ["link"] },
  { id: "gallery-dl-selection", title: "gallery-dl: 選択中のURL", contexts: ["selection"] },
];

type ClickInfo = Pick<
  browser.contextMenus.OnClickData,
  "menuItemId" | "pageUrl" | "linkUrl" | "selectionText"
>;

export function pickUrl(info: ClickInfo): string | null {
  switch (info.menuItemId) {
    case "gallery-dl-page":
      return info.pageUrl ?? null;
    case "gallery-dl-link":
      return info.linkUrl ?? null;
    case "gallery-dl-selection": {
      const selected = (info.selectionText ?? "").trim();
      return selected.length > 0 ? selected : null;
    }
    default:
      return null;
  }
}

export function formatNotification(
  url: string,
  msg: HostMessage,
): { title: string; message: string } {
  switch (msg.status) {
    case "started":
      return { title: "gallery-dl 開始", message: url };
    case "done":
      return { title: "gallery-dl 完了", message: url };
    case "failed":
      return {
        title: "gallery-dl 失敗",
        message: `${url}\n(exit ${msg.code ?? "?"}${msg.error ? `: ${msg.error}` : ""})`,
      };
  }
}

function notify(body: { title: string; message: string }): void {
  browser.notifications.create({ type: "basic", ...body });
}

function runGalleryDl(url: string): void {
  const port = browser.runtime.connectNative(HOST);
  port.onMessage.addListener((msg) => {
    const m = msg as HostMessage;
    notify(formatNotification(url, m));
    if (m.status !== "started") port.disconnect();
  });
  port.onDisconnect.addListener((p) => {
    if (p.error) notify({ title: "gallery-dl エラー", message: `${url}\n${p.error.message}` });
  });
  port.postMessage({ url });
}

if (typeof browser !== "undefined") {
  browser.runtime.onInstalled.addListener(() => {
    browser.contextMenus.removeAll().then(() => {
      for (const item of MENU_ITEMS) browser.contextMenus.create(item);
    });
  });
  browser.contextMenus.onClicked.addListener((info) => {
    const url = pickUrl(info);
    if (url) runGalleryDl(url);
  });
}
