# add gcp instance ip line after [talkliketv] in inventory.txt
sed '/\[talkliketv\]/{n;s/.*/${instance_ip}/g;}' ../ansible/inventory.txt > output.file
mv output.file ../ansible/inventory.txt

# uncomment first sed for linux, second for mac. replaces CLOUD_HOST_IP in .envrc file
# sed -i 's/^export CLOUD_HOST_IP=.*$/export CLOUD_HOST_IP=${instance_ip}/' ../.envrc
sed -i '' -e 's/^export CLOUD_HOST_IP=.*$/export CLOUD_HOST_IP=${instance_ip}/' ../.envrc

# run ansible playbook locally
# shellcheck disable=SC2154
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i '../ansible/inventory.txt' \
  -e 'gcp_public_ip=${instance_ip}' \
  -e 'db_user=${db_user}' \
  -e 'db_password=${db_password}' \
  -e 'db_name=${db_name}' \
  -e 'ansible_user=${ansible_user}' \
  -e 'ansible_private_key_file=${ansible_private_key_file}' ../ansible/playbook.yml
