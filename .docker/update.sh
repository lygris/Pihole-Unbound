ipv6=$(ip -6 route show | grep 256 |  awk '{print $1}' | grep / | grep -v fe | awk 'ORS=","')
ipv4=$(ip -4 route show | grep / | grep br | awk '{print $1}'| awk 'ORS=","')
ipv6PD=$(ip -6 a show dev br2 | grep /64 | grep -v fe | awk '{print $2}' | awk -F: '{ print $1":"$2":"$3":"$4+10"::/64" }')
routes=$ipv4$ipv6$ipv6PD
echo "routes=$routes" > .env
echo "ipv6PD=$ipv6PD" >> .env
docker compose --env-file=.env pull
docker compose --env-file=.env down
docker compose --env-file=.env up -d