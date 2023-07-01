#! /bin/bash

func() {
  sleep 10

  ip link add lan link openwrt-lan type macvlan mode bridge

  ip link set lan up

  sleep 20

  ip route add 192.168.1.1 dev lan

  sleep 180

  ip route delete default via 192.168.1.1 dev openwrt-wan

  ip route delete default via 192.168.1.1 dev openwrt-lan

  ip route add default via 192.168.1.1 dev lan
}

func
