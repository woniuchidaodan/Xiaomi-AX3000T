#!/bin/bash
# 修改默认 IP 和主机名
sed -i 's/192.168.1.1/192.168.5.1/g' package/base-files/files/bin/config_generate
sed -i 's/ImmortalWrt/AX3000T/g' package/base-files/files/bin/config_generate