#!/usr/bin/env bash

# modules are files with name `.bashrc.$module_name'
# each module define a function with name `setup_$module_name'
# modules should be kept in .bashrc.d/$module_name
modules=(
    ps1
    aliases
    bash_completion
    rbenv
    env_vars
    extras
    github
)

__require() {
    path="${HOME}/.bashrc.d/$1"
    if [ -e "${path}" ]; then source "${path}"; fi
}

__require_modules() {
  for module in "${modules[@]}"; do
    __require $module
  done
}

__is_interactive() { [[ $- == *i* ]]; }

__setup() {
    __require_modules

    if __is_interactive; then
	setup_ps1
	setup_bash_completion
    fi

    setup_aliases
    setup_extras
    setup_env_vars
    setup_rbenv

    secret_extras="/home/renan/SpiderOak Hive/.bashrc.extras"
    if [ -f "${secret_extras}" ]; then
        source "${secret_extras}"
    fi
}

__setup
