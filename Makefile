## system specific commands
SUDO			:= sudo
MKDIR			:= mkdir --parents
LINK			:= ln --symbolic --force
TOUCH			:= touch

CODE_DIR		:= $(HOME)/code
MODULE_DIR		:= $(HOME)/.modules
INSTALL_PACKAGE_FLAGS	:= -y
INSTALL_PACKAGE		:= apt-get install $(INSTALL_PACKAGE_FLAGS)

ADD_REPO_FLAGS		:= -y
ADD_REPO		:= apt-add-repository $(ADD_REPO_FLAGS)
ADD_REPO_PACKAGE	:= python-software-properties
UPDATE_REPO_CACHE	:= apt-get update -qq

RUBY_VERSION		:= 2.1.2

define touch-module
@$(MKDIR) $(MODULE_DIR)
@$(TOUCH) $(MODULE_DIR)/$(MODULE)
endef

MODULES = \
	bash-completion	\
	clojure		\
	code		\
	desktop		\
	dotfiles	\
	emacs		\
	git		\
	remote-desktop	\
	repositories	\
	ruby		\
	smlnj

REPOSITORIES = \
	ppa:brightbox/ruby-ng-experimental	\
	ppa:cassou/emacs			\
	ppa:chris-lea/node.js			\
	ppa:git-core/ppa			\
	ppa:lvillani/silversearcher		\
	ppa:nviennot/tmate			\
	ppa:paolorotolo/copy

PACKAGES = \
	aspell-pt-br			\
	bash-completion			\
	build-essential			\
	curl				\
	deluge				\
	deluge-console			\
	deluged				\
	dnsutils			\
	firefox				\
	g++-multilib			\
	gcc-multilib			\
	git				\
	guile-2.0-dev			\
	html2text			\
	icedtea-7-plugin		\
	libcurl3			\
	copy				\
	libcurl4-openssl-dev		\
	libgmime-2.6-dev		\
	libnspr4-0d			\
	libreadline6			\
	libreadline6-dev		\
	libsqlite3-dev			\
	libssl-dev			\
	libwebkit-dev			\
	libxapian-dev			\
	libxss1				\
	lxde				\
	markdown			\
	maven				\
	mongodb-org			\
	nodejs				\
	openssh-server			\
	oracle-java8-installer		\
	python-software-properties	\
	rdesktop			\
	remmina				\
	ruby2.0				\
	samba				\
	silversearcher-ag		\
	spotify-client			\
	ssh				\
	surfraw				\
	telnet				\
	tmate				\
	tmux				\
	w3m				\
	wget				\
	wingpanel-slim			\
	wl				\
	xdg-utils			\
	xrdp

.PHONY: install clean

###
# It all begins here
install: $(MODULES)

clean:
	rm -rf $(MODULE_DIR)

###
# Install package that allows to add more repositories
add-repo-package: $(MODULE_DIR)/add-repo-package
$(MODULE_DIR)/add-repo-package: MODULE = add-repo-package
$(MODULE_DIR)/add-repo-package:
	$(SUDO) $(INSTALL_PACKAGE) $(ADD_REPO_PACKAGE)
	$(touch-module)

###
# Add external repositories for packages
repositories: add-repo-package mongodb-repo spotify-repo $(MODULE_DIR)/repositories
$(MODULE_DIR)/repositories: MODULE = repositories
$(MODULE_DIR)/repositories:
	echo $(REPOSITORIES) | xargs -n 1 $(SUDO) $(ADD_REPO)
	$(add-mongo-repo)
	$(add-spotify-repo)

	$(SUDO) $(UPDATE_REPO_CACHE)
	$(touch-module)

mongodb-repo: $(MODULE_DIR)/mongodb-repo
$(MODULE_DIR)/mongodb-repo: MODULE = mongodb-repo
$(MODULE_DIR)/mongodb-repo:
	echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | $(SUDO) tee /etc/apt/sources.list.d/mongodb.list
	$(SUDO) apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
	$(touch-module)

spotify-repo: $(MODULE_DIR)/spotify-repo
$(MODULE_DIR)/spotify-repo: MODULE = spotify-repo
$(MODULE_DIR)/spotify-repo:
	$(SUDO) apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 94558F59
	$(SUDO) su -c "echo 'deb http://repository.spotify.com stable non-free' >> /etc/apt/sources.list"
	$(touch-module)

