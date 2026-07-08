#!/usr/bin/env nu

def read-message [] {
  let len_bytes = (^dd bs=1 count=4 e> /dev/null | into binary)
  if (($len_bytes | bytes length) < 4) { return null }
  let len = ($len_bytes | into int --endian little)
  ^dd bs=1 $"count=($len)" e> /dev/null | into binary | decode utf-8 | from json
}

def send-message [msg: record] {
  let data = ($msg | to json -r | into binary)
  let prefix = (($data | bytes length) | into binary --endian little | bytes at 0..<4)
  ($prefix ++ $data) | ^cat
}

def main [] {
  let msg = (try { read-message } catch { {} })
  if $msg == null { return }
  let url = (try { $msg.url? } catch { null })
  if ($url | is-empty) {
    send-message {status: "failed", code: -1, error: "no url"}
    return
  }
  let bin = ($env.GALLERY_DL_BIN? | default "gallery-dl")
  send-message {status: "started"}
  let result = (try { do { ^$bin -- $url } | complete } catch {|err| {exit_code: -1, stderr: $err.msg} })
  if $result.exit_code == 0 {
    send-message {status: "done"}
  } else {
    let error = ($result.stderr | str trim | lines | last 1 | str join)
    send-message {status: "failed", code: $result.exit_code, error: $error}
  }
}
