.PHONY: desktop media_server podium-up podium-down podium-install

desktop:
	ansible-playbook \
		-i desktop/ansible/hosts \
		--vault-password-file ~/.emacs.d/.ansible-vault \
                ${OPTS} \
		desktop/ansible/desktop.yml

media_server:
	ansible-playbook \
		-i media_server/ansible/hosts \
		--vault-password-file ~/.emacs.d/.ansible-vault \
                ${OPTS} \
		media_server/ansible/media_server.yml
