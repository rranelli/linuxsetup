#!/usr/bin/env bash

# modules are files with name `.bashrc.$module_name'
# each module define a function with name `setup_$module_name'
# modules should be kept in .bashrc.d/$module_name
modules=(
    ps1
    aliases
    bash_completion
    rbenv
    path
    extras
)

function __require {
    path=$HOME/.bashrc.d/$1
    if [[ -e $path ]]; then source $path; fi
}

function __require_modules {
    for module in "${modules[@]}"
    do __require $module; done
}

function __is_interactive {
    if [[ $- == *i* ]]; then 1; else 0; fi
}

function __setup {
    __require_modules

    if [ __is_interactive ]; then
	setup_ps1
	setup_aliases
	setup_bash_completion

	setup_extras
    fi

    setup_path
    setup_rbenv
}

__setup
