#!/bin/bash
set -e

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
echo "正在拉取 rkp-ipid 源码..."
if [ -d "package/rkp-ipid" ]; then
    echo "rkp-ipid 目录已存在，跳过克隆"
else
    git clone https://github.com/EOYOHOO/rkp-ipid.git package/rkp-ipid
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
# 2. 基础定制（IP、主机名、主题、源）
# ==========================================

sed -i 's/192.168.1.1/192.168.5.1/g' package/base-files/files/bin/config_generate
sed -i 's/ImmortalWrt/AX3000T/g' package/base-files/files/bin/config_generate

# 设置默认 Argon 主题
mkdir -p package/base-files/files/etc/uci-defaults
cat > package/base-files/files/etc/uci-defaults/99-set-argon-theme << 'EOT'
if [ -d "/www/luci-static/argon" ]; then
    uci set luci.main.mediaurlbase='/luci-static/argon'
    uci commit luci
fi
exit 0
EOT
chmod +x package/base-files/files/etc/uci-defaults/99-set-argon-theme

# 自定义 distfeeds.conf（使用 dl.openwrt.ai）
mkdir -p package/base-files/files/etc/opkg
cat > package/base-files/files/etc/opkg/distfeeds.conf << 'EOF'
src/gz openwrt_kiddin9 https://dl.openwrt.ai/packages-24.10/aarch64_cortex-a53/kiddin9
src/gz openwrt_small_flash https://dl.openwrt.ai/packages-24.10/aarch64_cortex-a53/small_flash
src/gz openwrt_base https://dl.openwrt.ai/packages-24.10/aarch64_cortex-a53/base
src/gz openwrt_luci https://dl.openwrt.ai/packages-24.10/aarch64_cortex-a53/luci
src/gz openwrt_packages https://dl.openwrt.ai/packages-24.10/aarch64_cortex-a53/packages
src/gz openwrt_routing https://dl.openwrt.ai/packages-24.10/aarch64_cortex-a53/routing
EOF

# ==========================================
# 3. 通用 WiFi 配置（自动适配任何设备）
# ==========================================

mkdir -p package/base-files/files/etc/uci-defaults
cat > package/base-files/files/etc/uci-defaults/98-set-wifi-unified << 'EOT'
#!/bin/sh
# 等待无线配置生成（首次启动时 OpenWrt 会自动执行 wifi detect）
sleep 2

if uci show wireless >/dev/null 2>&1; then
    # 获取所有 wifi-iface 的名称并统一设置 SSID 和密码
    for iface in $(uci show wireless | grep '=wifi-iface' | cut -d'=' -f1 | cut -d'.' -f2); do
        uci set wireless.${iface}.ssid='CMCC-6526'
        uci set wireless.${iface}.key='Cy1128724'
        uci set wireless.${iface}.encryption='psk2'
    done
    uci commit wireless
    wifi reload 2>/dev/null || true
fi
exit 0
EOT
chmod +x package/base-files/files/etc/uci-defaults/98-set-wifi-unified

# ==========================================
# 4. 已删除伪造 /etc/openwrt_release（由 Tag 自动生成）
# ==========================================

echo "✅ diy.sh 所有定制任务执行完毕！"
