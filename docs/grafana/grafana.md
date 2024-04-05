# Grafana

## Installation

```shell
apt -y update && apt -y upgrade
apt install -y sudo curl wget net-tools nano mc openssh-server wireguard

apt install -y apt-transport-https software-properties-common wget
sudo mkdir -p /etc/apt/keyrings/
wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list

apt install grafana loki promtail
# дописать... т_т
```
