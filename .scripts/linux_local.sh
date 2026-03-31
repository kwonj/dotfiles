#!/usr/bin/env bash

set -euo pipefail

APP_DIR="${HOME}/.local"
BIN_DIR="${APP_DIR}/bin"
CELLAR_DIR="${APP_DIR}/cellar"

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

require_command() {
  command -v "$1" >/dev/null 2>&1 || die "required command not found: $1"
}

ensure_directories() {
  mkdir -p "${BIN_DIR}" "${CELLAR_DIR}"
}

package_manager_prefix() {
  if command -v sudo >/dev/null 2>&1; then
    printf 'sudo'
    return
  fi

  printf ''
}

install_with_package_manager() {
  local package="$1"
  local prefix

  prefix="$(package_manager_prefix)"

  if command -v apt-get >/dev/null 2>&1; then
    if [ -n "${prefix}" ]; then
      ${prefix} apt-get update
      ${prefix} apt-get install -y "${package}"
    else
      apt-get update
      apt-get install -y "${package}"
    fi
    return
  fi

  if command -v dnf >/dev/null 2>&1; then
    if [ -n "${prefix}" ]; then
      ${prefix} dnf install -y "${package}"
    else
      dnf install -y "${package}"
    fi
    return
  fi

  if command -v yum >/dev/null 2>&1; then
    if [ -n "${prefix}" ]; then
      ${prefix} yum install -y "${package}"
    else
      yum install -y "${package}"
    fi
    return
  fi

  if command -v brew >/dev/null 2>&1; then
    brew install "${package}"
    return
  fi

  die "could not install ${package}: no supported package manager found"
}

ensure_system_package() {
  local package="$1"
  local command_name="${2:-$1}"

  if command -v "${command_name}" >/dev/null 2>&1; then
    log "${package} is already installed"
    return
  fi

  log "Installing ${package}"
  install_with_package_manager "${package}"
}

latest_release_asset_url() {
  local repo="$1"
  local pattern="$2"

  curl -fsSL "https://api.github.com/repos/${repo}/releases/latest" | \
    python3 -c '
import fnmatch
import json
import sys

data = json.load(sys.stdin)
pattern = sys.argv[1]
for asset in data.get("assets", []):
    name = asset.get("name", "")
    if fnmatch.fnmatch(name, pattern):
        print(asset["browser_download_url"])
        break
' "${pattern}"
}

download_to_temp() {
  local url="$1"
  local output_name="$2"
  local temp_dir

  temp_dir="$(mktemp -d)"
  curl -fL --retry 3 --output "${temp_dir}/${output_name}" "${url}"
  printf '%s\n' "${temp_dir}"
}

install_archive_binary() {
  local name="$1"
  local repo="$2"
  local asset_pattern="$3"
  local extracted_binary="$4"

  local url
  local temp_dir
  local install_dir

  if [ -x "${BIN_DIR}/${name}" ]; then
    log "${name} is already installed"
    return
  fi

  url="$(latest_release_asset_url "${repo}" "${asset_pattern}")"
  [ -n "${url}" ] || die "failed to locate release asset for ${name}"

  temp_dir="$(download_to_temp "${url}" "${name}.tar.gz")"
  install_dir="${CELLAR_DIR}/${name}"
  rm -rf "${install_dir}"
  mkdir -p "${install_dir}"
  tar -xzf "${temp_dir}/${name}.tar.gz" -C "${install_dir}"
  ln -sf "${install_dir}/${extracted_binary}" "${BIN_DIR}/${name}"
  rm -rf "${temp_dir}"
}

install_standalone_binary() {
  local name="$1"
  local repo="$2"
  local asset_pattern="$3"

  local url
  local temp_dir
  local install_dir

  if [ -x "${BIN_DIR}/${name}" ]; then
    log "${name} is already installed"
    return
  fi

  url="$(latest_release_asset_url "${repo}" "${asset_pattern}")"
  [ -n "${url}" ] || die "failed to locate release asset for ${name}"

  temp_dir="$(download_to_temp "${url}" "${name}")"
  install_dir="${CELLAR_DIR}/${name}"
  rm -rf "${install_dir}"
  mkdir -p "${install_dir}"
  mv "${temp_dir}/${name}" "${install_dir}/${name}"
  chmod +x "${install_dir}/${name}"
  ln -sf "${install_dir}/${name}" "${BIN_DIR}/${name}"
  rm -rf "${temp_dir}"
}

install_neovim() {
  install_archive_binary "nvim" "neovim/neovim" "nvim-linux64.tar.gz" "nvim-linux64/bin/nvim"
}

install_direnv() {
  install_standalone_binary "direnv" "direnv/direnv" "direnv.linux-amd64"
}

install_fzf() {
  install_archive_binary "fzf" "junegunn/fzf" "fzf-*-linux_amd64.tar.gz" "fzf"
}

install_lazydocker() {
  install_archive_binary "lazydocker" "jesseduffield/lazydocker" "lazydocker_*_Linux_x86_64.tar.gz" "lazydocker"
}

install_lazygit() {
  install_archive_binary "lazygit" "jesseduffield/lazygit" "lazygit_*_Linux_x86_64.tar.gz" "lazygit"
}

main() {
  require_command curl
  require_command python3
  require_command tar
  ensure_directories
  ensure_system_package "zsh"
  ensure_system_package "tmux"
  install_neovim
  install_direnv
  install_fzf
  install_lazydocker
  install_lazygit
}

main "$@"
