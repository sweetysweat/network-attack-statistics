# network-attack-statistics

Just a diploma project xD

Before running the installation script check that the default conf file in nginx is not being used cause its going to be deleted (or change `# Configure honeypot for SQL-Injection` section in `install.sh`).

## Preps

```shell
apt update -y
apt install -y git
git clone https://github.com/sweetysweat/network-attack-statistics.git /opt/network-attack-statistics
cd /opt/network-attack-statistics
chmod +x install.sh
```

## Installation

Please before running the installation script execute `export SSH_PUBLIC="<your_public_key>"`

Run `istall.sh` (still in progrs...)

If you want to disable IPv6 run:

```shell
echo -e "net.ipv6.conf.all.disable_ipv6 = 1\nnet.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
sysctl -p
```
