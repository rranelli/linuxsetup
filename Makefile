.PHONY: desktop media_server

desktop:
	ansible-playbook \
		-i desktop/ansible/hosts \
		--ask-become-pass \
		--vault-password-file ~/.emacs.d/.ansible-vault \
		desktop/ansible/desktop.yml

media_server:
	ansible-playbook \
		-i media_server/ansible/hosts \
		--ask-become-pass \
		--vault-password-file ~/.emacs.d/.ansible-vault \
		media_server/ansible/media_server.yml
