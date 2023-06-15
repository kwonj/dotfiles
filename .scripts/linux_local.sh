#!/usr/bin/env bash
# TODO: install zsh, tmux locally

set -e

APP_DIR="$HOME/.local"
mkdir -p $APP_DIR/bin

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

install_latest_app_from_github() {
    local name=$1
    local repo=$2
    local filename=$3

    if [ -f "$HOME/.local/bin/$name" ]; then
        echo "$name is installed in ~/.local/bin"
    else
        local download_url=$(\
            curl -L https://api.github.com/repos/${repo}/releases 2>/dev/null | \
            python -c "\
import json, sys, fnmatch;
J = json.load(sys.stdin);
for asset in J[0]['assets']:
    if fnmatch.fnmatch(asset['name'], '$filename'):
        print(asset['browser_download_url'])
")
        echo -e "download_url = $download_url"
        test -n $download_url
        sleep 0.5

        TEMP_DIR=$(mktemp -d -t $name-XXXXXXXXXX)
        mkdir -p $TEMP_DIR
        pushd $TEMP_DIR
        curl -L -o $filename -C - $download_url

        mkdir -p $APP_DIR/cellar/$name
        if [[ $filename == *.tar.gz ]]; then
            tar -xzf $filename -C $APP_DIR/cellar/$name
        else
            cp $filename $APP_DIR/cellar/$name/$name
        fi

        rm -rf $TEMP_DIR
        popd
    fi
}

install_neovim() {
    local app_name="nvim"
    install_latest_app_from_github $app_name "neovim/neovim" "nvim-linux64.tar.gz"
    ln -sf $APP_DIR/cellar/$app_name/nvim-linux64/bin/$app_name $APP_DIR/bin/$app_name
}

install_direnv() {
    local app_name="direnv"
    install_latest_app_from_github $app_name "direnv/direnv" "direnv.linux-amd64"
    chmod +x $APP_DIR/cellar/$app_name/$app_name
    ln -sf $APP_DIR/cellar/$app_name/$app_name $APP_DIR/bin/$app_name
}

install_fzf() {
    local app_name="fzf"
    install_latest_app_from_github $app_name "junegunn/fzf" "fzf-*-linux_amd64.tar.gz"
    ln -sf $APP_DIR/cellar/$app_name/$app_name $APP_DIR/bin/$app_name
}

install_lazydocker() {
    local app_name="lazydocker"
    install_latest_app_from_github $app_name "jesseduffield/lazydocker" "lazydocker_*_Linux_x86_64.tar.gz"
    ln -sf $APP_DIR/cellar/$app_name/$app_name $APP_DIR/bin/$app_name
}

install_lazygit() {
    local app_name="lazygit"
    install_latest_app_from_github $app_name "jesseduffield/lazygit" "lazygit_*_Linux_x86_64.tar.gz"
    ln -sf $APP_DIR/cellar/$app_name/$app_name $APP_DIR/bin/$app_name
}

# install packages
install_zsh
install_miniconda
install_neovim
install_direnv
install_fzf
install_lazydocker
install_lazygit
