### Prerequisites


### Push to github
```
git init --bare $HOME/.dotfiles
alias dotcfg='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
dotcfg config --local status.showUntrackedFiles no
```

### Clone to new box
```
git clone --bare <git-repo-url> $HOME/.dotfiles
alias config='/usr/bin/git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
config checkout
config config --local status.showUntrackedFiles no
```