###
# Installs packages
packages: repositories $(MODULE_DIR)/packages
$(MODULE_DIR)/packages: MODULE = packages
$(MODULE_DIR)/packages:
	$(SUDO) $(INSTALL_PACKAGE) $(PACKAGES)
	$(touch-module)

###
# Installs programming stuff
dotfiles: $(MODULE_DIR)/dotfiles
$(MODULE_DIR)/dotfiles: MODULE = dotfiles
$(MODULE_DIR)/dotfiles:
	scripts/setup_dotfiles
	$(touch-module)

git: packages $(MODULE_DIR)/git
$(MODULE_DIR)/git: MODULE = git
$(MODULE_DIR)/git:
	scripts/setup_git
	$(touch-module)

ruby: packages $(MODULE_DIR)/ruby
$(MODULE_DIR)/ruby: MODULE = ruby
$(MODULE_DIR)/ruby:
	git clone https://github.com/sstephenson/rbenv.git $(HOME)/.rbenv
	git clone https://github.com/sstephenson/ruby-build.git $(HOME)/.rbenv/plugins/ruby-build

	$(HOME)/.rbenv/bin/rbenv install $(RUBY_VERSION)
	$(HOME)/.rbenv/bin/rbenv global $(RUBY_VERSION)
	$(HOME)/.rbenv/bin/rbenv rehash

	$(touch-module)

code: packages git ruby $(MODULE_DIR)/code
$(MODULE_DIR)/code: MODULE = code
$(MODULE_DIR)/code:
	gem install git_multicast
	cd $(CODE_DIR) && git_multicast clone rranelli
	$(touch-module)

clojure: packages $(MODULE_DIR)/clojure
$(MODULE_DIR)/clojure: MODULE = clojure
$(MODULE_DIR)/clojure:
	$(MKDIR) $(HOME)/.lein
	wget https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein
	mv -f lein ~/.lein/; chmod 755 ~/.lein/lein
	$(touch-module)

smlnj: packages $(MODULE_DIR)/smlnj
$(MODULE_DIR)/smlnj: MODULE = smlnj
$(MODULE_DIR)/smlnj:
	wget 'http://smlnj.org/dist/working/110.74/config.tgz'
	$(MKDIR) $(HOME)/.sml
	mv config.tgz $(HOME)/.sml
	cd $(HOME)/.sml && \
		tar -xvf config.tgz && \
		config/install.sh && \
		rm -rf config.tgz config/
	$(touch-module)

bash-completion: packages $(MODULE_DIR)/bash-completion
$(MODULE_DIR)/bash-completion: MODULE = bash-completion
$(MODULE_DIR)/bash-completion:
	$(SUDO) su -c "echo 'set completion-ignore-case on' >> /etc/inputrc"
	$(SUDO) cp -f bash_completion.d/* /etc/bash_completion.d/
	$(touch-module)

###
# Installs the best editor in the world
emacs: packages code $(MODULE_DIR)/emacs
$(MODULE_DIR)/emacs: MODULE = emacs
$(MODULE_DIR)/emacs:
	wget http://ftpmirror.gnu.org/emacs/emacs-24.4.tar.xz
	tar -xvf emacs-24.4.tar.xz

	cd emacs-24.4 && \
		./configure && \
		make && \
		$(SUDO) make install

	rm -rf emacs-24.*

	$(CODE_DIR)/emacs-dotfiles/setup_dotfiles
	$(touch-module)

###
# Installs desktop stuff
remote-desktop: packages $(MODULE_DIR)/remote-desktop
$(MODULE_DIR)/remote-desktop: MODULE = remote-desktop
$(MODULE_DIR)/remote-desktop:
	echo lxsession -s LXDE -e LXDE > ~/.xsession
	$(SUDO) service xrdp restart
	$(touch-module)

desktop: packages $(MODULE_DIR)/desktop
$(MODULE_DIR)/desktop: MODULE = desktop
$(MODULE_DIR)/desktop:
	wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
	$(SUDO) dpkg -i google-chrome*
	$(SUDO) rm google-chrome*

	$(SUDO) $(INSTALL_PACKAGE) calibre

	$(SUDO) $(ADD_REPO) ppa:versable/elementary-update

	$(SUDO) $(INSTALL_PACKAGE) elementary-.*-icons \
		elementary-.*-theme \
		elementary-tweaks \
		elementary-wallpaper-collection \
		dconf-tools \
		indicator-synapse \
		super-wingpanel
	$(touch-module)
