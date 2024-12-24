#!/bin/sh

/app/tailscaled --tun=userspace-networking --socks5-server=localhost:1055 &
/app/tailscale up --authkey=${TAILSCALE_AUTHKEY} --hostname=ephermeral-vpn-${PORT} --advertise-exit-node
echo Tailscale started
