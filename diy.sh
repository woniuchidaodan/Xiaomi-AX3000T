#!/bin/bash
# ========== 来自你的 diy-part2.sh（保留所有已验证的功能）==========
# 修改默认 IP
sed -i 's/192.168.1.1/192.168.5.1/g' package/base-files/files/bin/config_generate

# 修改默认主机名
sed -i 's/ImmortalWrt/AX3000T/g' package/base-files/files/bin/config_generate

# -p自动创建多级目录，消除文件不存在报错
mkdir -p package/base-files/files/etc/opkg
cat > package/base-files/files/etc/opkg/distfeeds.conf << 'EOF'
# Kiddin9第三方插件源
src/gz openwrt_kiddin9 https://dl.openwrt.ai/packages-24.10/aarch64_cortex-a53/kiddin9
src/gz openwrt_small_flash https://dl.openwrt.ai/packages-24.10/aarch64_cortex-a53/small_flash
src/gz openwrt_base https://dl.openwrt.ai/packages-24.10/aarch64_cortex-a53/base
src/gz openwrt_luci https://dl.openwrt.ai/packages-24.10/aarch64_cortex-a53/luci
src/gz openwrt_packages https://dl.openwrt.ai/packages-24.10/aarch64_cortex-a53/packages
src/gz openwrt_routing https://dl.openwrt.ai/packages-24.10/aarch64_cortex-a53/routing

# ImmortalWrt官方24.10兜底源（已注释，按需启用）
# src/gz immortalwrt_base https://downloads.immortalwrt.org/releases/24.10.4/packages/aarch64_cortex-a53/base
# src/gz immortalwrt_luci https://downloads.immortalwrt.org/releases/24.10.4/packages/aarch64_cortex-a53/luci
# src/gz immortalwrt_packages https://downloads.immortalwrt.org/releases/24.10.4/packages/aarch64_cortex-a53/packages
# src/gz immortalwrt_routing https://downloads.immortalwrt.org/releases/24.10.4/packages/aarch64_cortex-a53/routing
# src/gz immortalwrt_telephony https://downloads.immortalwrt.org/releases/24.10.4/packages/aarch64_cortex-a53/telephony
EOF

# 设置默认主题为 argon（通过 uci-defaults 脚本实现）
mkdir -p package/base-files/files/etc/uci-defaults
cat > package/base-files/files/etc/uci-defaults/99-set-default-theme <<'EOT'
uci set luci.main.mediaurlbase='/luci-static/argon'
uci commit luci
EOT
# 添加可执行权限，确保uci-defaults框架能运行
chmod +x package/base-files/files/etc/uci-defaults/99-set-default-theme

# ========== 新增：强制固定版本显示为 24.10.4（消除 SNAPSHOT）==========
mkdir -p package/base-files/files/etc
cat > package/base-files/files/etc/openwrt_release << 'EOF'
DISTRIB_ID='ImmortalWrt'
DISTRIB_RELEASE='24.10.4'
DISTRIB_REVISION='r33602-e717d133ed6d'
DISTRIB_TARGET='mediatek/filogic'
DISTRIB_ARCH='aarch64_cortex-a53'
DISTRIB_DESCRIPTION='ImmortalWrt 24.10.4 r33602-e717d133ed6d'
EOF

# ========== 新增：添加 dl.openwrt.ai 第三方源（供刷机后 opkg 使用）==========
mkdir -p package/system/opkg/files
cat >> package/system/opkg/files/customfeeds.conf << 'EOF'
src/gz openwrt_ai_kenzok8 https://dl.openwrt.ai/packages-24.10/aarch64_cortex-a53/kenzok8
src/gz openwrt_ai_small https://dl.openwrt.ai/packages-24.10/aarch64_cortex-a53/small
EOF
