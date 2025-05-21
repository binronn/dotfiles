#!/bin/sh

if [[ !$EUID -ne 0 ]]; then
   echo "Can't use root run !"
   exit 1
fi

################
### yay
################
# 检查 yay 是否已安装
if ! command -v yay &> /dev/null; then
    echo "yay 未安装，正在开始安装..."

    # 安装依赖（base-devel 和 git）
    sudo pacman -Sy --noconfirm base-devel git

    # 克隆 yay AUR 仓库到临时目录
    cd /tmp || exit
    git clone https://aur.archlinux.org/yay.git

    # 进入目录并编译安装
    cd yay || exit
    makepkg -si --noconfirm

    echo "yay installed"
fi

################
### terminal
################
# add hyperland.conf 
################
sudo pacman -Sy --noconfirm kitty

################################
# file manager thunar
################################
#`thunar-archive-plugin`: 这个插件为Thunar添加了对归档文件的支持，允许用户使用上下文菜单创建和提取各种类型的归档文件（如.zip、.tar.gz等）。

#`thunar-media-tags-plugin`: 该插件为Thunar增加了查看和编辑多媒体文件标签（例如MP3、OGG格式的音频文件）的能力。

#`thunar-volman`: 它是一个用于管理外部设备自动挂载的工具。当插入USB驱动器、光盘或其他可移动媒体时，`thunar-volman`可以自动打开Thunar并显示相应的内容，同时提供卸载或弹出设备的选项。

#`tumbler`: Tumbler是Thunar使用的缩略图服务，它负责生成文件的缩略图预览，包括图片、文档和视频等，以便在文件管理器中以更直观的方式展示文件内容。
################################
sudo pacman -Sy --noconfirm thunar-archive-plugin thunar-media-tags-plugin thunar-volman tumbler

################
### 监听 hyprland 消息内容，如显示器热插拔
################
# add hyperland.conf exec-once = nm-applet --indicator
################
sudo pacman -Sy --noconfirm socat

################
### Notify ui ##
################
# conifg file in .config/mako/config
# add hyperland.conf exec-once mako
################
sudo pacman -Sy --noconfirm mako 


################
### Network ui
################
# add hyperland.conf exec-once = nm-applet --indicator
################
sudo pacman -Sy --noconfirm networkmanager network-manager-applet


#####################
### Bluetooh manager 
#####################
# add hyperland.conf exec-once = blueman-applet
#####################
sudo pacman -Sy --noconfirm bluez bluez-utils blueman
sudo systemctl enable bluetooth.service
sudo systemctl start bluetooth.service
blueman-manager control bluetooth


################################
### wofi launcher app
################################
# config file in .config/wofi/style.css
# wofi --show drun, must run with --show drun
################################
sudo pacman -Sy --noconfirm wofi


################
### Hypylock 
################
# config in .config/hypr/hyperlock.conf 
################
sudo pacman -Sy --noconfirm hyprlock

################
### Hyprpaper 
################
# config in .config/hypr/hyperpaper.conf 
# add hyprland.conf exec-once = hyperpaper --config $HOME/.config/hypr/hyprpaper.conf
################
sudo pacman -Sy --noconfirm hyprpaper

################
### screen_shot
################
# /usr/bin/grimshot copy area
# will copy area image to clipboard
################
sudo pacman -Sy --noconfirm grim
yay -Sy --noconfirm grimshot-bin-sway


################
### Clipboard
################
# add hyperland.conf
# exec-once = wl-paste --watch cliphist store # 监听粘贴板变化
# bind=SUPER, V, exec, cliphist list | wofi -dmenu | cliphist decode | wl-copy  # 粘贴板列表
sudo pacman -Sy --noconfirm wl-clipboard cliphist


################
### Waybar
################
# config in .config/waybar/{config.jsonc|style.css} 
################
sudo pacman -Sy --noconfirm waybar


################################
### Media contronl for waybar
################################
sudo pacman -Sy --noconfirm pamixer pavucontrol


################################
### Brightness contronl for waybar
################################
sudo pacman -Sy --noconfirm brightnessctl


################################
### Logout contronl ui for waybar
################################
yay -Sy --noconfirm wlogout

################
### Swayidle
################
# add hyperland.conf 
# exec-once = swayidle -w timeout 300 'brightnessctl s 10 && hyprlock'
# Auto lockscreen
################
sudo pacman -Sy --noconfirm swayidle


################
### Chinese font support
################
sudo pacman -Sy --noconfirm noto-fonts-cjk ttf-cascadia-code 
sudo fc-cache -fv

################
### fcitx5
################
sudo pacman -Sy --noconfirm fcitx5 fcitx5-chinese-addons fcitx5-configtool

################################
### fcitx5-themes
################################
# https://github.com/thep0y/fcitx5-themes-candlelight
if [ -d "/tmp/fctix5-themes-candlelight" ]; then
    rm -rf "/tmp/fctix5-themes-candlelight"
fi
mkdir -p /tmp/fctix5-themes-candlelight
git clone https://github.com/thep0y/fcitx5-themes-candlelight /tmp/fctix5-themes-candlelight

