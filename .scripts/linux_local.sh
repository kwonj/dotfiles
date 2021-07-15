#!/usr/bin/env bash
# TODO: install zsh, tmux locally

set -e

APP_DIR="$HOME/.local"

install_zsh() {
    # TODO: install zsh from source
    if command -v zsh &> /dev/null; then
        echo "zsh is installed already."
    elif command -v apt &> /dev/null; then
        apt install zsh
    elif command -v yum &> /dev/null; then
        yum install zsh
    elif command -v brew &> /dev/null; then
        brew install zsh
    else
        echo "cannot install zsh. stop"; exit 1
    fi

    # change default shell to zsh
    if [[ ! "$SHELL" = *zsh ]]; then
        echo "Changing default script to zsh.."
        cat <<EOF >> $HOME/.profile
[ -f $(command -v zsh) ] && exec $(command -v zsh) -l
EOF
        echo "Done - modified ~/.profile"
        echo "If you change default shell manually, run: chsh $(whoami) -s $(command -v zsh)."
    fi
}

install_tmux() {
    # tmux
    if command -v tmux &> /dev/null; then
        echo "tmux is installed already."
    elif command -v apt &> /dev/null; then
        apt install tmux
    elif command -v yum &> /dev/null; then
        yum install tmux
    elif command -v brew &> /dev/null; then
        brew install tmux
    fi
}

install_neovim() {
    if [ -f "$HOME/.local/bin/nvim" ]; then
        echo "neovim is installed in ~/.local/bin."
    else
        TEMP_DIR=$(mktemp -d -t neovim-XXXXXXXXXX)
        mkdir -p $TEMP_DIR
        pushd $TEMP_DIR
        NVIM_VERSION="v0.4.4"
        curl -L -O -C - "https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux64.tar.gz"
        tar xzvf nvim-linux64.tar.gz
        cp -RT nvim-linux64/ $APP_DIR
        rm -rf $TEMP_DIR
        popd
    fi
}

install_miniconda(){
    if [ -d "$HOME/.miniconda3" ]; then
        echo "miniconda is installed in ~/.miniconda3. rename it to '.miniconda' or install manually."
    elif [ -d "$HOME/.miniconda" ]; then
        echo "miniconda is installed already."
    else
        TEMP_DIR=$(mktemp -d -t miniconda-XXXXXXXXXX)
        mkdir -p $TEMP_DIR
        pushd $TEMP_DIR
        curl -L -O -C - https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
        bash Miniconda3-latest-Linux-x86_64.sh -b -p "$HOME/.miniconda"
        rm -rf $TEMP_DIR
        popd
    fi
}

# install packages
install_zsh
install_miniconda
install_neovim