#!/bin/sh

curl -o /app/config/Seanime/seanime.db -L $ACCS
#/app/tailscaled --tun=userspace-networking --socks5-server=localhost:1055 &
#/app/tailscale up --authkey=${TAILSCALE_AUTHKEY} --hostname=ephermeral-vpn-${PORT} --advertise-exit-node
#echo Tailscale started
wget -O /app/wireguard.sh https://get.vpnsetup.net/wg
chmod +x /app/wireguard.sh
bash /app/wireguard.sh --auto
