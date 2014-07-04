# removing rbenv if it is already there
if [ -d ~/.rbenv/ ]; then
    rm -r -f ~/.rbenv/
fi

# ensure openssl is installed
sudo apt-get install -y libssl-dev

# get latest rbenv
git clone https://github.com/sstephenson/rbenv.git ~/.rbenv

# get ruby-build
git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
