import { assertEquals } from "jsr:@std/assert";
import { formatNotification, pickUrl } from "./background.ts";

Deno.test("pickUrl routes each context to its URL field", () => {
  const cases = [
    [{ menuItemId: "gallery-dl-page", pageUrl: "https://e/p" }, "https://e/p"],
    [{ menuItemId: "gallery-dl-link", linkUrl: "https://e/l" }, "https://e/l"],
    [{ menuItemId: "gallery-dl-image", srcUrl: "https://e/i.jpg" }, "https://e/i.jpg"],
  ] as const;
  for (const [info, expected] of cases) assertEquals(pickUrl(info), expected);
});

Deno.test("pickUrl trims selection text", () => {
  assertEquals(pickUrl({ menuItemId: "gallery-dl-selection", selectionText: "  https://x  " }), "https://x");
});

Deno.test("pickUrl returns null for blank selection", () => {
  assertEquals(pickUrl({ menuItemId: "gallery-dl-selection", selectionText: "   " }), null);
});

Deno.test("pickUrl returns null for unknown menu id", () => {
  assertEquals(pickUrl({ menuItemId: "other", pageUrl: "https://e" }), null);
});

Deno.test("formatNotification maps started/done to their titles", () => {
  assertEquals(formatNotification("u", { status: "started" }).title, "gallery-dl 開始");
  assertEquals(formatNotification("u", { status: "done" }).title, "gallery-dl 完了");
});

Deno.test("formatNotification failed renders code/error and falls back when absent", () => {
  assertEquals(formatNotification("u", { status: "failed", code: 1, error: "boom" }).message, "u\n(exit 1: boom)");
  assertEquals(formatNotification("u", { status: "failed" }).message, "u\n(exit ?)");
});
