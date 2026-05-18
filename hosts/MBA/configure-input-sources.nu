#!/usr/bin/env nu
# Configure macOS input sources for Dvorak + macSKK. Idempotent.
#
# Requires Homebrew: cask `macskk`, tap `lutzifer/homebrew-tap` (keyboardSwitcher).
#
# `defaults write com.apple.HIToolbox AppleEnabledInputSources` is pruned at
# login. keyboardSwitcher uses the TIS API directly (the same path System
# Settings UI takes), so its writes persist.

let macskk_app = "/Library/Input Methods/macSKK.app"

# Launch so macSKK's input modes register with TIS.
^open $macskk_app
sleep 3sec

^keyboardSwitcher enable Dvorak
^keyboardSwitcher enable net.mtgto.inputmethod.macSKK.hiragana
^keyboardSwitcher disable ABC
^keyboardSwitcher select Dvorak

# macSKK has its own keyboard-layout setting (independent of the OS input
# source); without overriding it, SKK input stays QWERTY despite the OS being
# in Dvorak.
defaults write net.mtgto.inputmethod.macSKK selectedInputSource -string "com.apple.keylayout.Dvorak"

# Restart so macSKK re-reads the preference.
^pkill -f $"($macskk_app)/Contents/MacOS/macSKK"
sleep 1sec
^open $macskk_app

print "Done. Verify via menu bar input source picker."
