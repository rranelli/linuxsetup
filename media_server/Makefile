## system specific commands
SUDO			:= sudo
MKDIR			:= mkdir --parents
LINK			:= ln --symbolic --force
TOUCH			:= touch

MODULE_DIR		:= $(HOME)/.modules
INSTALL_PACKAGE_FLAGS	:= --yes --force-yes
INSTALL_PACKAGE		:= apt-get install $(INSTALL_PACKAGE_FLAGS)

ADD_REPO_FLAGS		:= -y
ADD_REPO		:= apt-add-repository $(ADD_REPO_FLAGS)
ADD_REPO_PACKAGE	:= python-software-properties
UPDATE_REPO_CACHE	:= apt-get update -qq

define touch-module
	@$(MKDIR) $(MODULE_DIR)
	@$(TOUCH) $@
endef

REQUIRED_MODULES = \
	dotfiles 	\
	git		\
	bash-completion \
	noip2		\
	nginx 		\
	init-files	\
	monit		\
	copy

define add-repositories
	echo $(REPOSITORIES) | xargs -n 1 $(SUDO) $(ADD_REPO)
	$(SUDO) $(UPDATE_REPO_CACHE)
endef

REPOSITORIES = \
	ppa:git-core/ppa		\
	ppa:pi-rho/dev

define install-packages
	$(SUDO) $(INSTALL_PACKAGE) $(PACKAGES)
endef

PACKAGES = \
	bash-completion			\
	build-essential			\
	curl				\
	deluge-console			\
	deluge-web			\
	deluged				\
	dnsutils			\
	ftp				\
	git				\
	nginx 				\
	openssh-server			\
	python-software-properties	\
	ssh				\
	telnet				\
	tmux				\
	wget

###
# It all begins here
all: install
install: $(REQUIRED_MODULES)
clean:
	rm -rf $(MODULE_DIR)

###
# Install packages
packages: $(MODULE_DIR)/packages repositories
$(MODULE_DIR)/packages:
	$(install-packages)
	$(touch-module)

###
# Add external repositories for packages
repositories: $(MODULE_DIR)/repositories
$(MODULE_DIR)/repositories: | add-repo-package
	$(add-repositories)
	$(touch-module)

###
# Install package that allows to add more repositories
add-repo-package: $(MODULE_DIR)/add-repo-package
$(MODULE_DIR)/add-repo-package:
	$(SUDO) $(INSTALL_PACKAGE) $(ADD_REPO_PACKAGE)
	$(touch-module)

git: $(MODULE_DIR)/git repositories
$(MODULE_DIR)/git: | packages
	$(CURDIR)/scripts/setup_git
	$(touch-module)

dotfiles: $(MODULE_DIR)/dotfiles
$(MODULE_DIR)/dotfiles:
	$(CURDIR)/scripts/setup_dotfiles
	$(touch-module)

bash-completion: $(MODULE_DIR)/bash-completion
$(MODULE_DIR)/bash-completion: | packages
	$(SUDO) su -c "echo 'set completion-ignore-case on' >> /etc/inputrc"
	$(SUDO) cp -f bash_completion.d/* /etc/bash_completion.d/
	$(touch-module)

###
# copying init-files
init-files: $(MODULE_DIR)/init-files
$(MODULE_DIR)/init-files: | packages noip2 calibre deluge
	$(SUDO) $(LINK) $(CURDIR)/media_server/init-scripts/noip2.init.d /etc/init.d/noip2
	$(SUDO) $(LINK) $(CURDIR)/media_server/init-scripts/calibre-server.init.d /etc/init.d/calibre-server
	$(SUDO) $(LINK) $(CURDIR)/media_server/init-scripts/deluge-web.init.d /etc/init.d/deluge-web

	$(touch-module)

copy: $(MODULE_DIR)/copy
$(MODULE_DIR)/copy: | packages
	wget https://copy.com/install/linux/Copy.tgz
	tar xvzf Copy.tgz

	$(SUDO) cp -r copy /opt

	$(SUDO) $(LINK) /opt/copy/x86_64/CopyAgent /usr/bin/copy-agent
	$(SUDO) $(LINK) /opt/copy/x86_64/CopyConsole /usr/bin/copy-console

	rm Copy.tgz
	rm -rf copy/

	echo "Now you can run"
	echo "./CopyConsole -u=the_mail_you_signed_up_with -r=/home/your_linux_username/copy -p=the_password_you_signed_up_with"
	$(touch-module)

noip2: $(MODULE_DIR)/noip2
$(MODULE_DIR)/noip2: | packages
	wget http://www.no-ip.com/client/linux/noip-duc-linux.tar.gz
	tar xzf noip-duc-linux.tar.gz
	cd no-ip-2.1.9
	make
	make install
	rm noip-duc-linux.tar.gz
	rm -rf no-ip-2.1.9
	$(touch-module)

plex: $(MODULE_DIR)/plex
$(MODULE_DIR)/plex: | packages
	wget https://downloads.plex.tv/plex-media-server/0.9.11.16.958-80f1748/plexmediaserver_0.9.11.16.958-80f1748_amd64.deb
	$(SUDO) dpkg -i plexmediaserver_0.9.11.16.958-80f1748_amd64.deb
	rm plexmediaserver_0.9.11.16.958-80f1748_amd64.deb
	$(touch-module)

nginx: $(MODULE_DIR)/nginx
$(MODULE_DIR)/nginx: NGINX_FILES_PATH:=$(CURDIR)/media_server/nginx
$(MODULE_DIR)/nginx: | packages plex
	$(SUDO) $(LINK) $(NGINX_FILES_PATH)/.htpasswd /etc/nginx/.htpasswd
	$(SUDO) $(LINK) $(NGINX_FILES_PATH)/sites-enabled/root /etc/nginx/sites-enabled/root
	$(SUDO) $(LINK) $(NGINX_FILES_PATH)/sites-enabled/plex /etc/nginx/sites-enabled/plex
	$(SUDO) $(LINK) $(NGINX_FILES_PATH)/sites-enabled/calibre /etc/nginx/sites-enabled/calibre
	$(SUDO) $(LINK) $(NGINX_FILES_PATH)/sites-enabled/torrent /etc/nginx/sites-enabled/torrent
	$(SUDO) $(LINK) $(NGINX_FILES_PATH)/sites-enabled/monit /etc/nginx/sites-enabled/monit
	$(touch-module)

monit: $(MODULE_DIR)/monit
$(MODULE_DIR)/monit: MONIT_FILES_PATH:=$(CURDIR)/media_server/monit
$(MODULE_DIR)/monit: | init-files
	$(SUDO) $(LINK) $(MONIT_FILES_PATH)/calibre-server.monit /etc/monit/conf.d/calibre-server
	$(SUDO) $(LINK) $(MONIT_FILES_PATH)/noip2.monit /etc/monit/conf.d/noip2
	$(SUDO) $(LINK) $(MONIT_FILES_PATH)/deluge-web.monit /etc/monit/conf.d/deluge-web
	$(SUDO) $(LINK) $(MONIT_FILES_PATH)/deluged.monit /etc/monit/conf.d/deluged
	$(SUDO) $(LINK) $(MONIT_FILES_PATH)/cronjobs.monit /etc/monit/conf.d/cronjobs

beets: $(MODULE_DIR)/beets
$(MODULE_DIR)/beets: | packages
	$(SUDO) pip install beets
