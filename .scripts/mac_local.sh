#!/usr/bin/env bash

set -e

# install brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# install packages
brew bundle --file=$HOME/.scripts/brewfile

# install oh-my-zsh and theme, plugins
source $HOME/.scripts/zsh.sh