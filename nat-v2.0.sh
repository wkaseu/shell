#!/bin/sh

## local ip for service
nat_host=192.168.1.130

## dst host
connector_host=172.16.192.10
transmit_host=172.16.192.10
file_host=172.16.192.110
emqttd_host=172.16.192.110

## dst port

connector_port=9907
connector_port1=19907
transmit_port=9908
transmit_port1=19908

file_port=9900

emqttd_port=1883


## enable ip forward
echo 1 > /proc/sys/net/ipv4/ip_forward


## file nat
iptables -t nat -A PREROUTING -d ${nat_host} -p tcp --dport ${file_port} -j DNAT --to ${file_host}:${file_port}
iptables -t nat -A POSTROUTING -p tcp -d ${file_host} --dport ${file_port} -j SNAT --to-source ${nat_host}
iptables -I FORWARD -d ${file_host} -p tcp --dport ${file_port} -j ACCEPT

## emqttd nat
iptables -t nat -A PREROUTING -d ${nat_host} -p tcp --dport ${emqttd_port} -j DNAT --to ${emqttd_host}:${emqttd_port}
iptables -t nat -A POSTROUTING -p tcp -d ${emqttd_host} --dport ${emqttd_port} -j SNAT --to-source ${nat_host}
iptables -I FORWARD -d ${emqttd_host} -p tcp --dport ${emqttd_port} -j ACCEPT

## connector nat
iptables -t nat -A PREROUTING -d ${nat_host} -p tcp --dport ${connector_port1} -j DNAT --to ${connector_host}:${connector_port}
iptables -t nat -A POSTROUTING -p tcp -d ${connector_host} --dport ${connector_port} -j SNAT --to-source ${nat_host}
iptables -I FORWARD -d ${connector_host} -p tcp --dport ${connector_port} -j ACCEPT

## transmit nat
#tcp
iptables -t nat -A PREROUTING -d ${nat_host} -p tcp --dport ${transmit_port1} -j DNAT --to ${transmit_host}:${transmit_port}
iptables -t nat -A POSTROUTING -p tcp -d ${transmit_host} --dport ${transmit_port} -j SNAT --to-source ${nat_host}
iptables -I FORWARD -d ${transmit_host} -p tcp --dport ${transmit_port} -j ACCEPT


#udp
iptables -t nat -A PREROUTING -d ${nat_host} -p udp --dport ${transmit_port1} -j DNAT --to ${transmit_host}:${transmit_port}
iptables -t nat -A POSTROUTING -p udp -d ${transmit_host} --dport ${transmit_port} -j SNAT --to-source ${nat_host}:${transmit_port1}
iptables -I FORWARD -d ${transmit_host} -p udp --dport ${transmit_port} -j ACCEPT

iptables -A FORWARD -m state --state NEW,ESTABLISHED,RELATED -p tcp --dport ${connector_port} -j ACCEPT
iptables -A FORWARD -m state --state NEW,ESTABLISHED,RELATED -p tcp --dport ${transmit_port} -j ACCEPT
iptables -A FORWARD -m state --state NEW,ESTABLISHED,RELATED -p udp --dport ${transmit_port} -j ACCEPT
iptables -A FORWARD -m state --state NEW,ESTABLISHED,RELATED -p tcp --dport ${file_port} -j ACCEPT
iptables -A FORWARD -m state --state NEW,ESTABLISHED,RELATED -p tcp --dport ${emqttd_port} -j ACCEPT

iptables-save > /etc/sysconfig/iptables
