#!/bin/bash

git clone https://github.com/openwrt/openwrt.git --depth=1 --branch=main
# 修改插件名字
sed -i 's/"终端"/"TTYD"/g' `egrep "终端" -rl ./`
sed -i 's/"网络存储"/"NAS"/g' `egrep "网络存储" -rl ./`
sed -i 's/"实时流量监测"/"流量"/g' `egrep "实时流量监测" -rl ./`
sed -i 's/"KMS 服务器"/"KMS激活"/g' `egrep "KMS 服务器" -rl ./`
sed -i 's/"USB 打印服务器"/"打印服务"/g' `egrep "USB 打印服务器" -rl ./`
sed -i 's/"Web 管理"/"Web管理"/g' `egrep "Web 管理" -rl ./`
sed -i 's/"管理权"/"改密码"/g' `egrep "管理权" -rl ./`
sed -i 's/"带宽监控"/"监控"/g' `egrep "带宽监控" -rl ./`
#set zsh as default shell
sed -i 's/\/bin\/ash/\/usr\/bin\/zsh/g' package/base-files/files/etc/passwd

backup=$PWD
#备份工作目录以免找不到下一步脚本
#现在可随意修改工作目录位置

git clone https://github.com/shidahuilang/openwrt-package.git --depth=1 --branch=Official ./package/addons

rm -rf ./package/addons/luci-theme-argon
rm -rf ./package/addons/luci-app-argon-config

git clone https://github.com/jerrykuku/luci-theme-argon.git ./package/argon/luci-theme-argon

git clone https://github.com/jerrykuku/luci-app-argon-config.git ./package/argon/luci-app-argon-config

git clone https://github.com/Kazagumo/luci-app-3ginfo-lite-zhcn ./package/3glite

git clone https://github.com/4IceG/luci-app-sms-tool ./package/smstool

git clone https://github.com/Kazagumo/OPi-Zero2-OPPatcher --depth=1 ./OPi-Zero2-OPPatcher
bash ./OPi-Zero2-OPPatcher/replace.sh

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
