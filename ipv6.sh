#!/bin/sh

export PUBLIC_IPV6=$(curl -s http://169.254.169.254/metadata/v1/interfaces/public/0/ipv6/address)

LAPTOP_IPV6=$PUBLIC_IPV6
PHONE_IPV6=$PUBLIC_IPV6

ip -6 route add $LAPTOP_IPV6 via $(docker inspect -f '{{range .NetworkSettings.Networks}}{{.GlobalIPv6Address}}{{end}}' wireguard)
ip -6 route add $PHONE_IPV6 via $(docker inspect -f '{{range .NetworkSettings.Networks}}{{.GlobalIPv6Address}}{{end}}' wireguard)

ip -6 neigh add proxy $LAPTOP_IPV6 dev eth0
ip -6 neigh add proxy $PHONE_IPV6 dev eth0

sysctl -w net.ipv6.conf.default.forwarding=1
sysctl -w net.ipv6.conf.all.forwarding=1
sysctl -w net.ipv6.conf.all.proxy_ndp=1
