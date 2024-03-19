#!/bin/bash
IPT="/sbin/iptables"

# Flush und Löschen der Custom-Chains
$IPT -F
$IPT -X

# Policy setzen
$IPT -P INPUT ACCEPT
$IPT -P OUTPUT ACCEPT
$IPT -P FORWARD DROP

# Eigene Chains anlegen
$IPT -N lan_dmz
$IPT -N lan_ext
$IPT -N dmz_ext

# LAN <-> DMZ
$IPT -A FORWARD -i lan -o dmz -j lan_dmz
$IPT -A FORWARD -i dmz -o lan -j lan_dmz

$IPT -A lan_dmz -m conntrack --ctstate RELATED,ESTABLISHED -j LOG --log-prefix "IPTABLES CONN RELATED/ESTABLISHED: "
$IPT -A lan_dmz -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
$IPT -A lan_dmz -p icmp -j ACCEPT
$IPT -A lan_dmz -p tcp --dport domain -j ACCEPT
$IPT -A lan_dmz -p udp --dport domain -j ACCEPT
$IPT -A lan_dmz -j REJECT

# LAN <-> INTERNET
$IPT -A FORWARD -i lan -o outside -j lan_ext
$IPT -A FORWARD -i outside -o lan -j lan_ext

$IPT -A lan_ext -j ACCEPT

# DMZ <-> INTERNET
$IPT -A FORWARD -i dmz -o outside -j dmz_ext
$IPT -A FORWARD -i outside -o dmz -j dmz_ext

$IPT -A dmz_ext -m conntrack --ctstate RELATED,ESTABLISHED -j LOG --log-prefix "IPTABLES CONN RELATED/ESTABLISHED: "
$IPT -A dmz_ext -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
$IPT -A dmz_ext -p udp --dport ntp -j ACCEPT
$IPT -A dmz_ext -p tcp --dport ssh -j ACCEPT
$IPT -A dmz_ext -p tcp --dport domain -j ACCEPT
$IPT -A dmz_ext -p udp --dport domain -j ACCEPT
$IPT -A dmz_ext -p icmp -j ACCEPT
$IPT -A dmz_ext -j REJECT

# MASQUERADING
$IPT -t nat -A POSTROUTING -o outside -j MASQUERADE
