# Put the pinned PHP 8.5 ahead of anything else that provides `php`.
#
# Homebrew leaves php@8.5 unlinked as soon as 8.6 becomes the current release,
# at which point /opt/homebrew/bin/php either disappears or belongs to another
# formula. Naming the opt prefix keeps `php` pointing at 8.5 through that
# transition. 20-path.zsh treats the other keg-only formulas the same way.
#
# This fragment belongs to the `php85` module: .zshrc sources every numbered
# file in this directory, so a machine without the module never has it.
if [[ -d /opt/homebrew/opt/php@8.5/bin ]]; then
  path=(/opt/homebrew/opt/php@8.5/bin $path)
  export PATH
fi
