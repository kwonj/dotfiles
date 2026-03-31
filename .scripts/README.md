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
- installs packages from `brewfile_personal` only when `INSTALL_PERSONAL_BREWFILE=1`
- `brewfile_personal` is intended for personal machines and is skipped by default
- runs the `fzf` post-install step when needed

### `linux_local.sh`

Linux bootstrap.

- installs `zsh` and `tmux` with a supported package manager
- installs tools under `~/.local`
- downloads standalone binaries from GitHub releases when practical
- does not assume root access
- no longer installs Miniconda
