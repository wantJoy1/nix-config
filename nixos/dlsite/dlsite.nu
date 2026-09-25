const dlsite_font_substitutes_key = 'HKLM\Software\Microsoft\Windows NT\CurrentVersion\FontSubstitutes'

const dlsite_font_substitutes = {
  "MS Gothic": "Noto Sans Mono CJK JP"
  "ＭＳ ゴシック": "Noto Sans Mono CJK JP"
  "MS UI Gothic": "Noto Sans CJK JP"
  "MS PGothic": "Noto Sans CJK JP"
  "ＭＳ Ｐゴシック": "Noto Sans CJK JP"
  "MS Mincho": "Noto Serif CJK JP"
  "ＭＳ 明朝": "Noto Serif CJK JP"
  "MS PMincho": "Noto Serif CJK JP"
  "ＭＳ Ｐ明朝": "Noto Serif CJK JP"
  "Meiryo": "Noto Sans CJK JP"
  "メイリオ": "Noto Sans CJK JP"
  "Meiryo UI": "Noto Sans CJK JP"
  "Yu Gothic": "Noto Sans CJK JP"
  "游ゴシック": "Noto Sans CJK JP"
  "Yu Gothic UI": "Noto Sans CJK JP"
  "Yu Mincho": "Noto Serif CJK JP"
  "游明朝": "Noto Serif CJK JP"
  "MS Shell Dlg 2": "Noto Sans CJK JP"
}

def dlsite-prefix [game_dir: path] {
  $game_dir | path expand | path join "prefix"
}

def dlsite-env [game_dir: path] {
  {
    WINEPREFIX: (dlsite-prefix $game_dir)
    LANG: "ja_JP.UTF-8"
    WINEDEBUG: ($env.WINEDEBUG? | default "-all")
  }
}

def dlsite-substitute-fonts [game_dir: path] {
  with-env (dlsite-env $game_dir) {
    $dlsite_font_substitutes | items {|windows_face, noto_face|
      ^wine reg add $dlsite_font_substitutes_key /v $windows_face /d $noto_face /f o> /dev/null
    } | ignore
  }
}

def dlsite-detach-home [game_dir: path] {
  let windows_user_dir = (dlsite-prefix $game_dir | path join "drive_c" "users" $env.USER)
  ls $windows_user_dir
  | where type == symlink
  | each {|home_symlink|
      rm $home_symlink.name
      mkdir $home_symlink.name
    }
  | ignore
}

def dlsite-init [game_dir: path] {
  mkdir (dlsite-prefix $game_dir)
  with-env (dlsite-env $game_dir) {
    ^wineboot --init
    ^wineserver --wait
  }
  dlsite-detach-home $game_dir
  dlsite-substitute-fonts $game_dir
}

def dlsite-run [executable: path, ...args: string, --game-dir (-d): path] {
  let target = ($executable | path expand)
  let game_root = ($game_dir | default ($target | path dirname) | path expand)
  let wineboot_finished = (dlsite-prefix $game_root | path join "system.reg" | path exists)
  if not $wineboot_finished {
    dlsite-init $game_root
  }
  with-env (dlsite-env $game_root) {
    cd $game_root
    ^wine $target ...$args
  }
}

def dlsite-wine [game_dir: path, ...args: string] {
  with-env (dlsite-env $game_dir) { ^wine ...$args }
}

def dlsite-winetricks [game_dir: path, ...args: string] {
  with-env (dlsite-env $game_dir) { ^winetricks ...$args }
}

alias dlsite-extract = ^unar -output-directory ~/Games
