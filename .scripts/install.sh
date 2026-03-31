#!/usr/bin/env bash

set -euo pipefail

DOTFILES_REPO_URL="https://github.com/kwonj/dotfiles.git"
DOTFILES_PATH="${HOME}/.dotfiles"
DOTFILES_BACKUP_ROOT="${HOME}/.dotfiles.backup"
PRIVATE_GITCONFIG_PATH="${HOME}/.gitconfig.private"

log() {
  printf '%s\n' "$*"
}

warn() {
  printf 'warning: %s\n' "$*" >&2
}

die() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

dotgit() {
  /usr/bin/git --git-dir="${DOTFILES_PATH}" --work-tree="${HOME}" "$@"
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || die "required command not found: $1"
}

detect_os() {
  case "$(uname -s)" in
    Darwin|Linux) ;;
    *) die "this installer supports macOS and Linux only" ;;
  esac
}

clone_dotfiles_repo() {
  if [ -d "${DOTFILES_PATH}" ]; then
    if dotgit rev-parse --is-bare-repository >/dev/null 2>&1; then
      log "Reusing existing bare repository at ${DOTFILES_PATH}"
      return
    fi

    die "${DOTFILES_PATH} exists but is not a usable bare Git repository"
  fi

  log "Cloning bare repository into ${DOTFILES_PATH}"
  git clone --bare "${DOTFILES_REPO_URL}" "${DOTFILES_PATH}"
}

configure_dotfiles_repo() {
  dotgit config --local status.showUntrackedFiles no
}

tracked_files() {
  dotgit ls-tree -r --name-only HEAD
}

backup_conflicting_files() {
  local backup_dir
  local path
  local target

  backup_dir="${DOTFILES_BACKUP_ROOT}/$(date +%Y%m%d%H%M%S)"

  while IFS= read -r path; do
    [ -n "${path}" ] || continue
    target="${HOME}/${path}"

    if [ ! -e "${target}" ]; then
      continue
    fi

    mkdir -p "${backup_dir}/$(dirname "${path}")"
    mv "${target}" "${backup_dir}/${path}"
    log "Backed up ${target} -> ${backup_dir}/${path}"
  done < <(tracked_files)

  if [ -e "${PRIVATE_GITCONFIG_PATH}" ]; then
    mkdir -p "${backup_dir}"
    mv "${PRIVATE_GITCONFIG_PATH}" "${backup_dir}/.gitconfig.private"
    log "Backed up ${PRIVATE_GITCONFIG_PATH} -> ${backup_dir}/.gitconfig.private"
  fi
}

checkout_dotfiles() {
  log "Checking out tracked files into ${HOME}"
  dotgit checkout
}

ensure_private_gitconfig_template() {
  if [ -e "${PRIVATE_GITCONFIG_PATH}" ]; then
    return
  fi

  cat > "${PRIVATE_GITCONFIG_PATH}" <<'EOF'
# git configuration for personal information
#
# [user]
#     name = "YOUR NAME"
#     email = "YOUR EMAIL"
EOF
}

run_os_bootstrap() {
  case "$(uname -s)" in
    Darwin) "${HOME}/.scripts/mac_local.sh" ;;
    Linux) "${HOME}/.scripts/linux_local.sh" ;;
  esac
}

install_oh_my_zsh() {
  if [ ! -d "${HOME}/.oh-my-zsh" ]; then
    log "Installing Oh My Zsh"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
      "" --unattended --keep-zshrc
  else
    log "Reusing existing Oh My Zsh installation"
  fi
}

install_plugin_repo() {
  local repo_url="$1"
  local destination="$2"

  if [ -d "${destination}" ]; then
    log "Reusing ${destination}"
    return
  fi

  git clone --depth=1 "${repo_url}" "${destination}"
}

install_shell_plugins() {
  local zsh_custom

  install_oh_my_zsh

  zsh_custom="${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}"
  install_plugin_repo \
    "https://github.com/romkatv/powerlevel10k.git" \
    "${zsh_custom}/themes/powerlevel10k"
  install_plugin_repo \
    "https://github.com/zsh-users/zsh-autosuggestions" \
    "${zsh_custom}/plugins/zsh-autosuggestions"
  install_plugin_repo \
    "https://github.com/zsh-users/zsh-syntax-highlighting.git" \
    "${zsh_custom}/plugins/zsh-syntax-highlighting"
}

main() {
  require_command git
  require_command curl
  detect_os
  clone_dotfiles_repo
  configure_dotfiles_repo

  if ! [ -f "${HOME}/.zshrc" ] || ! dotgit ls-files --error-unmatch .zshrc >/dev/null 2>&1; then
    backup_conflicting_files
    checkout_dotfiles
  else
    log "Tracked files appear to be checked out already; skipping checkout"
  fi

  ensure_private_gitconfig_template
  run_os_bootstrap
  install_shell_plugins

  log
  log "Install finished."
}

main "$@"
