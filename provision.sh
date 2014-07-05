# options: -p for personal setup
#          -e for elementaryos setup

# add repositories
./setup_repositories.sh

# calls the files in this repository
./setup_installs.sh
./setup_rbenv.sh
./setup_editor.sh
./setup_git.sh
./setup_dotfiles.py

# clones emacs repository
git clone https://github.com/rranelli/emacs-dotfiles.git

# install and configure emacs
cd emacs-dotfiles
./setup_dotfiles.sh

# I don't know what i'm doing
TEMP=`getopt -o pe:: --long p-long,e-long:: \
     -n 'example.bash' -- "$@"`
if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi

eval set -- "$TEMP"

while true; do
    case "$1" in
        -p) sh setup_personal; shift ;;
        -e) sh setup_elementary; shift 2;;
        --) shift; break;;
        *) echo "Internal error"; exit 1 ;;
    esac
done
