function start_dropbox {
    if [[ -d ~/.dropbox-dist ]]; then
        if ! ps aux | grep "[d]ropbox-dist" > /dev/null; then
            echo "Starting Dropbox..."
            nohup ~/.dropbox-dist/dropboxd & >& /dev/null
        fi
    fi
}

function setup_ps1 {
    function parse_login_shell {
        shopt -q login_shell && echo '(login_shell)'
    }
    function parse_status {
        if [[ $? != 0 ]]; then
            echo "-=(error)=-"
        fi
    }
    function parse_git_branch {
        git branch --no-color 2> /dev/null \
            | sed -e '/^[^*]/d' -e 's/* \(.*\)/\[\1\]/'
    }
    function parse_ruby_version {
        regexp="([0-9]\.[0-9](\.[0-9])?)"
        [[ `ruby --version` =~ $regexp ]]
        echo "${BASH_REMATCH[1]}"
    }

    # Colors
    local txtblk='\[\e[0;30m\]' # Black - Regular
    local txtred='\[\e[0;31m\]' # Red
    local txtgrn='\[\e[0;32m\]' # Green
    local txtylw='\[\e[0;33m\]' # Yellow
    local txtblu='\[\e[0;34m\]' # Blue
    local txtpur='\[\e[0;35m\]' # Purple
    local txtcyn='\[\e[0;36m\]' # Cyan
    local txtwht='\[\e[0;37m\]' # White
    local bldblk='\[\e[1;30m\]' # Black - Bold
    local bldred='\[\e[1;31m\]' # Red
    local bldgrn='\[\e[1;32m\]' # Green
    local bldylw='\[\e[1;33m\]' # Yellow
    local bldblu='\[\e[1;34m\]' # Blue
    local bldpur='\[\e[1;35m\]' # Purple
    local bldcyn='\[\e[1;36m\]' # Cyan
    local bldwht='\[\e[1;37m\]' # White
    local undblk='\[\e[4;30m\]' # Black - Underline
    local undred='\[\e[4;31m\]' # Red
    local undgrn='\[\e[4;32m\]' # Green
    local undylw='\[\e[4;33m\]' # Yellow
    local undblu='\[\e[4;34m\]' # Blue
    local undpur='\[\e[4;35m\]' # Purple
    local undcyn='\[\e[4;36m\]' # Cyan
    local undwht='\[\e[4;37m\]' # White
    local bakblk='\[\e[40m\]'   # Black - Background
    local bakred='\[\e[41m\]'   # Red
    local bakgrn='\[\e[42m\]'   # Green
    local bakylw='\[\e[43m\]'   # Yellow
    local bakblu='\[\e[44m\]'   # Blue
    local bakpur='\[\e[45m\]'   # Purple
    local bakcyn='\[\e[46m\]'   # Cyan
    local bakwht='\[\e[47m\]'   # White
    local hiblk='\[\e[0;90m\]'  # Black - High intensity
    local hired='\[\e[0;91m\]'  # Red
    local higrn='\[\e[0;92m\]'  # Green
    local hiylw='\[\e[0;93m\]'  # Yellow
    local hiblu='\[\e[0;94m\]'  # Blue
    local hipur='\[\e[0;95m\]'  # Purple
    local hicyn='\[\e[0;96m\]'  # Cyan
    local hiwht='\[\e[0;97m\]'  # White
    local clroff='\[\e[0m\]'    # Text Reset

    # other variables with human readable names
    # \a          an ASCII bell character (07)
    # \d          the date in "Weekday Month Date" format (e.g., "Tue May 26")
    # \D{format}  the format is passed to strftime(3) and the result
    #             is inserted into the prompt string an empty format
    #             results in a locale-specific time representation.
    #             The braces are required
    # \e          an ASCII escape character (033)
    # \h          the hostname up to the first `.'
    # \H          the hostname
    # \j          the number of jobs currently managed by the shell
    # \l          the basename of the shell's terminal device name
    # \n          newline
    # \r          carriage return
    # \s          the name of the shell, the basename of $0 (the portion following
    #             the final slash)
    # \t          the current time in 24-hour HH:MM:SS format
    # \T          the current time in 12-hour HH:MM:SS format
    # \@          the current time in 12-hour am/pm format
    # \A          the current time in 24-hour HH:MM format
    # \u          the username of the current user
    # \v          the version of bash (e.g., 2.00)
    # \V          the release of bash, version + patch level (e.g., 2.00.0)
    # \w          the current working directory, with $HOME abbreviated with a tilde
    # \W          the basename of the current working directory, with $HOME
    #             abbreviated with a tilde
    # \!          the history number of this command
    # \#          the command number of this command
    # \$          if the effective UID is 0, a #, otherwise a $
    # \nnn        the character corresponding to the octal number nnn
    # \\          a backslash
    # \[          begin a sequence of non-printing characters, which could be used
    #             to embed a terminal control sequence into the prompt
    # \]          end a sequence of non-printing characters

    time24h="\A"
    path="\w"
    newline="\n"
    jobs="\j"
    user="\u"
    host="\H"

    # building PS1 out of various parts
    PS1=""

    #time part
    PS1+="$hicyn[$time24h]$clroff"
    #status part
    PS1+="$hired\$(parse_status)$clroff"
    #git branch part
    PS1+="$bldred\$(parse_git_branch)$clroff"
    #ruby version part
    PS1+="$undblu{$hiblu\$(parse_ruby_version)$undblu}$clroff"
    #path part
    PS1+="$clroff[$txtcyn$path$clroff]"
    #line break
    PS1+="$newline"
    #login shell indicator part
    PS1+="$hiblu\$(parse_login_shell)"
    #user and hostname part
    PS1+="$hipur$user$txtred@$hiwht$host$clroff"
    #final part
    PS1+="$txtwht(\#)$clroff-> "
}
function setup_bash_completion {
    # -- Bash completion configuration --
    if [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
}
function setup_rbenv {
    if [ -d ~/.rbenv/ ]; then
        export PATH="$HOME/.rbenv/bin:$PATH"
        eval "$(rbenv init -)"
    fi
}
function setup_aliases {
    # aliasing ls to show pretyt colors
    alias ls="ls --color=tty"

    # aliasing emacs
    function __emacs-x-client { emacsclient -a '' -c -n $1; }
    function __emacs-terminal-client { emacsclient -a '' -t $1; }

    # export terminal to xterm256
    export TERM=xterm-256color

    alias em=__emacs-x-client
    alias et=__emacs-terminal-client
    alias edk="emacsclient -e \"(kill-emacs)\""
    alias ekr="edk && em && exit"

    # moving to projects
    function __open_code_project { cd ~/code/$1; }
    function __open_locaweb_project { cd ~/locaweb/$1; }

    alias 8pl=__open_locaweb_project
    alias 8pc=__open_code_project

    # clone and update everything using my personal script
    alias 8gcc="\$(8pc && ./github-ruby-cloner/cloner.rb)"
    alias 8gpc="\$(8pc && ./github-ruby-cloner/puller.rb)"

    alias 8gpl="\$(8pl && ./github-ruby-cloner/puller.rb)"

    # aliasing ruby & git stuff
    alias 8bes="bundle exec rspec"
    alias 8be="bundle exec"
    alias 8rdbm="bundle exec rake db:migrate db:rollback && bundle exec rake db:migrate"
    alias 8bejs="bundle exec jekyll serve --watch"
}

function actual_setup {
    function is_interactive {
        if [[ $- == *i* ]]; then 1; else 0;
        fi
    }

    if [ is_interactive ]; then
        setup_ps1
        setup_bash_completion
        setup_aliases

        start_dropbox
    fi

    setup_rbenv
}

# Must not forget to call setup!
actual_setup
