# FANBOXSESSID は Firefox の Cookie ストアから取得する。
# 事前条件: Firefox で www.fanbox.cc にログイン済みであること。

def fetch_fanbox_payments [] {
    # Firefox 起動中は cookies.sqlite がロックされるためコピーしてから読む。
    let db = (glob ~/.config/mozilla/firefox/*/cookies.sqlite | first)
    let tmp = (mktemp -t fanbox-cookies-XXXXX.sqlite)
    cp $db $tmp
    let session = (open $tmp | query db "SELECT value FROM moz_cookies WHERE name = 'FANBOXSESSID'" | get value.0?)
    rm -f $tmp
    if ($session | is-empty) {
        error make {msg: "FANBOXSESSID が取得できません。Firefox で www.fanbox.cc にログインしてください"}
    }

    let payments = try {
        http get https://api.fanbox.cc/payment.listPaid --headers {
            Origin: "https://www.fanbox.cc" # Origin ヘッダが無いと API が拒否する
            Cookie: $"FANBOXSESSID=($session)"
        }
    } catch {|error| error make {msg: $"FANBOX API の取得に失敗しました。FANBOXSESSID が期限切れの可能性があります: ($error.msg)"} }
    | get body.payments?
    | default []

    if ($payments | is-empty) {
        error make {msg: "支払いデータが取得できませんでした"}
    }
    $payments
}

def total_by_datetime [] {
    $in
    | group-by --to-table paymentDatetime
    | each {{
        datetime: $in.paymentDatetime
        total: ($in.items.paidAmount | math sum)
        count: ($in.items | length)
      }}
}

def total_by_creator [] {
    $in
    | group-by --to-table creator.creatorId
    | each {{
        creator: ($in.items.creator.user.name | first)
        total: ($in.items.paidAmount | math sum)
        count: ($in.items | length)
      }}
}
