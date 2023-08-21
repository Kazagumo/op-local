#!/bin/bash


git clone https://github.com/openwrt/openwrt.git --depth=1 --branch=main
cd ./openwrt
# 修改插件名字
#sed -i 's/"终端"/"TTYD"/g' `egrep "终端" -rl ./`
sed -i 's/"网络存储"/"NAS"/g' `egrep "网络存储" -rl ./`
sed -i 's/"实时流量监测"/"流量"/g' `egrep "实时流量监测" -rl ./`
sed -i 's/"KMS 服务器"/"KMS激活"/g' `egrep "KMS 服务器" -rl ./`
sed -i 's/"USB 打印服务器"/"打印服务"/g' `egrep "USB 打印服务器" -rl ./`
sed -i 's/"Web 管理"/"Web管理"/g' `egrep "Web 管理" -rl ./`
#sed -i 's/"管理权"/"改密码"/g' `egrep "管理权" -rl ./`
#sed -i 's/"带宽监控"/"监控"/g' `egrep "带宽监控" -rl ./`
#set zsh as default shell
sed -i 's/\/bin\/ash/\/usr\/bin\/zsh/g' package/base-files/files/etc/passwd

backup=$PWD
#备份工作目录以免找不到下一步脚本
#现在可随意修改工作目录位置

mkdir -p turboacc_tmp ./package/turboacc
cd turboacc_tmp 
git clone https://github.com/chenmozhijin/turboacc -b package
cd ../package/turboacc
git clone https://github.com/fullcone-nat-nftables/nft-fullcone
git clone https://github.com/chenmozhijin/turboacc
mv ./turboacc/luci-app-turboacc ./luci-app-turboacc
rm -rf ./turboacc
cd ../..
cp -f turboacc_tmp/turboacc/hack-6.1/952-add-net-conntrack-events-support-multiple-registrant.patch ./target/linux/generic/hack-6.1/952-add-net-conntrack-events-support-multiple-registrant.patch
cp -f turboacc_tmp/turboacc/hack-6.1/953-net-patch-linux-kernel-to-support-shortcut-fe.patch ./target/linux/generic/hack-6.1/953-net-patch-linux-kernel-to-support-shortcut-fe.patch
cp -f turboacc_tmp/turboacc/pending-6.1/613-netfilter_optional_tcp_window_check.patch ./target/linux/generic/pending-6.1/613-netfilter_optional_tcp_window_check.patch
rm -rf ./package/libs/libnftnl ./package/network/config/firewall4 ./package/network/utils/nftables
mkdir -p ./package/network/config/firewall4 ./package/libs/libnftnl ./package/network/utils/nftables
cp -r ./turboacc_tmp/turboacc/shortcut-fe ./package/turboacc
cp -RT ./turboacc_tmp/turboacc/firewall4-$(grep -o 'FIREWALL4_VERSION=.*' ./turboacc_tmp/turboacc/version | cut -d '=' -f 2)/firewall4 ./package/network/config/firewall4
cp -RT ./turboacc_tmp/turboacc/libnftnl-$(grep -o 'LIBNFTNL_VERSION=.*' ./turboacc_tmp/turboacc/version | cut -d '=' -f 2)/libnftnl ./package/libs/libnftnl
cp -RT ./turboacc_tmp/turboacc/nftables-$(grep -o 'NFTABLES_VERSION=.*' ./turboacc_tmp/turboacc/version | cut -d '=' -f 2)/nftables ./package/network/utils/nftables
rm -rf turboacc_tmp
echo "# CONFIG_NF_CONNTRACK_CHAIN_EVENTS is not set" >> target/linux/generic/config-6.1
echo "# CONFIG_SHORTCUT_FE is not set" >> target/linux/generic/config-6.1

git clone https://github.com/shidahuilang/openwrt-package.git --depth=1 --branch=Official ./package/addons

rm -rf ./package/addons/luci-theme-argon
rm -rf ./package/addons/luci-app-argon-config
rm -rf ./package/addons/luci-app-oled

git clone https://github.com/jerrykuku/luci-theme-argon.git ./package/argon/luci-theme-argon --depth=1 

git clone https://github.com/vernesong/OpenClash ./package/luci-app-openclash --depth=1

git clone https://github.com/sirpdboy/luci-app-partexp ./package/luci-app-partexp --depth=1

git clone https://github.com/jerrykuku/luci-app-argon-config.git ./package/argon/luci-app-argon-config --depth=1 

git clone https://github.com/Kazagumo/luci-app-3ginfo-lite-zhcn ./package/luci-app-3ginfo-lite-zhcn --depth=1 

git clone https://github.com/4IceG/luci-app-sms-tool ./package/luci-app-sms-tool --depth=1 

git clone https://github.com/Kazagumo/luci-app-oled ./package/luci-app-oled-mod --depth=1 

git clone https://github.com/gSpotx2f/luci-app-temp-status ./package/luci-app-temp-status --depth=1

git clone https://github.com/Kazagumo/luci-app-cpufreq ./package/luci-app-cpufreq --depth=1

git clone https://github.com/Kazagumo/OPi-Zero2-OPPatcher --depth=1 --branch=6.1.40+6.1.24-1PORT ./OPi-Zero2-OPPatcher
bash ./OPi-Zero2-OPPatcher/replace.sh

rm ./OPi-Zero2-OPPatcher -rf

mkdir -p files/root
pushd files/root

## Install oh-my-zsh
# Clone oh-my-zsh repository
git clone https://github.com/robbyrussell/oh-my-zsh ./.oh-my-zsh

# Install extra plugins
git clone https://github.com/zsh-users/zsh-autosuggestions ./.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ./.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-completions ./.oh-my-zsh/custom/plugins/zsh-completions

# Get .zshrc dotfile
wget https://raw.githubusercontent.com/SuLingGG/OpenWrt-Rpi/main/data/zsh/.zshrc

popd

pushd files

cat << "EOF" > /etc/uci-defaults/99-custom
uci set wireless.@wifi-device[0].disabled='0'
uci commit
wifi up
EOF

mkdir -p files/etc/openclash/core

CLASH_DEV_URL="https://raw.githubusercontent.com/vernesong/OpenClash/core/master/dev/clash-linux-arm64.tar.gz"
#CLASH_TUN_URL="https://raw.githubusercontent.com/vernesong/OpenClash/core/master/premium/clash-linux-arm64-2023.03.04.gz"
CLASH_META_URL="https://raw.githubusercontent.com/vernesong/OpenClash/core/master/meta/clash-linux-arm64.tar.gz"
GEOIP_URL="https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat"
GEOSITE_URL="https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat"

wget -qO- $CLASH_DEV_URL | tar xOvz > files/etc/openclash/core/clash
#wget -qO- $CLASH_TUN_URL | gunzip -c > files/etc/openclash/core/clash_tun
wget -qO- $CLASH_META_URL | tar xOvz > files/etc/openclash/core/clash_meta
wget -qO- $GEOIP_URL > files/etc/openclash/GeoIP.dat
wget -qO- $GEOSITE_URL > files/etc/openclash/GeoSite.dat

chmod +x files/etc/openclash/core/clash*

#所有操作执行完毕 
cd $backup

./scripts/feeds update -a
./scripts/feeds install -a
