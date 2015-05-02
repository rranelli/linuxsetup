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
	elixir		\
	emacs		\
	git		\
	langtool 	\
	repositories	\
	ruby

OPTIONAL_MODULES = \
	cask 		\
	desktop		\
	docker		\
	google-chrome	\
	haskell		\
	octave		\
	smlnj		\
	vagrant

define add-repositories
	echo $(REPOSITORIES) | xargs -n 1 $(SUDO) $(ADD_REPO)
	$(SUDO) $(UPDATE_REPO_CACHE)
endef

REPOSITORIES = \
	ppa:brightbox/ruby-ng		\
	ppa:cassou/emacs		\
	ppa:chris-lea/node.js		\
	ppa:git-core/ppa		\
	ppa:nviennot/tmate		\
	ppa:paolorotolo/copy		\
	ppa:webupd8team/java		\
	ppa:pi-rho/dev

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
	esl-erlang			\
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
	libqt4-opengl			\
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
	network-manager-openvpn		\
	nodejs				\
	openssh-server			\
	oracle-java8-installer		\
	python-software-properties	\
	rdesktop			\
	redis-server 			\
	remmina				\
	ruby2.1				\
	ruby2.1-dev			\
	samba				\
	silversearcher-ag		\
	ssh				\
	surfraw				\
	telnet				\
	texlive				\
	tmate				\
	tmux				\
	w3m				\
	wget				\
	wl				\
	wordnet				\
	xdg-utils

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
repositories: $(MODULE_DIR)/repositories
$(MODULE_DIR)/repositories: | add-repo-package mongodb-repo
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
packages: repositories $(MODULE_DIR)/packages
$(MODULE_DIR)/packages:
	$(install-packages)
	$(touch-module)

###
# Install programming stuff
dotfiles: $(MODULE_DIR)/dotfiles
$(MODULE_DIR)/dotfiles:
	$(CURDIR)/scripts/setup_dotfiles
	$(touch-module)

git: $(MODULE_DIR)/git
$(MODULE_DIR)/git: | packages
	$(CODE_DIR)/linuxsetup/scripts/setup_git
	$(touch-module)

ruby: $(MODULE_DIR)/ruby
$(MODULE_DIR)/ruby: | packages
	git clone https://github.com/sstephenson/rbenv.git $(HOME)/.rbenv --depth=1
	git clone https://github.com/sstephenson/ruby-build.git $(HOME)/.rbenv/plugins/ruby-build --depth=1

	$(HOME)/.rbenv/bin/rbenv install $(RUBY_VERSION)
	$(HOME)/.rbenv/bin/rbenv global $(RUBY_VERSION)
	$(HOME)/.rbenv/bin/rbenv rehash

	$(touch-module)

code: $(MODULE_DIR)/code git
$(MODULE_DIR)/code: | packages ruby dotfiles
	gem install git_multicast
	$(MKDIR) $(CODE_DIR)
	cd $(CODE_DIR) && git_multicast clone rranelli
	$(touch-module)

clojure: $(MODULE_DIR)/clojure
$(MODULE_DIR)/clojure: | packages
	$(MKDIR) $(HOME)/.lein
	wget https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein
	mv -f lein ~/.lein/; chmod 755 ~/.lein/lein
	$(touch-module)

smlnj: $(MODULE_DIR)/smlnj
$(MODULE_DIR)/smlnj: | packages
	wget 'http://smlnj.org/dist/working/110.74/config.tgz'
	$(MKDIR) $(HOME)/.sml
	mv config.tgz $(HOME)/.sml
	cd $(HOME)/.sml && \
		tar -xvf config.tgz && \
		config/install.sh && \
		rm -rf config.tgz config/
	$(touch-module)

elixir: $(MODULE_DIR)/elixir
$(MODULE_DIR)/elixir: | code
	cd $(HOME)/code/elixir && make clean test
	$(touch-module)

haskell: $(MODULE_DIR)/haskell
$(MODULE_DIR)/haskell: TARFILE := haskell-platform-2014.2.0.0-unknown-linux-x86_64.tar.gz
$(MODULE_DIR)/haskell: TARPATH := $(CURDIR)/$(TARFILE)
$(MODULE_DIR)/haskell: | packages
	wget https://www.haskell.org/platform/download/2014.2.0.0/$(TARFILE)
	cd / && $(SUDO) tar xvf $(TARPATH)

	$(SUDO) /usr/local/haskell/ghc-7.8.3-x86_64/bin/activate-hs

	rm $(TARPATH)
	$(touch-module)

