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

RUBY_VERSION		:= 2.1.5
EMACS_VERSION		:= 24.4
EMACS			:= emacs-$(EMACS_VERSION)

define touch-module
	@$(MKDIR) $(MODULE_DIR)
	@$(TOUCH) $@
endef

# the 'desktop' target is not a required module anymore
REQUIRED_MODULES = \
	bash-completion	\
	clojure		\
	code		\
	dotfiles	\
	emacs		\
	git		\
	repositories	\
	ruby

OPTIONAL_MODULES = \
	desktop		\
	google-chrome	\
	remote-desktop	\
	smlnj

define add-repositories
	echo $(REPOSITORIES) | xargs -n 1 $(SUDO) $(ADD_REPO)
	$(SUDO) $(UPDATE_REPO_CACHE)
endef

REPOSITORIES = \
	ppa:brightbox/ruby-ng			\
	ppa:cassou/emacs			\
	ppa:chris-lea/node.js			\
	ppa:git-core/ppa			\
	ppa:lvillani/silversearcher		\
	ppa:nviennot/tmate			\
	ppa:paolorotolo/copy			\
	ppa:webupd8team/java

define install-packages
	$(SUDO) $(INSTALL_PACKAGE) $(PACKAGES)
endef

PACKAGES = \
	aspell-pt-br			\
	bash-completion			\
	build-essential			\
	copy 				\
	curl				\
	dnsutils			\
	firefox				\
	ftp				\
	g++-multilib			\
	gcc-multilib			\
	git				\
	guile-2.0-dev			\
	html2text			\
	icedtea-7-plugin		\
	libcurl3			\
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
	redis-server 			\
	remmina				\
	ruby2.1				\
	samba				\
	silversearcher-ag		\
	spotify-client			\
	ssh				\
	surfraw				\
	telnet				\
	texlive				\
	tilda				\
	tmate				\
	tmux				\
	w3m				\
	wget				\
	wl				\
	xdg-utils			\
	xrdp

.PHONY: install clean

###
# It all begins here
install: $(REQUIRED_MODULES)

optional: $(OPTIONAL_MODULES)

all: install optional

clean:
	rm -rf $(MODULE_DIR)

###
# Install package that allows to add more repositories
add-repo-package: $(MODULE_DIR)/add-repo-package
$(MODULE_DIR)/add-repo-package:
	$(SUDO) $(INSTALL_PACKAGE) $(ADD_REPO_PACKAGE)
	$(touch-module)

###
# Add external repositories for packages
repositories: $(MODULE_DIR)/repositories | add-repo-package mongodb-repo spotify-repo
$(MODULE_DIR)/repositories:
	$(add-repositories)
	$(touch-module)

mongodb-repo: $(MODULE_DIR)/mongodb-repo
$(MODULE_DIR)/mongodb-repo:
	echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | $(SUDO) tee /etc/apt/sources.list.d/mongodb.list
	$(SUDO) apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
	$(touch-module)

spotify-repo: $(MODULE_DIR)/spotify-repo
$(MODULE_DIR)/spotify-repo:
	$(SUDO) apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 94558F59
	$(SUDO) su -c "echo 'deb http://repository.spotify.com stable non-free' >> /etc/apt/sources.list"
	$(touch-module)

###
# Install packages
packages: $(MODULE_DIR)/packages | repositories
$(MODULE_DIR)/packages:
	$(install-packages)
	$(touch-module)

###
# Install programming stuff
dotfiles: $(MODULE_DIR)/dotfiles | code
$(MODULE_DIR)/dotfiles:
	$(CODE_DIR)/linuxsetup/scripts/setup_dotfiles
	$(touch-module)

git: $(MODULE_DIR)/git | packages
$(MODULE_DIR)/git:
	scripts/setup_git
	$(touch-module)

ruby: $(MODULE_DIR)/ruby | packages
$(MODULE_DIR)/ruby:
	git clone https://github.com/sstephenson/rbenv.git $(HOME)/.rbenv --depth=1
	git clone https://github.com/sstephenson/ruby-build.git $(HOME)/.rbenv/plugins/ruby-build --depth=1

	$(HOME)/.rbenv/bin/rbenv install $(RUBY_VERSION)
	$(HOME)/.rbenv/bin/rbenv global $(RUBY_VERSION)
	$(HOME)/.rbenv/bin/rbenv rehash

	$(touch-module)

code: $(MODULE_DIR)/code | packages git ruby
$(MODULE_DIR)/code:
	$(SUDO) gem install git_multicast
	$(MKDIR) $(CODE_DIR)
	cd $(CODE_DIR) && git_multicast clone rranelli
	$(touch-module)

clojure: $(MODULE_DIR)/clojure | packages
$(MODULE_DIR)/clojure:
	$(MKDIR) $(HOME)/.lein
	wget https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein
	mv -f lein ~/.lein/; chmod 755 ~/.lein/lein
	$(touch-module)

smlnj: $(MODULE_DIR)/smlnj | packages
$(MODULE_DIR)/smlnj:
	wget 'http://smlnj.org/dist/working/110.74/config.tgz'
	$(MKDIR) $(HOME)/.sml
	mv config.tgz $(HOME)/.sml
	cd $(HOME)/.sml && \
		tar -xvf config.tgz && \
		config/install.sh && \
		rm -rf config.tgz config/
	$(touch-module)

bash-completion: $(MODULE_DIR)/bash-completion | packages
$(MODULE_DIR)/bash-completion:
	$(SUDO) su -c "echo 'set completion-ignore-case on' >> /etc/inputrc"
	$(SUDO) cp -f bash_completion.d/* /etc/bash_completion.d/
	$(touch-module)

remote-desktop: $(MODULE_DIR)/remote-desktop | packages
$(MODULE_DIR)/remote-desktop:
	echo lxsession -s LXDE -e LXDE > ~/.xsession
	$(SUDO) service xrdp restart
	$(touch-module)

###
# Install the best editor in the world
emacs: $(MODULE_DIR)/emacs | packages code
$(MODULE_DIR)/emacs:
	wget http://ftpmirror.gnu.org/emacs/$(EMACS).tar.xz
	tar -xvf $(EMACS).tar.xz

	$(SUDO) apt-get build-dep emacs24 -y

	cd $(EMACS) && ./configure
	make -C $(EMACS)/
	$(SUDO) make -C $(EMACS)/ install

	rm -rf $(EMACS)*

	$(CODE_DIR)/emacs-dotfiles/setup_dotfiles
	$(touch-module)

editor: emacs

###
# Install desktop stuff
desktop: $(MODULE_DIR)/desktop | install google-chrome
$(MODULE_DIR)/desktop: PACKAGES = \
		elementary-.*-icons		\
		elementary-.*-theme		\
		elementary-tweaks		\
		elementary-wallpaper-collection	\
		dconf-tools			\
		indicator-synapse		\
		super-wingpanel			\
		wingpanel-slim			\
		deluge				\
		deluge-console			\
		deluged				\
		calibre
$(MODULE_DIR)/desktop: REPOSITORIES = \
		ppa:versable/elementary-update \
		ppa:heathbar/wingpanel-slim
$(MODULE_DIR)/desktop:
	cd $(CODE_DIR)/emacs-dotfiles && $(SUDO) ./setup_shortcut

	$(add-repositories)
	$(install-packages)

	$(touch-module)

google-chrome: $(MODULE_DIR)/google-chrome
$(MODULE_DIR)/google-chrome:
	wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
	$(SUDO) dpkg -i google-chrome*
	rm google-chrome*
	$(touch-module)
