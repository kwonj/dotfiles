#!/usr/bin/env bash

set -euo pipefail

BREWFILE="${HOME}/.scripts/brewfile"
BREWFILE_PERSONAL="${HOME}/.scripts/brewfile_personal"
INSTALL_PERSONAL_BREWFILE="${INSTALL_PERSONAL_BREWFILE:-0}"

log() {
  printf '%s\n' "$*"
}

install_homebrew() {
  if command -v brew >/dev/null 2>&1; then
    return
  fi

  log "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

load_homebrew_environment() {
  if command -v brew >/dev/null 2>&1; then
    eval "$(brew shellenv)"
    return
  fi

  if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    return
  fi

  if [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
    return
  fi

  printf 'error: brew command is unavailable after installation\n' >&2
  exit 1
}

run_bundle() {
  local brewfile="$1"

  [ -f "${brewfile}" ] || return
  log "Installing packages from ${brewfile}"
  brew bundle --file="${brewfile}"
}

install_fzf_shell_integration() {
  local fzf_install

  fzf_install="$(brew --prefix)/opt/fzf/install"
  if [ ! -x "${fzf_install}" ]; then
    return
  fi

  if [ -f "${HOME}/.fzf.zsh" ] && [ -f "${HOME}/.fzf.bash" ]; then
    return
  fi

  log "Installing fzf shell integration"
  yes | "${fzf_install}" --no-update-rc
}

main() {
  install_homebrew
  load_homebrew_environment
  run_bundle "${BREWFILE}"
  if [ "${INSTALL_PERSONAL_BREWFILE}" = "1" ]; then
    run_bundle "${BREWFILE_PERSONAL}"
  else
    log "Skipping ${BREWFILE_PERSONAL}; set INSTALL_PERSONAL_BREWFILE=1 to install personal packages"
  fi
  install_fzf_shell_integration
}

main "$@"
