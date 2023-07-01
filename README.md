# OpenWRT in Docker

本项目介绍如何在 **Docker** 中运行 **OpenWRT**，并将其作为主路由器使用。

## 准备工作

- 一台长期开机的 **Linux** 机器（该设备最好能有两个千兆以上的物理网口，可以用 *USB* 网卡代替），*ARM/x86* 均可，并且已安装 **Docker**。

## 配置

- 我们假设 **Linux** 机器有两个网口，分别为 `openwrt-wan` 和 `openwrt-lan`；
  其中 `openwrt-wan` 连接光猫，作为 *wan* 口使用，进行拨号等操作；
  `openwrt-lan` 连接路由器，作为 *lan* 口使用，提供 *DHCP* 等服务。

- 我们假设光猫的 *IP* 为 `192.168.0.1`，*CIDR* 为 `192.168.0.0/24`；
  `openwrt-lan` 的 *IP* 为 `192.168.1.1`，*CIDR* 为 `192.168.1.0/24`。
  只要两边的 *IP* 不在同一个网段即可。

> 注：如果需要修改网口名称，同步修改 [openwrt-lan.sh](bin/openwrt-lan.sh)，
  [openwrt-lan.service](conf/openwrt-lan.service)，[docker-compose.yml](docker-compose.yml) 中相应的配置。
  文档使用的是 `x86` 架构的设备，如果你使用的是 `ARM`架构的设备，可能需要修改 [docker-compose.yml](docker-compose.yml) 中的镜像。

## 启动

### 1. 打开网卡混杂模式

```shell
sudo ip link set openwrt-wan promisc on
sudo ip link set openwrt-lan promisc on
```

### 2. 启动 OpenWRT

```shell
sudo docker-compose up -d
```

如果启动失败，请根据日志排查错误。

### 3. 修改网络配置

#### 3.1 进入容器：

```shell
sudo docker exec -it openwrt bash # openwrt 为容器名称
```

#### 3.2 修改 OpenWrt 网络配置文件：

```shell
vim /etc/config/network
```

找到下面的配置项：

```
config interface 'lan'
        option ifname 'eth0'
        option proto 'static'
        option ipaddr '192.168.1.1'
        option netmask '255.255.255.0'
        option ip6assign '60'
        option dns '114.114.114.114 223.5.5.5 119.29.29.29 8.8.8.8 1.1.1.1'
```

只需要修改 `option ipaddr` 字段，将其修改为 `openwrt-lan` 的 *IP* 即可，本教程中为 `192.168.1.1`。

#### 3.3 重启网络

```shell
/etc/init.d/network restart
```

#### 3.4 调整光猫，路由器配置

将光猫设置为`桥接`模式，将路由器设置 `AP` 模式

#### 3.5 进入 Web 控制面板

在浏览器中输入 `openwrt-lan` 的 *IP* 进入 *Luci* 控制面板，用户名：`root`，密码：`password`。
在 *Web* 控制面板，你可以对 **OpenWRT** 进行各种配置，包括系统、网络、服务等。

> 建议 `wan`、`lan` 口都使用自定义的 *DNS*。

## 宿主机网络修复

**OpenWrt** 容器运行后，宿主机无法正常访问 *Internet*，局域网内其他设备也无法访问宿主机；
应该和 **Docker** 的 `macvlan` 网络驱动有关，比较复杂，我目前还没有搞懂。
幸运的是，网上有大佬给出了一些解决方案，我整理成了一个简单的 [脚本](bin/openwrt-lan.sh)，并作为 [systemd](https://systemd.io) 服务运行。
在启动该守护进程前，请根据实际情况修改 [openwrt-lan.sh](bin/openwrt-lan.sh) 和 [openwrt-lan.service](conf/openwrt-lan.service)。

> 注意，如果该守护进程成功运行，宿主机应该可以正常访问网络了，但是局域网内其他设备仍然无法直接连接宿主机，需要借助 **OpenWRT** 作为跳板机来连接宿主机。
  也即，假如你想在局域网内连接宿主机，需要先 *ssh* 到 **OpenWRT**，然后在 **OpenWRT** 内再 *ssh* 到宿主机。

## 感谢
- [在Docker 中运行 OpenWrt 旁路网关](https://mlapp.cn/376.html)