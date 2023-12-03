1. Change host.txt to your host

2. Change ansible_vars.yml to your values

3. ansible-playbook -i host.txt prepare.yml

4. ansible-playbook -i host.txt webserver.yml -e "@/home/user/scripts/ansible/install_web_server/ansible_vars.yaml"

5. ansible-playbook -i host.txt wordpress.yml


