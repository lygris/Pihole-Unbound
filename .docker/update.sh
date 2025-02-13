export ipv6=$(ip -6 route show | grep 256 |  awk '{print $1}' | grep / | grep -v fe | awk 'ORS=","')
export ipv4=$(ip -4 route show | grep / | grep br | awk '{print $1}'| awk 'ORS=","')
export ipv6PD=$(ip -6 a show dev br2 | grep /64 | grep -v fe | awk '{print $2}' | awk -F: '{ print $1":"$2":"$3":"$4+10"::/64" }')
export routes=$ipv4$ipv6$ipv6PD
echo "routes=$routes" > .env
echo "ipv6PD=$ipv6PD" >> .env
echo '#!/bin/bash
# v1.0
sudo systemctl start docker
sudo ipset create -! docker_lan_routable_net_set hash:net
sudo ipset add -! docker_lan_routable_net_set 172.16.0.0/24
sudo ipset create -! docker_wan_routable_net_set hash:net
sudo ipset add -! docker_wan_routable_net_set 172.16.0.0/24
sudo ipset create -! docker_lan_routable_net_set6 hash:net family inet6
sudo ipset add -! docker_lan_routable_net_set6 '$ipv6PD'
sudo ipset create -! docker_lan_routable_net_set6 hash:net family inet6
sudo ipset add -! docker_wan_routable_net_set6 '$ipv6PD'
sudo ip route add 172.16.0.0/24 dev br-$(sudo docker network inspect pihole |jq -r '.[0].Id[0:12]') table lan_routable
sudo ip route add 172.16.0.0/24 dev br-$(sudo docker network inspect pihole |jq -r '.[0].Id[0:12]') table wan_routable
sudo ip -6 route add '$ipv6PD' dev br-$(sudo docker network inspect pihole |jq -r '.[0].Id[0:12]') table lan_routable
sudo ip -6 route add '$ipv6PD' dev br-$(sudo docker network inspect pihole |jq -r '.[0].Id[0:12]') table wan_routable
sudo systemctl start docker-compose@pihole
sudo rmmod br_netfilter' > /home/pi/.firewalla/config/post_main.d/start_pihole.sh
docker compose --env-file=.env pull
docker compose --env-file=.env down
docker compose --env-file=.env up -d