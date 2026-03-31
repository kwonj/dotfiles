# Bootstrap Scripts

These scripts support the bare-repo dotfiles setup.

## Files

### `install.sh`

Top-level bootstrap entrypoint.

- clones or reuses `~/.dotfiles`
- backs up conflicting files before checkout
- checks out tracked dotfiles into `~`
- creates `~/.gitconfig.private` if missing
- delegates package installation to the OS-specific script
- installs Oh My Zsh plus required plugins/themes

### `mac_local.sh`

macOS package bootstrap.

- installs Homebrew if missing
- installs packages from `brewfile`
- optionally installs packages from `brewfile_local`
- runs the `fzf` post-install step when needed

### `linux_local.sh`

Linux user-space bootstrap.

- installs tools under `~/.local`
- installs Miniconda under `~/.miniconda`
- downloads standalone binaries from GitHub releases when practical
- does not assume root access
- does not manage `zsh` or `tmux` automatically; it reports them as manual prerequisites
