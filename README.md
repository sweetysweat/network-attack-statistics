# network-attack-statistics

Just a diploma project xD

## Preps

```shell
apt update -y
apt install -y git
cd /opt
git clone https://github.com/sweetysweat/network-attack-statistics.git
```

## Installation

Please before running the installation script execute `export SSH_PUBLIC="<your_public_key>"`

Run `istall.sh` (still in progrs...)

If you want to disable IPv6 run:

```shell
echo -e "net.ipv6.conf.all.disable_ipv6 = 1\nnet.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
```
