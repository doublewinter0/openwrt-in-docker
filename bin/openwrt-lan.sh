#! /bin/bash

func() {
  sleep 10

  ip link add link openwrt-lan name lan type macvlan mode bridge

  ip link set lan up

  sleep 20

  ip route add 192.168.1.1 dev lan

  # 局域网其他设备，需要添加路由，否则无法访问
  # ip route add 192.168.1.1 dev lan

  sleep 180

  ip route delete default via 192.168.1.1 dev openwrt-wan

  ip route delete default via 192.168.1.1 dev openwrt-lan

  ip route add default via 192.168.1.1 dev lan
}

func
