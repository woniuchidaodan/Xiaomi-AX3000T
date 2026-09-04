#!/bin/bash
# 设置 Argon 主题
mkdir -p package/base-files/files/etc/uci-defaults
cat > package/base-files/files/etc/uci-defaults/99-set-argon-theme << 'EOT'
if [ -d "/www/luci-static/argon" ]; then
    uci set luci.main.mediaurlbase='/luci-static/argon'
    uci commit luci
fi
exit 0
EOT
chmod +x package/base-files/files/etc/uci-defaults/99-set-argon-theme

# 设置默认 WiFi（双频合一）
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
    option key '123456789'

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
    option key '123456789'
EOF
