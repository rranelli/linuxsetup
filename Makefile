.PHONY: desktop media_server podium-up podium-down podium-install

desktop:
	ansible-playbook \
		-i desktop/ansible/hosts \
		--vault-password-file ~/bin/ansible-vault-pwd \
                ${OPTS} \
		desktop/ansible/desktop.yml

media_server:
	ansible-playbook \
		-i media_server/ansible/hosts \
		--vault-password-file ~/bin/ansible-vault-pwd \
                ${OPTS} \
		media_server/ansible/media_server.yml

vault-unlock:
	@for f in $$(ag '\$ANSIBLE_VAULT;' -l desktop/ media_server/ | tee -a .unlocked); do \
	  echo decrypting $$f ; \
	  ansible-vault decrypt --vault-password-file ~/bin/ansible-vault-pwd "$$f"; \
	done

vault-lock:
	@for f in $$(cat .unlocked); do \
	  echo encrypting $$f ; \
	  ansible-vault encrypt --vault-password-file ~/bin/ansible-vault-pwd "$$f"; \
	done || rm .unlocked
	@rm .unlocked || true
