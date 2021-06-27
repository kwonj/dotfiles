# Dotfiles

### Prerequisites
- git

### Create new git
```
git init --bare $HOME/.dotfiles
alias dotgit='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
dotgit config --local status.showUntrackedFiles no
```
next step: add, commit, push, ...

### Clone to new box
```
echo ".dotfiles" >> .gitignore
git clone --bare https://github.com/kwonj/dotfiles.git $HOME/.dotfiles
alias dotgit='/usr/bin/git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
dotgit config --local status.showUntrackedFiles no
config checkout
```