octave: $(MODULE_DIR)/octave
$(MODULE_DIR)/octave: PACKAGES = octave
$(MODULE_DIR)/octave: REPOSITORIES = ppa:octave/stable
$(MODULE_DIR)/octave:
	$(add-repositories)
	$(install-packages)

	$(touch-module)

bash-completion: $(MODULE_DIR)/bash-completion
$(MODULE_DIR)/bash-completion: | packages
	$(SUDO) su -c "echo 'set completion-ignore-case on' >> /etc/inputrc"
	$(SUDO) cp -f bash_completion.d/* /etc/bash_completion.d/
	$(touch-module)

editor: emacs
emacs: $(MODULE_DIR)/emacs
$(MODULE_DIR)/emacs: | packages code
	wget http://ftpmirror.gnu.org/emacs/$(EMACS).tar.xz
	tar -xvf $(EMACS).tar.xz

	$(SUDO) apt-get build-dep emacs24 -y

	cd $(EMACS) && ./configure --with-x-toolkit=lucid
	make -C $(EMACS)/
	$(SUDO) make -C $(EMACS)/ install

	rm -rf $(EMACS)*

	$(CODE_DIR)/emacs-dotfiles/setup_dotfiles
	$(touch-module)

cask: $(MODULE_DIR)/cask
$(MODULE_DIR)/cask: | packages
	curl -fsSL https://raw.githubusercontent.com/cask/cask/master/go | python
	$(touch-module)

langtool: $(MODULE_DIR)/langtool | packages
$(MODULE_DIR)/langtool: LANGTOOL=LanguageTool-2.8
$(MODULE_DIR)/langtool: LANGTOOL_ZIP_URL=https://languagetool.org/download/$(LANGTOOL).zip
$(MODULE_DIR)/langtool:
	wget $(LANGTOOL_ZIP_URL)
	unzip $(LANGTOOL)
	mv $(LANGTOOL)/ $(HOME)/.langtool
	rm $(LANGTOOL).zip
	$(touch-module)

###
# Install desktop stuff
desktop: $(MODULE_DIR)/desktop
$(MODULE_DIR)/desktop: PACKAGES = \
		calibre				\
		dconf-tools			\
		deluge				\
		deluge-console			\
		deluged				\
		elementary-.*-theme		\
		elementary-tweaks		\
		elementary-wallpapers-extra	\
		empathy				\
		firefox				\
		flashplugin-installer		\
		indicator-synapse		\
		spotify-client
$(MODULE_DIR)/desktop: REPOSITORIES = \
		ppa:mpstark/elementary-tweaks-daily 	\
		ppa:heathbar/super-wingpanel		\
		ppa:elementary-os/unstable-upstream
$(MODULE_DIR)/desktop: | install google-chrome spotify-repo
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

keysnail:
	wget https://github.com/mooz/keysnail/raw/master/keysnail.xpi
	firefox keysnail.xpi

docker: $(MODULE_DIR)/docker
$(MODULE_DIR)/docker: | packages
	$(SUDO) apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys
	$(SUDO) sh -c "echo deb https://get.docker.com/ubuntu docker main > /etc/apt/sources.list.d/docker.list"
	$(SUDO) apt-get update -qq
	$(SUDO) apt-get install --yes --force-yes lxc-docker

	# adding current user to docker group
	$(SUDO) usermod -a -G docker $(USER)

	$(SUDO) service docker restart
	$(touch-module)

vagrant: $(MODULE_DIR)/vagrant
$(MODULE_DIR)/vagrant: | packages virtualbox
	wget https://dl.bintray.com/mitchellh/vagrant/vagrant_1.7.2_x86_64.deb
	$(SUDO) dpkg -i vagrant_1.7.2_x86_64.deb
	rm vagrant_*.deb
	$(touch-module)

virtualbox: $(MODULE_DIR)/virtualbox
$(MODULE_DIR)/virtualbox:
	wget http://download.virtualbox.org/virtualbox/4.3.24/virtualbox-4.3_4.3.24-98716~Ubuntu~precise_amd64.deb
	$(SUDO) dpkg -i virtualbox-4.3_4.3.24-98716~Ubuntu~precise_amd64.deb
	rm virtualbox-*.deb
	$(touch-module)
