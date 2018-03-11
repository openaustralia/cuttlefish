#!/bin/bash

cd provisioning

galaxy_roles=(
	"rvm_io.ruby,v2.0.1"
	"ANXS.postgresql,v1.9.1"
	"geerlingguy.certbot,3.0.0"
	"DavidWittman.redis,1.2.5"
)

echo -e "Setting Ansible Galaxy roles...\n"
for r in "${galaxy_roles[@]}"
do
	ansible-galaxy install --roles-path=./roles $r
done 

if [[ $? -eq 0 ]]
then
	echo -e "Provisioning the server...\n"
	ansible-playbook -i hosts --vault-password-file=~/.cuttlefish_ansible_vault_pass.txt -u root playbook.yml
fi