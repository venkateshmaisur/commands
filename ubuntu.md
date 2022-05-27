**Topics**
* Install Docker on Ubuntu
* Run FreeIPA Server in Docker Ubuntu

###### The following ports are required by FreeIPA:

* 80 tcp (http)
* 443 tcp (https)
* 389 tcp (ldap)
* 636 tcp (ldaps)
* 88 tcp+udp (kerberos)
* 464 tcp+udp (kpasswd)
* 7389 tcp (separate Dogtag instance - used on RHEL 6)

## Install Docker on Ubuntu

```bash
# Uninstall old versions

sudo apt-get remove docker docker-engine docker.io containerd runc

# Set up the repository

sudo apt-get update
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Add Docker’s official GPG key:

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Use the following command to set up the repository:

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null


# Install Docker Engine

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin


# Uninstall Docker Engine
# Uninstall the Docker Engine, CLI, Containerd, and Docker Compose packages:
# sudo apt-get purge docker-ce docker-ce-cli containerd.io docker-compose-plugin
# sudo rm -rf /var/lib/docker
# sudo rm -rf /var/lib/containerd
```

## Run FreeIPA Server in Docker Ubuntu
```bash
# Install docker first.

# Build FreeIPA server image
sudo apt update
sudo apt install git -y


# If Selinux is enabled
# apt install policycoreutils -y
# setsebool -P container_manage_cgroup 1
mkdir -p /var/lib/ipa-data


git clone https://github.com/freeipa/freeipa-container.git
cd freeipa-container
docker build -t freeipa-server -f Dockerfile.centos-7 .
docker images

docker run --name freeipa-server-adsre -ti -h mstr1.odp.u18.adsre \
--sysctl net.ipv6.conf.all.disable_ipv6=0 -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
-v /var/lib/ipa-data:/data:Z -e PASSWORD=admin-password \
freeipa-server ipa-server-install -U -r ADSRE.TEST --ds-password=admin-password \
--admin-password=admin-password --domain=u18.adsre --no-ntp -p 53:53/udp -p 53:53 \
-p 80:80 -p 443:443 -p 389:389 -p 636:636 -p 88:88 -p 464:464 \
-p 88:88/udp -p 464:464/udp -p 123:123/udp


# Note:
# Clean up or change data dir " /var/lib/ipa-data" for new configuration

docker stop freeipa-server-adsre
docker start freeipa-server-adsre

# Cleanup container
# docker stop 8363de7d0653
# docker rm 8363de7d0653

Hostname:       mstr1.odp.u18.adsre
IP address(es): 172.17.0.2
Domain name:    u18.adsre
Realm name:     ADSRE.TEST




docker run -e IPA_SERVER_IP=10.12.0.98 -p 53:53/udp -p 53:53 \
    -p 80:80 -p 443:443 -p 389:389 -p 636:636 -p 88:88 -p 464:464 \
-p 88:88/udp -p 464:464/udp -p 123:123/udp
```