if [ -d "/home/byron/.local/share/fcitx5/themes" ]; then
    rm -rf "/home/byron/.local/share/fcitx5/themes"
fi
mkdir -p /home/byron/.local/share/fcitx5/themes
cp -r /tmp/fctix5-themes-candlelight/macOS-dark /home/byron/.local/share/fcitx5/themes

if [ -f "~/.config/fcitx5/conf/classicui.conf" ]; then
    rm -rf "~/.config/fcitx5/conf/classicui.conf"
fi
if [ ! -d "~/.config/fcitx5/conf" ]; then
    mkdir -p "~/.config/fcitx5/conf"
fi

tee "~/.config/fcitx5/conf/classicui.conf" > /dev/null <<EOF
Vertical Candidate List=False
PerScreenDPI=True
Font="Cascadia Code Bold 9"
Theme=macOS-dark
EOF


################
### Enable deep sleep (hibernate)
################
################

read -r -p "Enable deep sleep(hibernation)？ (y/N): " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
	## 创建swap文件
	echo 'Make /swapfile_hibernation file...'
	sudo fallocate -l 8G /swapfile_hibernation 
	sudo chmod 600 /swapfile_hibernation
	sudo mkswap /swapfile_hibernation
	sudo swapon /swapfile_hibernation

	# ## 挂载swap文件
	sudo tee -a /etc/fstab <<EOF

/swapfile_hibernation none swap sw 0 0
EOF

	echo ''
	echo 'Enable resume hook ...'

	MKINITCPIO_CFG="/etc/mkinitcpio.conf.b"
	sudo cp $MKINITCPIO_CFG /etc/mkinitcpio.conf.bak
	echo -e 'Created backfile for /etc/mkinitcpio.conf: /etc/mkinitcpio.conf.bak\n'

	if [ $? -eq 0 ]; then

		if [ ! -f "$MKINITCPIO_CFG" ]; then
			echo "错误：文件 $MKINITCPIO_CFG 不存在。"
			exit 1
		fi

		HOOKS_LINE=$(grep "^HOOKS=" "$MKINITCPIO_CFG")
		if [ -z "$HOOKS_LINE" ]; then
			echo "[Deep sleep make fail.] 错误：在文件 $MKINITCPIO_CFG 中找不到以 HOOKS= 开头的行。"
		else
			echo -e "\nFinded HOOKS line: \n$HOOKS_LINE"

			if [[ "$HOOKS_LINE" == *" resume "* ]]; then
				sudo mkinitcpio -P
				echo -e "Deep sleep make successed.\n"
			else
				if [[ "$HOOKS_LINE" =~ "fsck" ]]; then
					EW_HOOKS_LINE=$(echo "$HOOKS_LINE" | sed 's/fsck/resume fsck/')

					# 使用 printf 对 HOOKS_LINE 和 EW_HOOKS_LINE 进行转义，防止正则表达式特殊字符的影响
					ESCAPED_HOOKS_LINE=$(printf '%s\n' "$HOOKS_LINE" | sed 's:[][\/.^$*]:\\&:g')
					ESCAPED_EW_HOOKS_LINE=$(printf '%s\n' "$EW_HOOKS_LINE" | sed 's:[\/&]:\\&:g')

					sudo sed -i "s/$ESCAPED_HOOKS_LINE/$ESCAPED_EW_HOOKS_LINE/" "$MKINITCPIO_CFG"

					if [ $? -eq 0 ]; then
						echo 'Changed HOOKS line'
						grep "^HOOKS=" "$MKINITCPIO_CFG" # 显示修改后的行
						echo -e '\n'
						# sudo mkinitcpio -P
						echo -e "Deep sleep make successed.\n"
					else
						echo "[Deep sleep make fail.] sed rewrite $MKINITCPIO_CFG failed."
						echo "[Deep sleep make fail.] 请手动检查并修改文件 $MKINITCPIO_CFG"
					fi
				else
					echo "[Deep sleep make fail.] 错误：在 HOOKS 行中找不到 'fsck' hook，无法在其前面添加 'resume'。"
					echo "[Deep sleep make fail.] 请手动检查并修改文件 $MKINITCPIO_CFG"
				fi
			fi
		fi
	else
		echo "[Deep sleep make filed.] Cann't create swapfile."
	fi
fi


################################################
### SDDM Autologin
################################################
# add hyperland.conf
# exec-once = hyprlock
################################################
CONFIG_FILE="/etc/sddm.conf"

read -r -p "Enable sddm autologin？ (y/N): " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then

	AUSER=$USER
	echo $AUSER

	if [ ! -f "/usr/share/wayland-sessions/hyprland.desktop" ]; then
		echo 'Not find /usr/share/wayland-sessions/hyprland.desktop file, and autologin failed!!!'
	else


		if [ -f "$CONFIG_FILE" ]; then
			sudo rm "$CONFIG_FILE"
		fi

		sudo tee "$CONFIG_FILE" > /dev/null <<EOF
[Autologin]
Relogin=false
Session=hyprland
User=$AUSER
EOF
# Session= 来自 /usr/share/wayland-sessions/hyprland.desktop 不包含后缀

		echo "SDDM Autologin writed, $CONFIG_FILE , for $AUSER"
	fi
fi
