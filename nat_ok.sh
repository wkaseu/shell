


echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -F
iptables -F -t nat



aircraft_ip=`getprop | grep "wlan0.gateway" | cut -f 2 -d : | cut -f 1 -d ] | cut -f 2 -d [`
switch_ip_to_air=`getprop | grep "wlan0.ipaddress" | cut -f 2 -d : | cut -f 1 -d ] | cut -f 2 -d [`
switch_ip_to_p=`getprop | grep "usb0.ipaddress" | cut -f 2 -d : | cut -f 1 -d ] | cut -f 2 -d [`
phone_ip=`getprop | grep "usb0.gateway" | cut -f 2 -d : | cut -f 1 -d ] | cut -f 2 -d [`
iphone_ip=`getprop | grep "eth0.gateway" | cut -f 2 -d : | cut -f 1 -d ] | cut -f 2 -d [`



have_iphone=`netcfg | grep eth0`
have_android=`netcfg | grep usb0`
have_wlan0=`netcfg | grep wlan0`





if [ -z "$have_wlan0" ];then
    echo "wifi not connected"
	exit 1
fi

if [[ -z "$have_iphone" ]] && [[ -z "$have_android" ]];then
    echo "have no phone connected"
	exit 1
fi

if [[ ! -z "$have_iphone" ]] && [[ ! -z "$have_android" ]];then
    echo "have two phone connected,must be one phone"
	exit 1
fi
    
if [[ ! -z "$have_iphone" ]] && [[ -z "$have_android" ]];then
    phone_ip=iphone_ip
fi


if [ -z "$phone_ip" ];then
    echo "command error,can not find usb client ip"
	exit 1;
fi

## iptables -A FORWARD -i wlan0 -o usb0 -m state --state RELATED,ESTABLISHED -j ACCEPT
## iptables -A FORWARD -i usb0 -o wlan0 -j ACCEPT

iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT

## phone:42.129     42.138-42.2        A20:42.1
iptables -t nat -A PREROUTING -d $switch_ip_to_air -j DNAT --to $phone_ip
iptables -A FORWARD -d$phone_ip  -j ACCEPT
## iptables -t nat -A POSTROUTING -s 192.168.42.1 -j SNAT --to 192.168.42.138
iptables -t nat -A POSTROUTING -s $aircraft_ip -j SNAT --to $switch_ip_to_p

## iptables -t nat -A PREROUTING -d 192.168.42.138 -j DNAT --to 192.168.42.1
iptables -t nat -A PREROUTING -d $switch_ip_to_p -j DNAT --to $aircraft_ip
iptables -A FORWARD -d $aircraft_ip  -j ACCEPT
iptables -t nat -A POSTROUTING -s $phone_ip -j SNAT --to $switch_ip_to_air




echo $phone_ip
exit 0