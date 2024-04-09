#!/bin/bash

if [ -z ${SSH_PUBLIC+x} ]
then
    # read SSH_PUBLIC (maybe change to this...)
    echo "SSH_PUBLIC is unset. Please export SSH_PUBLIC=\"<your_public_key>\""
    exit 1
else 
    echo "SSH_PUBLIC is set. It will be unset after installation."
fi

export DEBIAN_FRONTEND=noninteractive

# Update system and install basic packagesinstall.sh
apt update -y && apt dist-upgrade -y
apt install -y mc nano iptables net-tools wget curl docker \
               docker-compose make cmake gcc g++ git nginx \
               libssh-dev libjson-c-dev libpcap-dev libssl-dev

# Create and configure defauld user
useradd -mG docker -s /bin/bash node
mkdir /home/node/.ssh
chmod 700 /home/node/.ssh
echo "ssh-rsa $SSH_PUBLIC" > /home/node/.ssh/authorized_keys
chown -Rf node:node /home/node/.ssh/

# Configure SSH
mkdir ~/backup
cp /etc/ssh/sshd_config ~/backup/
rm -f /etc/ssh/sshd_config.d/*
sed -i 's/^#Port 22/Port 49152/' /etc/ssh/sshd_config
sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i '/^PermitRootLogin/s/yes/no/' /etc/ssh/sshd_config
systemctl restart sshd

# Configure logrotation for ssh
sed -i '/rotate/s/1/13/' /etc/logrotate.d/btmp
sed -i 's/monthly/weekly/' /etc/logrotate.d/btmp

# Configure SSH honeypot
git clone https://github.com/sweetysweat/ssh-honeypot.git /opt/ssh-honeypot
cd /opt/ssh-honeypot
make
make install
systemctl enable --now ssh-honeypot
mkdir /var/log/ssh-honeypot
touch /var/log/ssh-honeypot/ssh-honeypot.log.json
chown -Rf nobody:nogroup /var/log/ssh-honeypot
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

# Configure honeypot for SQL-Injection
cd /opt/network-attack-statistics/honeypots/sql-injection
chown -Rf node:node honeypots
rm -f /etc/nginx/sites-enabled/*.conf  # 
cp nginx.conf /etc/nginx/sites-enabled/sql-injection.conf
su node -c "docker-compose build --no-cache --build-arg HOST_UID=$(id node -u) && docker-compose up -d"


# Configure suricata
apt install -y software-properties-common
add-apt-repository -y ppa:oisf/suricata-stable
apt update -y
apt install -y suricata
DEFAULT_INTERFACE=$(ip -4 route show default | grep -oP '(?<=dev )(\S+)')
DEFAULT_IP=$(ip addr show dev $DEFAULT_INTERFACE | grep -oP '(?<=inet\s)\d+\.\d+\.\d+\.\d+')
sed -i "/^IFACE=/s/eth0/$DEFAULT_INTERFACE/" /etc/default/suricata
sed -i "/- interface:/s/eth0/$DEFAULT_INTERFACE/g" /etc/suricata/suricata.yaml
sed -i "/[^#]HOME_NET:/s@\[\([^]]*\)\]@[$DEFAULT_IP\/32]@" /etc/suricata/suricata.yaml
suricata-update
sed -i '/rule-files:/a \ \ - /etc/suricata/rules/local.rules' /etc/suricata/suricata.yaml
cd ../../suricata-rules && cp local.rules
systemctl enable suricata && systemctl restart suricata

# TO DO: add logrotation with compression cause to many scans т_т
