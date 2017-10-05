#!/usr/bin/env bash

modules=(
  ps1
  aliases
  bash_completion
  pyenv
  rbenv
  ndenv
  env_vars
  extras
  github
)

__is_interactive() { [[ $- == *i* ]]; }
__run_setup() {
  for mod in "${modules[@]}"; do
    source "${HOME}/.bashrc.d/$mod"
  done

  if __is_interactive; then
      setup_ps1
      setup_bash_completion
  fi

  setup_aliases
  setup_extras
  setup_env_vars
  setup_rbenv
  setup_pyenv
  setup_ndenv

  secret_extras="/home/renan/SpiderOak Hive/.bashrc.extras"
  if [ -f "${secret_extras}" ]; then
      source "${secret_extras}"
  fi
}

__run_setup
