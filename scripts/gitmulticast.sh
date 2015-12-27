#!/usr/bin/env bash
set -euo pipefail # these don't play well with bashdb;

#
## Setup environment
#
: ${GITHUB_USER:=rranelli}
: ${GITHUB_USER_TYPE:=users}
: ${GITHUB_API_TOKEN:=$(mimipass get github-api-token)}
: ${CODE_DIR:=$HOME/code}

auth_header="Authorization: token $GITHUB_API_TOKEN"
repos_url="https://api.github.com/${GITHUB_USER_TYPE}/${GITHUB_USER}/repos"

## Helpers
txtgrn="\e[0;32m"
txtred="\e[0;31m"
clroff="\e[0m"

grn-echo() { echo -e "${txtgrn}$@${clroff}" ;}
red-echo() { echo -e "${txtred}$@${clroff}" ;}

## Verify all required commands are available
check-command() {
    [ $# = 0 ] && return 0
    (command -v $1 >/dev/null) || { red-echo "$1 is not available"; exit 1 ;}
    shift && check-command $@
}
check-command jq mimipass curl mktemp git

fetch-repos() {
    function get-next-page {
        if [[ "$@" =~ \<(.*)\>\;\ rel\=\"next\" ]]; then
            echo "${BASH_REMATCH[1]}"
        fi
        return 0
    }

    function fetch-repos-rec {
        [ $# = 0 ] && return 0

        url=$1
        header=$(curl -sSI -H "$auth_header" $url)
        repos=$(curl -sS -H "$auth_header" $url | jq '.[]') # extract out of array

        next_page=$(get-next-page "$header")
        [ -n $next_page ] && echo "$repos" "$(fetch-repos-rec $next_page)"
    }

    fetch-repos-rec $1 | jq --slurp '.'
}

: ${POOL_SIZE:=20}
parallel() {
    declare -a jobs=()
    declare -A outputs=()

    function async {
        out=$(mktemp)

        grn-echo "Result of: ${clroff}$@" > $out
        if $@; then
            grn-echo "Success!"; echo
        else
            red-echo "Failure!"; echo
        fi >>$out 2>&1 &

        outputs[$!]=$out
    }

    function is-alive { kill -0 $1 2>/dev/null ;}
    function read-output {
        pid=$1
        if [ ${outputs[$pid]} ]; then
            cat ${outputs[$pid]} && unset outputs[$pid]
        fi
    }

    for n in $(eval echo {0..$POOL_SIZE}); do # Start the first batch:
        [ $# = 0 ] && break                   # - check if there are still jobs to run
        async $1                              # - run the next job in the background

        jobs[$n]=$!; shift                    # - record the n-th job PID & dequeue it
    done

    while true; do                               # While the jobs are not done:
        for i in ${!jobs[@]}; do              # - For each running process
            local pid=${jobs[$i]}
            is-alive $pid && continue         # -- Check if process is still alive. If it is, continue

            read-output $pid                  # -- if the process is just finished, read its output
            [ $# = 0 ] && break               # -- Check if there are still jobs to run

            async $1; shift;                  # -- If there are, dequeue the next and run it
            jobs[$i]=$!
        done

        [ $# = 0 ] && { wait; break; }        # - If all jobs were fetched, wait for them to finish and break
    done

    # - read the remaining files
    for f in ${outputs[@]}; do cat $f; done
}

clone() {
    url=$1
    repo_name=$(basename $url .git)

    grn-echo "Cloning $repo_name ..."
    (
        cd $CODE_DIR
        git clone "$url" \
            && grn-echo "Done cloning $repo_name"
    )
}

set-upstream() {
    url=$1
    repo_name=$(basename $url .git)

    # get the repo via github api and extract its parent git_url
    grn-echo "Setting upstream for $repo_name ..."
    parent_url=$(curl -sS -H "$auth_header" $url | jq -r '.parent.git_url')
    (
        cd  $CODE_DIR/$repo_name
        git remote add upstream "$parent_url" --fetch \
            && grn-echo "Upstream set for $repo_name"
    )
}

gitmulticast-clone() {
    repos=$(fetch-repos $repos_url)                                       # fetch all the repos for the user
    git_urls=$(echo "$repos" | jq '.[] | .ssh_url')                       # grab all the remote urls for his/her repos
    forked_repo_urls=$(echo "$repos" | jq '.[] | select(.fork) | .url')   # get the urls of the repos which are forks

    # This is needed because we want each entry of the clone_commands array to
    # correspond to one line of the `jq -r ...` command.
    OLDIFS=$IFS; IFS=$'\n'
    declare -a clone_commands=(
        $(echo $git_urls | jq -r '"clone \(.)"')
    )
    declare -a set_upstream_commands=(
        $(echo $forked_repo_urls | jq -r '"set-upstream \(.)"')
    )
    IFS=$OLDIFS

    parallel "${clone_commands[@]}"          # clone all of the repos in parallel
    parallel "${set_upstream_commands[@]}"   # set upstreams for repos which are forked
}

gitmulticast-pull() {
    OLDIFS=$IFS; IFS=$'\n'
    declare -a pull_commands=(
        $(ls $CODE_DIR -1 | xargs -n1 -I{} echo "git -C $CODE_DIR/{} pull --rebase")
    )
    IFS=$OLDIFS

    parallel "${pull_commands[@]}"
}

gitmulticast-status() {
    OLDIFS=$IFS; IFS=$'\n'
    declare -a status_commands=(
        $(ls $CODE_DIR -1 | xargs -n1 -I{} echo "git -C $CODE_DIR/{} status")
    )
    IFS=$OLDIFS

    parallel "${status_commands[@]}"
}

gitmulticast-${1-clone}
