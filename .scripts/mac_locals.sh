#!/usr/bin/sh

set -e

# install brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# install packages
brew bundle --file=$HOME/.scripts/brewfile_mac

# install oh-my-zsh and theme, plugins
source .scripts/zsh.sh