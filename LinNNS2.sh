#!/bin/bash

read -p LAN_MAC DMZ_MAC OUTSIDE_MAC

sudo cat <<EOT > /etc/netplan/00-installer-config.yaml
network:
  ethernets:
    lan:
      addresses:
        - 10.0.0.254/24
      match:
        macaddress: $LAN_MAC
      set-name: lan
    dmz:
      addresses:
        - 192.168.30.254/24
      match:
        macaddress: $DMZ_MAC
      set-name: dmz
    outside:
      dhcp4: true
      match:
        macaddress: $OUTSIDE_MAC
      set-name: outside
  version: 2
EOT

sudo netplan apply
sudo sysctl -w net.ipv4.ip_forward=1
sudo sysctl -w net.ipv6.conf.all.forwarding=1
sudo sysctl -p
sudo curl https://vikt.or.at/s/ls2/ipt.sh | sudo bash

echo "Konfiguration abgeschlossen."
