__iife() {
  unset __iife

  ENVAR_NAME=sh.lib

  local curdir="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
  PATH="${curdir}/vendor/.bin:${PATH}"
} && __iife
