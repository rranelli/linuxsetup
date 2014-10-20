# modules are files with name `.bashrc.$module_name'
# each module define a function with name `setup_$module_name'
modules=(ps1 aliases bash_completion rbenv path extras)

function __require {
    if [[ -f $1 ]]; then source $1; fi
}

for module in "${modules[@]}"; do __require $HOME/.bashrc.$module; done

function __setup {
    function __is_interactive {
	if [[ $- == *i* ]]; then 1; else 0; fi
    }

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
