#!/bin/bash
# ArcMCV.sh: Mobile Construction Vehicle for ArchLinux.
# -----------------------------------------------------
# Copyright 2015 Guanrenfu (GitHub)
# Copyright 2015 Mingye Wang <arthur200126@gmail.com>
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
declare -A mcvopts
VERSION=1.0
VERSIONSTATUS=$"，正式版"
mcvopts[c]=$"不运行 clear" 
mcv_cmdline_c(){ alias clear=:; }
mcvarch_choice_error(){ echo $"选项错误！如果要不选，请选择 None。"; }
# library
mcv_import(){ if [ -e "$1" ]; then . "$1" || echo non-zero ret $1 $?; else echo Library $1 not found; exit 1; fi; }
mcv_import "${MCV=$(dirname "$0")/..}/common.sh"
# start
reset
echo $"欢迎您来到Arch Linux Shell（快速设置）"
echo
echo $"版本："$VERSION$VERSTATUS
echo

if [ $(getconf LONG_BIT) = 64 ]; then
	info $"准备 64 位 pacman"
	sed -i -ne '89,90d
88a Include = /etc/pacman.d/mirrorlist
88a [multilib]' &&
	pacman -Syu --noconfirm || warn $"Pacman 操作失败"
fi

echo 
echo $"首先，我们要为您创建一个普通用户（此用户为wheel用户组，可以使用sudo）"
echo $"如果您已经创建，请直接输入两次回车"
echo 
echo $"请注意用户名只能由小写字母和不在开头的数字组成"
echo 
echo 

while [[ "$username" =~ (^$|^[0-9]|[^a-z0-9]) ]]; do
	read -i -ep $"新用户名：" username
done

read -s -p $"新密码：" userpasswd
useradd -m -G wheel -s /bin/bash "$username"
chpasswd <<< "$username:$userpasswd"
groupadd -g "$(id -G -n wheel)" "$(id -n $username)"
# sed -i "73a ${usrnm} ALL=(ALL) ALL" /etc/sudoers
# dangerous!

clear
cd /home/${username}
echo $"您的新用户已经创建完成，现在我们继续进行设置。"
if [ -e mcv.sh ]; then
	echo $"我们发现了已有的 mcv.sh，你可以退出直接运行。"
	select opt in $"终止 MCV" $"切换到 mcv.sh" $"继续运行"
	do
		case $opt in
			($"终止 MCV")	bye $"现在你可以用新用户 ${username} 运行 ./mcv.sh 了。";;
			($"切换到 mcv.sh") exec sudo -H -u ${username} ~/mcv.sh;;
			($"继续运行") 	mv mcv.sh "mcv.$(date -u +%s)_$RANDOM.sh"; break;；
		esac
	done
fi

cat > mcv.sh << ESSENTIALS
#! /bin/bash
# generated by ArchMCV on $(LANG=C date)
aurinst(){
	echo AURINST \$1
	wget -nv "https://aur.archlinux.org/packages/${1:0:2}/$1/$1.tar.gz" &&
	tar xf "\$1".tar.gz
	cd "\$1"
	yes | makepkg -si
	cd ..
}
aurget(){
	pushd \$(mktemp -d)
	for aurpk; do aurinst "\$aurpk"; done
	popd
}
pacman_S(){ sudo pacman -S --noconfirm "\$@"; }
sysdserv(){ sudo systemctl enable \$1; sudo systemctl start \$1; }
# 安装必要组件
pacman_S wget git wqy-microhei xorg-server xorg-xinit
cp /etc/X11/xinit/xinitrc ~/.xinitrc
# sed '\$d' ~/.xinitrc"
ESSENTIALS
chmod +x mcv.sh
chown ${username} mcv.sh 

mcvsh_paragraph Yaourt
echo $"安装 Yaourt 可以帮助你获得 AUR 软件，推荐安装。"
echo "# Yaourt" >> mcv.sh
PS3=$"是否要安装 Yaourt？"
select yaourt in Yes No
do
	case $yaourt in
	(Yes)
		mcvdo aurget package-query yaourt
		break;;
	(No)
		break;;
	esac
done

mcvsh_paragraph Zsh
if yesno_query $"是否要安装 Z Shell？" \
	$"Zsh 曾被称为终极 Shell，配合 oh-my-zsh 更比默认配置的 bash 强大不少。"; then
	mcvdo "wget -nv https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/pacman_S.sh -O- | sh &>/mcv_omz.log &"
fi

