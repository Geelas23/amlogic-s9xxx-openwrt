 #!/bin/bash
    # ====== HAPUS PAKET BIANG KEROK ======
    sed -i '/bmx7/d' .config
    sed -i '/babeld/d' .config
    sed -i '/dcwapd/d' .config
    sed -i '/prometheus-node-exporter-lua/d' .config
    sed -i '/kmod-dummy/d' .config

# 1. Musnahin paket docker
sed -i 's/CONFIG_PACKAGE_dockerd=.*/CONFIG_PACKAGE_dockerd=n/g' .config
sed -i 's/CONFIG_PACKAGE_docker=.*/CONFIG_PACKAGE_docker=n/g' .config
sed -i 's/CONFIG_PACKAGE_luci-app-dockerman=.*/CONFIG_PACKAGE_luci-app-dockerman=n/g' .config
sed -i '/docker/d' package/base-files/files/etc/config/fstab
sed -i '/CONFIG_PACKAGE_luci-i18n-dockerman/d' .config

# --- Nonaktifkan IPv6 di runtime (sysctl) ---
mkdir -p files/etc/sysctl.d
cat > files/etc/sysctl.d/99-ipv6off.conf << 'EOF'
net.ipv6.conf.all.disable_ipv6=1
net.ipv6.conf.default.disable_ipv6=1
net.ipv6.conf.lo.disable_ipv6=0
EOF

# --- Matikan DHCPv6/RA di semua interface ---
mkdir -p files/etc/hotplug.d/iface
cat > files/etc/hotplug.d/iface/99-ipv6-off << 'EOF'
#!/bin/sh
[ "$ACTION" = "ifup" ] && \
    uci -q delete dhcp.lan.ra && \
    uci -q delete dhcp.lan.dhcpv6 && \
    uci -q delete dhcp.wan.ra && \
    uci -q delete dhcp.wan.dhcpv6
EOF
chmod +x files/etc/hotplug.d/iface/99-ipv6-off


    # ====== SETTING CCACHE BIAR CEPET ======
    sed -i '/CONFIG_DEVEL/d' .config
    sed -i '/CONFIG_CCACHE/d' .config
    echo "CONFIG_DEVEL=y" >>.config
    echo "CONFIG_CCACHE=y" >>.config
    echo "CONFIG_CCACHE_DIR=\"\$(TOPDIR)/.ccache\"" >>.config

    # ====== INFO REPO ======
    sed -i "s|DISTRIB_REVISION='.*'|DISTRIB_REVISION='R$(date +%Y.%m.%d)'|" package/base-files/files/etc/openwrt_release
    echo "DISTRIB_SOURCEREPO='github.com/openwrt/openwrt'" >>package/base-files/files/etc/openwrt_release
    echo "DISTRIB_SOURCECODE='openwrt'" >>package/base-files/files/etc/openwrt_release
    echo "DISTRIB_SOURCEBRANCH='main'" >>package/base-files/files/etc/openwrt_release
