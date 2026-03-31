# Dotfiles

This repository manages the home directory with a bare Git repository at
`$HOME/.dotfiles` and a work tree rooted at `$HOME`.

## Layout

- Git directory: `~/.dotfiles`
- Work tree: `~`
- Convenience alias:

```sh
alias dotgit='/usr/bin/git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
```

## Install

Bootstrap a new machine with:

```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/kwonj/dotfiles/master/.scripts/install.sh)"
```

The Git clone step uses SSH, so the target machine needs GitHub SSH access.

The installer:

- clones the bare repository into `~/.dotfiles`
- backs up conflicting files into `~/.dotfiles.backup/<timestamp>/`
- checks out tracked files into `~`
- creates `~/.gitconfig.private` if it does not exist
- runs OS-specific package setup
- installs Oh My Zsh and the required plugins/themes

## Daily Use

Fetch and inspect status:

```sh
dotgit fetch origin
dotgit status -sb
dotgit log --oneline --decorate --graph -n 10
```

Commit and push changes:

```sh
dotgit add <path>
dotgit commit -m "message"
dotgit push origin main
```

## Tracked vs Local

Track files that are reproducible shell/editor/package-manager configuration.

For Homebrew packages:

- `brewfile` is the common baseline
- `brewfile_personal` is for personal-machine-only software
- `brewfile_personal` is only installed when `INSTALL_PERSONAL_BREWFILE=1` is set

Keep these out of the repository:

- secrets and personal overrides such as `~/.gitconfig.private`
- caches, histories, generated files, and machine-local state
- files already synchronized by another tool

## Notes

- When Nerd Font is missing, run `p10k configure`.
- The repository uses `status.showUntrackedFiles = no` locally to avoid showing
  the rest of the home directory as noise.
- Linux bootstrap installs `zsh` and `tmux` with an available package manager,
  and installs standalone tools under `~/.local`.
