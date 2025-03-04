#!/bin/bash

patch_dir(){
for file in `ls $1`     
do
    if [ -d $1"/"$file ]  
    then
        patch_dir $1"/"$file
    else
        patch -p1 < $1"/"$file   
    fi
done
}

git clone https://github.com/openwrt/openwrt.git --depth=1 --branch=main
script_path=$PWD
cd ./openwrt
sed -i 's/\/bin\/ash\/usr\/bin\/zsh/g' package/base-files/files/etc/passwd

cat << "EOF" > package/base-files/etc/uci-defaults/99-custom
uci set wireless.@wifi-device[0].disabled='0'
uci commit
wifi up
EOF

backup=$PWD
#备份工作目录以免找不到下一步脚本
#现在可随意修改工作目录位置



git clone https://github.com/jerrykuku/luci-theme-argon.git ./package/argon/luci-theme-argon --depth=1 

git clone https://github.com/jerrykuku/luci-app-argon-config.git ./package/argon/luci-app-argon-config --depth=1 

git clone https://github.com/4IceG/luci-app-sms-tool ./package/luci-app-sms-tool --depth=1 

git clone https://github.com/Kazagumo/luci-app-oled ./package/luci-app-oled-mod --depth=1 

git clone https://github.com/gSpotx2f/luci-app-temp-status ./package/luci-app-temp-status --depth=1

git clone https://github.com/Kazagumo/luci-app-cpufreq ./package/luci-app-cpufreq --depth=1

git clone https://github.com/Kazagumo/sierra-mbpl ./package/sierra-mbpl --depth=1

git clone https://github.com/Kazagumo/opicm4-openwrt-patcher --branch=plain --depth=1 ./opicm4-openwrt-patcher
bash ./opicm4-openwrt-patcher/replace.sh

rm ./opicm4-openwrt-patcher -rf

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

#所有操作执行完毕 
cd $backup

./scripts/feeds update -a


pushd feeds/packages

patch_dir $script_path"/patches/feeds"

popd


./scripts/feeds install -a
