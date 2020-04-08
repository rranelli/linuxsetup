.PHONY: desktop media_server

desktop:
	ansible-playbook \
		-i desktop/ansible/hosts \
		--ask-become-pass \
		--vault-password-file ~/.emacs.d/.ansible-vault \
                ${OPTS} \
		desktop/ansible/desktop.yml

media_server:
	ansible-playbook \
		-i media_server/ansible/hosts \
		--vault-password-file ~/.emacs.d/.ansible-vault \
                ${OPTS} \
		media_server/ansible/media_server.yml

podium:
	ansible-playbook \
		-i desktop/ansible/hosts \
		--ask-become-pass \
		--vault-password-file ~/.emacs.d/.ansible-vault \
                --tags "podium" \
                ${OPTS} \
		desktop/ansible/desktop.yml
