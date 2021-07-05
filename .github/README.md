# Dotfiles
dotfiles managed by bare git

### Prerequisites
- git
- curl

### Install
It uses **git bare repository**
```
bash -c "$(curl -fsSL https://raw.githubusercontent.com/kwonj/dotfiles/master/.scripts/install.sh)"
```

### Next step
run `linux_locals.sh` or `mac_locals.sh` in `.scripts` to install packages

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