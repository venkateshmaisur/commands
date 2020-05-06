# Openshift

### Installing KVM Components

1. First, verify your CPU supports virtualization:
```
grep -E '(vmx|svm)' /proc/cpuinfo
```
We should get either the word `vmx` or `svm` in the output, otherwise CPU doesn’t support virtualization.

2. Install KVM and associated packages:
```bash
yum install qemu-kvm qemu-img virt-manager libvirt libvirt-python libvirt-client virt-install virt-viewer bridge-utils -y
```

3. Enable and start libvirtd:
```
systemctl enable --now libvirtd
```

### Usercreate

```bash
#!/bin/bash
# Create users for Arlen, Texas
for i in Peggy Hank Luanne Buckley BuckStrickland
	do
	htpasswd -b /etc/origin/master/htpasswd $i propanerules
done
# Create Arlen, Texas projects
for i in strickland-propane arlen-high megalomart
	do
	oc new-project $i --description="Arlen Tx Engineering project"
done
# add admin privileges to Hank & Buck
for i in hank buckstrickland
	do
	oadm policy add-role-to-user admin $i -n strickland-propane
done
# create a new group for Arlen users
oc adm groups new arlentx Hank Peggy Luanne Buckley BuckStrickland
# Grant admin privileges to Peggy
oc adm policy add-role-to-user admin peggy -n arlen-high
# Grant edit privileges to Buckley in megalomart project
oc adm policy add-role-to-user edit buckley -n megalomart
# Allow all users in the arlentx project to view megalomart components
oc adm policy add-role-to-group view arlentx -n megalomart
# remove the self-provisioner role from password-authenticated users
oc adm policy remove-cluster-role-from-group self-provisioner system:authenticated system:authenticated:oauth
```
