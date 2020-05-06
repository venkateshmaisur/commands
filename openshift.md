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

4. Verify that the KVM kernel module is loaded:
```
$ lsmod | grep kvm
```

5. If you're running CentOS/RHEL 7 minimal, `virt-manager` may not start unless the `x-window-system` package is installed:
```
yum install "@X Window System" xorg-x11-xauth xorg-x11-fonts-* xorg-x11-utils -y
```

6. If not running as root (which you shouldn't be), add your $USER to the libvirt and KVM groups:
```bash
useradd -m -s /bin/bash -c "Administrator" pbhagade
usermod -aG wheel pbhagade
usermod -aG libvirt $USER
su - pbhagade
```

### The Network

All KVM guests to be used as OpenShift nodes will need to be connected to the same network, which can be achieved by creating a Bridge in KVM.

1. Start up `virt-manager`

  * Go into `Menu --> Connection details --> Virtual networks`
..  * Click `+` to add a network
..* Give a name `shadowman`
  * Set IP range
  * Enable DHCPv4
  * Click Next
  * Skip IPv6 details
  * Select Forward to physical network
  * For destination, select your network (eth0, eno1, wlps0, etc)
  * Set Mode to `NAT`
  * Optional: Set domain name (or leave as `shadowman`)



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
