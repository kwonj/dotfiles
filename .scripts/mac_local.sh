#!/usr/bin/sh

set -e

# install brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# install packages
brew bundle --file=$HOME/.scripts/brewfile

# link conda directory from homebrew to home directory
ln -s /opt/homebrew/Caskroom/miniconda/base ~/.miniconda

# install oh-my-zsh and theme, plugins
source $HOME/.scripts/zsh.sh