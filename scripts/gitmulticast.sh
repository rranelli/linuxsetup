#!/usr/bin/env bash
set -euo pipefail # these don't play well with bashdb;

#
## Setup environment
#
: ${GITHUB_USER:=rranelli}
: ${GITHUB_API_TOKEN:=$(mimipass get github-api-token)}

auth_header="Authorization: token $GITHUB_API_TOKEN"
repos_url="https://api.github.com/users/$GITHUB_USER/repos"

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
check-command jq mimipass

#
## Functions
#
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

    # Record the number of jobs to run
    total_jobs=$#

    for n in $(eval echo {0..$POOL_SIZE}); do            # Start the first batch:
        [ $# = 0 ] && break                              # - check if there are still jobs to run
        $1 &                                             # - dequeue the next job and run it in the background:

        jobs[$n]=$!; shift                               # - record the n-th job PID in the `jobs` array:
    done

    while :; do                                          # While the jobs are not done:
        done=0
        for i in ${!jobs[@]}; do                         # - For each running process
            kill -0 ${jobs[$i]} 2>/dev/null && continue  # --- Check if process is still alive
            (( ++done ))                                 # --- If it is not, it means its done

            [ $# = 0 ] && continue                       # --- Check if there are still jobs to run
            $1 &                                         # --- If there are, dequeue the next and run it
            jobs[$i]=$!; shift
        done

        if [ $# = 0 ] && [ $done = ${#jobs[@]} ]; then   # - If all jobs were fetched, and all jobs are done
            break                                        # --- Break out of the infinite loop
        fi
    done
}

clone() {
    url=$1
    repo_name=$(basename $url .git)

    grn-echo "Cloning $repo_name ..."
    (
        cd ~/code
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
        cd ~/code/$repo_name
        git remote add upstream "$parent_url" --fetch \
            && grn-echo "Upstream set for $repo_name"
    )
}

#
## Actual work
#
repos=$(fetch-repos $repos_url)                                       # fetch all the repos for the user
git_urls=$(echo "$repos" | jq '.[] | .git_url')                       # grab all the git url for his/her repos
forked_repo_urls=$(echo "$repos" | jq '.[] | select(.fork) | .url')   # get the urls of the repos which are forks

# This is needed because we want each entry of the clone_commands array to
# correspond to one line of the `jq -r ...` command.
declare -a clone_commands set_upstream_commands
OLDIFS=$IFS; IFS=$'\n'
clone_commands=(
    $(echo $git_urls | jq -r '"clone \(.)"')
)
set_upstream_commands=(
    $(echo $forked_repo_urls | jq -r '"set-upstream \(.)"')
)
IFS=$OLDIFS

parallel "${clone_commands[@]}"          # clone all of the repos in parallel
parallel "${set_upstream_commands[@]}"   # set upstreams for repos which are forked
