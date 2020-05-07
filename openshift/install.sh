```
#!/bin/bash
# Add User to all nodes
sudo useradd -p $(openssl passwd -1 password) pbhagade
echo -e 'Defaults:origin !requiretty\norigin ALL = (root) NOPASSWD:ALL' | tee /etc/sudoers.d/openshift
chmod 440 /etc/sudoers.d/openshift

# On Master Node, login with a user created above and set SSH keypair with no pass-phrase.
 ssh-keygen -q -N ""
 # transfer public-key to other nodes
ssh-copy-id master

# if Firewalld is running, allow SSH
firewall-cmd --add-service=ssh --permanent
firewall-cmd --reload

yum -y install centos-release-openshift-origin310 epel-release docker git pyOpenSSL NetworkManager openshift-ansible
systemctl start docker
systemctl enable docker
systemctl start NetworkManager
systemctl enable NetworkManager
```

```
sudo vi /etc/ansible/hosts
# add follows to the end
[OSEv3:children]
masters
nodes
etcd

[OSEv3:vars]
# admin user created in previous section
ansible_ssh_user=origin
ansible_become=true
openshift_deployment_type=origin

# use HTPasswd for authentication
openshift_master_identity_providers=[{'name': 'htpasswd_auth', 'login': 'true', 'challenge': 'true', 'kind': 'HTPasswdPasswordIdentityProvider'}]
# define default sub-domain for Master node
openshift_master_default_subdomain=apps.srv.world
# allow unencrypted connection within cluster
openshift_docker_insecure_registries=172.30.0.0/16

[masters]
ctrl.srv.world openshift_schedulable=true containerized=false

[etcd]
ctrl.srv.world

[nodes]
# defined values for [openshift_node_group_name] in the file below
# [/usr/share/ansible/openshift-ansible/roles/openshift_facts/defaults/main.yml]
ctrl.srv.world openshift_node_group_name='node-config-master-infra'
node01.srv.world openshift_node_group_name='node-config-compute'
node02.srv.world openshift_node_group_name='node-config-compute'


# run Prerequisites Playbook
ansible-playbook /usr/share/ansible/openshift-ansible/playbooks/prerequisites.yml

# run Deploy Cluster Playbook
ansible-playbook /usr/share/ansible/openshift-ansible/playbooks/deploy_cluster.yml
```
