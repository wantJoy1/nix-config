#!/usr/bin/env nu
# Download SKK dictionaries into macSKK's dictionary directory.

let destination_directory = (
    $env.HOME
    | path join "Library" "Containers" "net.mtgto.inputmethod.macSKK" "Data" "Documents" "Dictionaries"
)
let dictionaries = [
    "SKK-JISYO.L"
    "SKK-JISYO.jinmei"
    "SKK-JISYO.geo"
    "SKK-JISYO.station"
    "SKK-JISYO.propernoun"
]

mkdir $destination_directory

for name in $dictionaries {
    let source_url = $"https://raw.githubusercontent.com/skk-dev/dict/master/($name)"
    let destination_file = ($destination_directory | path join $name)
    ^curl --location --fail --silent --show-error --output $destination_file $source_url
    print $"Saved ($destination_file)"
}

print "Enable them in macSKK Settings → 辞書."
