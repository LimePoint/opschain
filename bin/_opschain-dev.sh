#!/usr/bin/env bash
set -eo pipefail

export PROJECT_DIR="$(pwd)"

# change to the directory containing the docker-compose.yml and the .env
CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]}")"
cd ..

shopt -s nocasematch
env_vars=''
for var in $(compgen -e); do
  if [[ "$var" = opschain_* ]]; then
    env_vars+=" -e $var"
  fi
done

exec docker-compose run ${env_vars} ${EXTRA_ARGS} --rm opschain-runner-devenv "$@"
