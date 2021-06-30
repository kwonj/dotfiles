#!/usr/bin/sh
# TODO: install zsh, tmux, and nvim locally

APP_DIR="$HOME/.local"

install_zsh() {
    set -e
    # zsh
    # TODO: install zsh from source
    if command -v zsh &> /dev/null; then
        echo "zsh is installed already."
    elif command -v apt &> /dev/null; then
        apt install zsh
    elif command -v yum &> /dev/null; then
        yum install zsh
    elif command -v brew &> /dev/null; then
        brew install zsh
    fi

    chsh -s /bin/zsh
}

install_tmux() {
    set -e
    # tmux
    if command -v tmux &> /dev/null; then
        echo "tmux is installed already."
    if command -v apt &> /dev/null; then
        apt install tmux
    elif command -v yum &> /dev/null; then
        yum install tmux
    elif command -v brew &> /dev/null; then
        brew install tmux
    fi
}

install_nvim() {
    set -e
    TEMP_DIR="/tmp/nvim/"
    mkdir -p $TEMP_DIR
    pushd $TEMP_DIR
    NVIM_VERSION="v0.4.4"
    curl -L -O -C - "https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux64.tar.gz"
    tar xzvf nvim-linux64.tar.gz
    cp -RT nvim-linux64/ $APP_DIR
    popd
}

install_miniconda(){
    set -e
    TEMP_DIR="/tmp/miniconda/"
    mkdir -p $TEMP_DIR
    pushd $TEMP_DIR
    curl -L -O -C - https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
    bash Miniconda3-latest-Linux-x86_64.sh -b -p "$HOME/.miniconda"
    popd
}

if [ -d "$HOME/.miniconda3" ]; then
    echo "miniconda is installed in ~/.miniconda3. rename it to '.miniconda' or install manually."
elif [ -d "$HOME/.miniconda" ]; then
    echo "miniconda is installed already."
else
    install_miniconda
fi

# install oh-my-zsh and theme, plugins
source $SCRIPT_DIR/zsh.sh