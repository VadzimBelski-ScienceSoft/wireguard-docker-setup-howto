#!/bin/bash

export PUBLIC_IPV6=$(curl -s http://169.254.169.254/metadata/v1/interfaces/public/0/ipv6/address)

echo "Got IPV6 $PUBLIC_IPV6"

ip -6 route add ${PUBLIC_IPV6::-1}2 via $(docker inspect -f '{{range .NetworkSettings.Networks}}{{.GlobalIPv6Address}}{{end}}' wireguard)
ip -6 route add ${PUBLIC_IPV6::-1}3 via $(docker inspect -f '{{range .NetworkSettings.Networks}}{{.GlobalIPv6Address}}{{end}}' wireguard)

ip -6 neigh add proxy ${PUBLIC_IPV6::-1}2 dev eth0
ip -6 neigh add proxy ${PUBLIC_IPV6::-1}3 dev eth0

sysctl -w net.ipv6.conf.default.forwarding=1
sysctl -w net.ipv6.conf.all.forwarding=1
sysctl -w net.ipv6.conf.all.proxy_ndp=1

# modify wg.conf to support IPV6
cat wireguard_config/wg0.conf | sed "2s/$/, ${PUBLIC_IPV6}/" \
    | sed "12s/$/, ${PUBLIC_IPV6::-1}2/" \
    | sed "18s/$/, ${PUBLIC_IPV6::-1}3/" \
    | sed '5s/.*/PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE; ip6tables -A FORWARD -i wg0 -j ACCEPT; ip link set dev wg0 mtu 1500/' \
    | sed '6s/.*/PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE; ip6tables -D FORWARD -i wg0 -j ACCEPT/' > wireguard_config/wg0.conf.tmp

cp wireguard_config/wg0.conf.tmp wireguard_config/wg0.conf

# restart wireguard

docker restart wireguard

# modify peer configs

cat wireguard_config/peer_laptop/peer_laptop.conf | sed "2s/$/, ${PUBLIC_IPV6::-1}2/" \
    | sed "5s/$/, 2001:4860:4860::8888/" > wireguard_config/peer_laptop/peer_laptop.conf.ipv6

cat wireguard_config/peer_phone/peer_phone.conf | sed "2s/$/, ${PUBLIC_IPV6::-1}3/" \
    | sed "5s/$/, 2001:4860:4860::8888/" > wireguard_config/peer_phone/peer_phone.conf.ipv6

echo "<br>+++++++ Laptop Config +++++++ <br><pre>" >> /var/www/html/index.html

cat wireguard_config/peer_laptop/peer_laptop.conf.ipv6 >> /var/www/html/index.html

echo "<pre>+++++++ PHONE Config +++++++ <pre>" >> /var/www/html/index.html

cat wireguard_config/peer_phone/peer_phone.conf.ipv6 >> /var/www/html/index.html

sleep 10m

cat /dev/null > /var/www/html/index.html