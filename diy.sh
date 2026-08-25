#!/bin/bash
set -e  # 遇到错误立即退出，避免掩耳盗铃

# ==========================================
# 1. 拉取外部源码（UA3F + quickstart 全套）
# ==========================================

echo "----------------------------------------"
echo "正在拉取 UA3F 源码..."
if [ -d "package/UA3F" ]; then
    echo "UA3F 目录已存在，跳过克隆"
else
    git clone https://github.com/SunBK201/UA3F.git package/UA3F
fi

echo "----------------------------------------"
echo "正在从 kenzok8 源拉取 quickstart 及其全部依赖..."
if [ -d "package/quickstart" ]; then
    echo "quickstart 目录已存在，跳过拉取"
else
    git clone --depth 1 --filter=blob:none --sparse https://github.com/kenzok8/openwrt-packages.git temp_kenzok8
    cd temp_kenzok8
    git sparse-checkout set quickstart luci-app-quickstart luci-app-store luci-lib-taskd luci-lib-xterm taskd
    cd ..
    mv temp_kenzok8/quickstart package/
    mv temp_kenzok8/luci-app-quickstart package/
    mv temp_kenzok8/luci-app-store package/
    mv temp_kenzok8/luci-lib-taskd package/
    mv temp_kenzok8/luci-lib-xterm package/
    mv temp_kenzok8/taskd package/
    rm -rf temp_kenzok8
    echo "✅ quickstart 全部依赖链已拉取"
fi

# ==========================================
# 2. 原 diy.sh 的定制内容（完全保留）
# ==========================================

sed -i 's/192.168.1.1/192.168.5.1/g' package/base-files/files/bin/config_generate
sed -i 's/ImmortalWrt/AX3000T/g' package/base-files/files/bin/config_generate

mkdir -p package/base-files/files/etc/uci-defaults
cat > package/base-files/files/etc/uci-defaults/99-set-argon-theme << 'EOT'
if [ -d "/www/luci-static/argon" ]; then
    uci set luci.main.mediaurlbase='/luci-static/argon'
    uci commit luci
fi
exit 0
EOT
chmod +x package/base-files/files/etc/uci-defaults/99-set-argon-theme

# ========== distfeeds.conf（默认：dl.openwrt.ai 第三方源）==========
mkdir -p package/base-files/files/etc/opkg
cat > package/base-files/files/etc/opkg/distfeeds.conf << 'EOF'
src/gz openwrt_kiddin9 https://dl.openwrt.ai/packages-24.10/aarch64_cortex-a53/kiddin9
src/gz openwrt_small_flash https://dl.openwrt.ai/packages-24.10/aarch64_cortex-a53/small_flash
src/gz openwrt_base https://dl.openwrt.ai/packages-24.10/aarch64_cortex-a53/base
src/gz openwrt_luci https://dl.openwrt.ai/packages-24.10/aarch64_cortex-a53/luci
src/gz openwrt_packages https://dl.openwrt.ai/packages-24.10/aarch64_cortex-a53/packages
src/gz openwrt_routing https://dl.openwrt.ai/packages-24.10/aarch64_cortex-a53/routing
EOF

# ========== 吉林大学镜像站（已注释，按需启用）==========
# mkdir -p package/base-files/files/etc/opkg
# cat > package/base-files/files/etc/opkg/distfeeds.conf << 'EOF'
# src/gz openwrt_base http://mirrors.jlu.edu.cn/immortalwrt/releases/24.10.6/packages/aarch64_cortex-a53/base
# src/gz openwrt_luci http://mirrors.jlu.edu.cn/immortalwrt/releases/24.10.6/packages/aarch64_cortex-a53/luci
# src/gz openwrt_packages http://mirrors.jlu.edu.cn/immortalwrt/releases/24.10.6/packages/aarch64_cortex-a53/packages
# src/gz openwrt_routing http://mirrors.jlu.edu.cn/immortalwrt/releases/24.10.6/packages/aarch64_cortex-a53/routing
# src/gz openwrt_telephony http://mirrors.jlu.edu.cn/immortalwrt/releases/24.10.6/packages/aarch64_cortex-a53/telephony
# EOF

# ========== 设置默认 WiFi 名称和密码（双频合一）==========
mkdir -p package/base-files/files/etc/config
cat > package/base-files/files/etc/config/wireless << 'EOF'
config wifi-device 'radio0'
    option type 'mac80211'
    option path 'platform/soc/18000000.wifi'
    option channel '1'
    option band '2g'
    option htmode 'HE20'
    option disabled '0'

config wifi-iface 'default_radio0'
    option device 'radio0'
    option network 'lan'
    option mode 'ap'
    option ssid 'CMCC-6526'
    option encryption 'psk2'
    option key 'Cy1128724'

config wifi-device 'radio1'
    option type 'mac80211'
    option path 'platform/soc/18000000.wifi+1'
    option channel '36'
    option band '5g'
    option htmode 'HE80'
    option disabled '0'

config wifi-iface 'default_radio1'
    option device 'radio1'
    option network 'lan'
    option mode 'ap'
    option ssid 'CMCC-6526'
    option encryption 'psk2'
    option key 'Cy1128724'
EOF

# ========== 已删除伪造 /etc/openwrt_release ==========

echo "✅ diy.sh 所有定制任务执行完毕！"
