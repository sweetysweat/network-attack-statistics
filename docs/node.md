# Installation

Tested only on Ubuntu 22.04

## Preps

```shell
apt update -y && apt upgrade -y
apt install -y mc nano iptables net-tools wget curl docker docker-compose make cmake gcc g++ git nginx
useradd -mG docker -s /bin/bash node
mkdir /home/node/.ssh
chmod 700 /home/node/.ssh
echo "ssh-rsa <your_public_key>" > /home/node/.ssh/authorized_keys
chown -Rf node:node /home/node/.ssh/
mkdir ~/backup
cp /etc/ssh/sshd_config ~/backup/
rm -f /etc/ssh/sshd_config.d/*
sed -i 's/^#Port 22/Port 49152/' /etc/ssh/sshd_config
sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i '/^PermitRootLogin/s/yes/no/' /etc/ssh/sshd_config
systemctl restart sshd
sed -i '/rotate/s/1/13/' /etc/logrotate.d/btmp
sed -i 's/monthly/weekly/' /etc/logrotate.d/btmp
```

## ssh tarpit

```shell
apt install -y libssh-dev libjson-c-dev libpcap-dev libssl-dev
git clone https://github.com/sweetysweat/ssh-honeypot.git
mkdir /var/log/ssh-honeypot
touch /var/log/ssh-honeypot/ssh-honeypot.log.json
chown -Rf nobody:nogroup /var/log/ssh-honeypot
cd ~/ssh-honeypot && make && make install
cat <<'EOF' >> /etc/logrotate.d/ssh-honeypot
/var/log/ssh-honeypot/ssh-honeypot.log
/var/log/ssh-honeypot/ssh-honeypot.log.json
{
    missingok
    weekly
    create 0644 nobody nogroup
    rotate 13
    su nobody nogroup
}
EOF
systemctl enable --now ssh-honeypot
```

## SQL-Injection

Want to use this as a base:
`https://github.com/SunshineCTF/SunshineCTF-2019-Public/tree/master/Web/WrestlerBook`

```shell
docker-compose build --no-cache --build-arg UID=$(id -u)
docker-compose up -d
```

## Suricata

```shell
add-apt-repository -y ppa:oisf/suricata-stable
apt-get update -y
apt install -y suricata
export DEFAULT_INTERFACE=$(ip -o -4 route show to default | awk '{print $5}')
export DEFAULT_IP=$(ip -o -4 route show to default | awk '{print $9}')
sed -i "/^IFACE=/s/eth0/$DEFAULT_INTERFACE/" /etc/default/suricata
sed -i "/- interface:/s/eth0/$DEFAULT_INTERFACE/g" /etc/suricata/suricata.yaml
sed -i "/[^#]HOME_NET:/s@\[\([^]]*\)\]@[$DEFAULT_IP\/32]@" /etc/suricata/suricata.yaml
suricata-update
# как-то надо вставить дохуя строк из suricata.rules (может просто с помощью копирования и не париться)
systemctl restart suricata
```
