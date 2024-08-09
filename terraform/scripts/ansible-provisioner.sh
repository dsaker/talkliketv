# add gcp instance ip line after [talkliketv] in inventory.txt
sed '/\[talkliketv\]/{n;s/.*/34.82.99.12/g;}' ../ansible/inventory.txt > output.file
mv output.file ../ansible/inventory.txt

# uncomment first sed for linux, second for mac. replaces CLOUD_HOST_IP in .envrc file
# sed -i 's/^export CLOUD_HOST_IP=.*$/export CLOUD_HOST_IP=34.82.99.12/' ../.envrc
sed -i '' -e 's/^export CLOUD_HOST_IP=.*$/export CLOUD_HOST_IP=34.82.99.12/' ../.envrc

# run ansible playbook locally
# shellcheck disable=SC2154
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i '../ansible/inventory.txt' \
  -e 'gcp_public_ip=34.82.99.12' \
  -e 'db_user=talkliketv' \
  -e 'db_password=talkliketv_password' \
  -e 'db_name=talkliketv' \
  -e 'ansible_user=dustysaker' \
  -e 'ansible_private_key_file=/Users/dustysaker/.ssh/id_ed25519' ../ansible/playbook.yml