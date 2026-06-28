$env.config.show_banner = false

alias gdl = gallery-dl

def invalid-filename-targets [] {
  glob "**/*"
  | where {|path| ($path | path basename) =~ '[:\"<>|?*]' }
  | each {|path|
      let dirname = ($path | path dirname)
      let new_basename = (($path | path basename) | str replace --all '[:\"<>|?*]' '_' --regex)
      { path: $path, new_path: $"($dirname)/($new_basename)" }
    }
}

def check-filename [] { invalid-filename-targets }

def sanitize-filename [] {
  invalid-filename-targets
  | sort-by --reverse {|item| $item.path | str length }
  | each {|item|
      try {
        mv $item.path $item.new_path
        { path: $item.path, new_path: $item.new_path, ok: true }
      } catch {
        { path: $item.path, new_path: $item.new_path, ok: false }
      }
    }
}
