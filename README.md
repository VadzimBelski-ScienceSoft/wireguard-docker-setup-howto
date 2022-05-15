# Wireguard VPN with IPV6 external ip setup howto

Wireguard setup using Docker on DigitalOcean

1. Create DigitalOcean Account https://digitalocean.com
2. Download Wireguard Client app on your device https://www.wireguard.com/install/
3. Create a new droplet with the following settings:
   You need to define User Data to run the following commands:
```
#!/bin/bash

# Install needed software
apt-get -y update
apt-get -y install nginx git curl

export PUBLIC_IPV4=$(curl -s http://169.254.169.254/metadata/v1/interfaces/public/0/ipv4/address)
echo Droplet: $HOSTNAME, IP Address: $PUBLIC_IPV4 > /var/www/html/index.html

# get Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# get Wireguard
git clone https://github.com/VadzimBelski-ScienceSoft/wireguard-docker-setup-howto.git
cd wireguard-docker-setup-howto
        
# enable ip forwarding in sysctl

echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
echo "net.ipv6.conf.all.forwarding = 1" >> /etc/sysctl.conf
echo "net.ipv6.conf.default.forwarding = 1" >> /etc/sysctl.conf
echo "net.ipv6.conf.all.proxy_ndp = 1" >> /etc/sysctl.conf

sysctl -p

# run the script
./run.sh

# run IPV6 setup script
./ipv6.sh

```

   3. Navigate to http://server_ip here you will find Wireguard client configs. Please note they will be deleted from public access with in 10 minutes, so hurry up.
   4. Please check you IPv6 connectivity here https://test-ipv6.com/
   5. You can check you public ip here to verify that tunnel works correctly https://whoer.net/ 


# For developers

To debug scripts please use "/var/log/cloud-init-output.log"
    