_Xsession_extras_question(){
	[ "$1" ] || return 2
	echo $"拓展包 $1 能够提供一些原生软件和主题，让你获得一个完整的 $Xsession 体验。"
	[ "$2" ] && echo "$2"
	echo
	local PS3=$"是否要安装 ""$Xsession"$" 拓展包？"
	select XsessionExt in Yes No; do
		case $XsessionExt in
		(Yes)	mcvdo "pacman_S $2"; break;;
		(No)	break;;
		esac
	done
}
mcvsh_paragraph "Xsession (Desktop Enviroment / Window Manager)"
PS3=$"请选择一个桌面环境或窗口管理器："
select Xsession in Gnome Plasma/KDE5 Xfce4 Cinnamon Mate None
do
	case $Xsession in
	(Gnome)
		mcvdo "echo exec gnome-session >> ~/.xinitrc"
		mcvdo "pacman_S gnome"
		_Xsession_extras_question gnome-extra
		break;;
	(Plasma/KDE5)
		mcvdo "echo exec startkde >> ~/.xinitrc"
		mcvdo "pacman_S plasma"
		break;;
	(Xfce4)
		mcvdo "echo exec startxfce4 >> ~/.xinitrc"
		mcvdo "pacman_S xfce4"
		_Xsession_extras_question xfce4-goodies
		break;;
	(Cinnamon)
		mcvdo "echo exec cinnamon-session >> ~/.xinitrc"
		mcvdo "pacman_S cinnamon"
		_Xsession_extras_question mate-extra \
		$"Cinnamon 和 Mate 使用同样的拓展包，若不安装您将面临虚拟终端都没有的尴尬局面。"
		break;;
	(Mate)
		mcvdo "echo exec mate-session >> ~/.xinitrc"
		mcvdo "pacman_S mate"
		_Xsession_extras_question mate-extra
		break;;
	(None)
		mcvdo $"不安装桌面环境！"
		break;;
	esac
	mcvarch_choice_error
done

clear

mcvdo "**Optional Packages**"
echo $"恭喜您完成了多半的配置了，现在让我们来看一下几个日常用的软件吧："

if yesno_query $"是否安装 Networkmanager 网络管理器？" $"大部分人都需要这个的。"; then
	mcvsh_paragraph NetworkManager
	mcvdo pacman_S networkmanager
	mcvdo sysdserv NetworkManager
fi

if yesno_query $"是否安装 fcitx-googlepinyin？" $"首先安装输入法。" $"我们还会额外安装一个 sunpinyin 作为备份。" \
	$"如果你习惯使用五笔，可以不安装。"; then
	mcvsh_paragraph fcitx Chinese Input
	mcvdo pacman_S fcitx fcitx-{im,qt5,configtool}
	mcvdo pacman_S fcitx-googlepinyin
	mcvdo pacman_S fcitx-sunpinyin
fi

clear
mcvsh_paragraph Text Edior
echo $"是时候选择一款你看着顺眼的文本编辑器了！"
echo $"Gedit 和 Leafpad 是适用于新手的文本编辑器。"

PS3=$"文本编辑器："
select texteditor in gvim emacs gedit leafpad None
do
	case $texteditor in
	(gvim)
		mcvdo pacman_S gvim{,-python3}
		mcvdo echo -e "filetype indent on\nsyntax enable\ncolorscheme murphy >> ~/.vimrc"
		break;;
	(emacs|gedit|leadpad)
		mcvdo pacman_S $texteditor
		break;;
	(None)
		break;;
	esac
	mcvarch_choice_error
done

clear
mcvsh_paragraph Media Player
echo $"选择媒体播放器。作者本人推荐 SMPlayer 播放器。"
PS3=$"媒体播放器："
select video in SMPlayer VLC MPV None
do
	case $video in
	(SMPlayer)	mcvdo pacman_S smplayer; break;;
	(VLC)	mcvdo pacman_S vlc; break;;
	(MPV)	mcvdo pacman_S mpv; break;;
	esac
	mcvarch_choice_error
done

clear
mcvsh_paragraph Web Browser
if yesno_query $"是否安装 Flash Player？"; then
	mcvdo pacman_S flashplugin
fi

PS3=$"网页浏览器："
select browser in Firefox Opera None;
do
	case $browser in
	(Firefox)
		mcvdo pacman_S firefox
		yesno_query $"是否安装 Firefox 中文支持？" && mcvdo pacman_S firefox-i18n-zh-cn
		break;;
	(Opera)
		mcvdo pacman_S opera
		break;;
	(None)
		break;;
	esac
	mcvarch_choice_error
done

clear
mcvsh_paragraph Touchpad Drivers for X
yesno_query $"安装 Synapics 触摸板驱动：" $"如果你的笔记本使用触摸板，那么你需要一个触摸板驱动来操作。" &&
	mcvdo pacman_S xf86-input-synaptics
yesno_query $"安装 evdev 驱动：" $"你也可以装一份几乎万能的 evdev 驱动放着：" &&
	mcvdo pacman_S xf86-input-evdev

clear
mcvsh_paragraph Misc
yesno_prepend $"是否安装 Gnome 计算器？" && mcvdo pacman_S gcalctool
yesno_prepend $"是否安装 LibreOffice 办公套件？" && mcvdo pacman_S libreoffice-fresh{,-zh-CN}
yesno_prepend $"是否安装 Python 开发环境？" && mcvdo pacman_S {,i}python
rm -rf /var/log/* /var/tmp/* /tmp/*
# rm -rf /usr/share/man/!(*man*) &>/dev/null

clear
echo $"配置完成！撒花www"
echo $"现在你可以切换到 ${username} 来运行这个脚本，或者"
yesno_query $"是否直接运行脚本？" $"直接让本脚本切换用户运行。" &&
	sudo -H -u ${username} ~/mcv.sh
