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
               libssh-dev libjson-c-dev libpcap-dev libssl-dev \
               logrotate nano

# Create and configure defauld user
useradd -mG docker -s /bin/bash node
mkdir /home/node/.ssh
chmod 700 /home/node/.ssh
echo "$SSH_PUBLIC" > /home/node/.ssh/authorized_keys
chown -Rf node:node /home/node/.ssh/

# Configure SSH
mkdir ~/backup
cp /etc/ssh/sshd_config ~/backup/
rm -f /etc/ssh/sshd_config.d/*
sed -i 's/^#Port 22/Port 49152/' /etc/ssh/sshd_config
sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i '/^PermitRootLogin/s/yes/no/' /etc/ssh/sshd_config
systemctl restart sshd

chown -Rf node:node /opt/network-attack-statistics

# Configure logrotation for ssh
sed -i '/rotate/s/1/13/' /etc/logrotate.d/btmp
sed -i 's/monthly/weekly/' /etc/logrotate.d/btmp

# Configure SSH honeypot (cowrie)
# Maybe will return to https://github.com/sweetysweat/ssh-honeypot
cd /opt/network-attack-statistics/honeypots/cowrie
mkdir /var/log/cowrie
docker-compose up -d

cd /opt/network-attack-statistics/honeypots/sql-injection
rm -f /etc/nginx/sites-enabled/default  # pls reconfigure if you need it
cp nginx.conf /etc/nginx/sites-enabled/sql-injection.conf
nginx -s reload
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
sed -i 's/filename: fast.log/filename: fast-%Y-%m-%d-%H:%M.log/' /etc/suricata/suricata.yaml
sed -i '/filename: fast-%Y-%m-%d-%H:%M.log/ a\      rotate-interval: day' /etc/suricata/suricata.yaml
sed -i 's/filename: eve.json/filename: eve-%Y-%m-%d-%H:%M.json/' /etc/suricata/suricata.yaml
sed -i '/filename: eve-%Y-%m-%d-%H:%M.json/ a\      rotate-interval: day' /etc/suricata/suricata.yaml
cd ../../suricata-rules && cp local.rules
cat <<'EOF' >> /etc/logrotate.d/suricata
/var/log/suricata/*.log /var/log/suricata/*.json
{
    daily
    rotate 120
    missingok
    compress
    notifempty
    create
    sharedscripts
    postrotate
            /bin/kill -HUP `cat /var/run/suricata.pid 2>/dev/null` 2>/dev/null || true
    endscript
}
EOF
systemctl enable suricata && systemctl restart suricata
