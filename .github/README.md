# Dotfiles
dotfiles managed by bare git

### Prerequisites
- git
- curl
- zsh (installing zsh is not fully implemented)
- miniconda (optional)

### Install
It uses **git bare repository**
```
bash -c "$(curl -fsSL https://raw.githubusercontent.com/kwonj/dotfiles/master/.scripts/install.sh)"
```

### Help
- when **Nerd Font** is not installed
    - run `p10k configure` (it installs the font first)

- Create new empty dotfiles git <br />
    ```
    git init --bare $HOME/.dotfiles
    alias dotgit="/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"
    dotgit config --local status.showUntrackedFiles no
    ```
    next step: add, commit, push, ...