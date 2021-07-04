#!/usr/bin/sh

# refer to: https://gist.github.com/weibeld/869f723063811e5088708a9386bf52bf#file-dotfiles-install-sh

set -e

DOTFILES_PATH="$HOME/.dotfiles"
DOTFILES_BACKUP_PATH="$HOME/.dotfiles.backup"

if [ -e $DOTFILES_PATH ]; then
  >&2 echo "$DOTFILES_PATH already exists. remove it first."
  exit 1
fi

echo "Start installing dotfiles."
echo
echo "Install dotfiles from remote git repository:"
git clone --bare https://github.com/kwonj/dotfiles.git $DOTFILES_PATH
dotgit() { /usr/bin/git --git-dir=$DOTFILES_PATH --work-tree=$HOME "$@"; }
dotgit config --local status.showUntrackedFiles no

# Backup already existing dotfiles
echo
echo "Backup already existing dotfiles.."
files=($(dotgit ls-tree -r HEAD | awk '{print $NF}'))
for f in "${files[@]}"; do
  # File at root ==> back up file
  if [[ $(basename "$f") = "$f" ]]; then
    [[ -f "$HOME/$f" ]] && mkdir -p $DOTFILES_BACKUP_PATH && mv "$HOME/$f" $DOTFILES_BACKUP_PATH \
      && echo "> Backing up: $HOME/$f ==> $DOTFILES_BACKUP_PATH/$f"
  # File in nested directory ==> back up outermost directory
  else
    d=${f%%/*}
    if [[ -d "$HOME/$d" ]]; then
      [[ -d "$DOTFILES_BACKUP_PATH/$d" ]] && rm -rf "$DOTFILES_BACKUP_PATH/$d"
      mkdir -p $DOTFILES_BACKUP_PATH && mv "$HOME/$d" $DOTFILES_BACKUP_PATH \
        && echo "> Backing up: $HOME/$d/ ==> $DOTFILES_BACKUP_PATH/$d/"
    fi
  fi
done

# Install
dotgit checkout
echo
echo "Install finished. The following dotfiles have been installed to $HOME:"
printf '    %s\n' "${files[@]}"