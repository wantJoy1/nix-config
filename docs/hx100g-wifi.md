# HX100G の Wi-Fi

## 2.4GHz は Bluetooth と併用できない (MT7921 時代の記録)

> MT7921 での記録。MT7927 では同じ低下は出ていない (2026-11-05、BLE マウス操作中の 2.4GHz で 99〜119 Mbit/s、RTT 平均 6.3ms)。

BLE 機器 (マウス程度でも) を接続していると 2.4GHz の下りが 1/100 程度まで落ち、RTT は 500ms を超える。IP 層では損失が出ないため「0% loss なのに遅い」形で現れる。

mt7921 の Wi-Fi/BT 共存はファームウェア任せで、ドライバに調整手段が無い。上流に該当チケットは無い。

→ 5GHz を使う。

再確認:

```bash
bluetoothctl disconnect <MAC>
ping -c20 -i0.2 192.168.0.1
curl -o /dev/null -w '%{speed_download}\n' 'https://speed.cloudflare.com/__down?bytes=5000000'
```
