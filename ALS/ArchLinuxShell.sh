#!/bin/bash
reset
echo "欢迎您来到Arch Linux Shell（快速设置）"
echo ""
echo "版本：1.0 ，正式版"
echo ""

if [ $(getconf LONG_BIT) = 64 ];then
	sed -i '89,90d' /etc/pacman.conf >> /dev/null 2>&1
	sed -i '88a Include = /etc/pacman.d/mirrorlist' /etc/pacman.conf >> /dev/null 2>&1
	sed -i '88a [multilib]' /etc/pacman.conf >> /dev/null 2>&1
	pacman -Syu --noconfirm  2>> /dev/null 
fi

echo ""
echo "首先，我们要为您创建一个普通用户（此用户为wheel用户组，可以使用sudo）"
echo "如果您已经创建，请直接输入两次回车"
echo ""
echo "请注意用户名不能使用大写字母，不然会创建失败"
echo ""
echo ""

read -p "您的新用户的用户名（小写）：" usrnm
read -s -p "您的新用户的密码：" usrpasswd
useradd -m -G wheel -s /bin/bash ${usrnm}
echo "${usrnm}:${usrpasswd}" | chpasswd
sed -i "73a ${usrnm} ALL=(ALL) ALL" /etc/sudoers

clear
echo "您的新用户已经创建完成，现在我们继续进行设置。"
echo ""
echo ""
echo "现在在我们继续之前，我们需要知道您是否愿意继续："
echo ""
echo "1、如果您是第一次使用本Shell，请不要疑惑，直接选择本选项，我们将继续为您进行设置。"
echo ""
echo "2、如果您已经执行过一次本脚本并且生成了continue.sh脚本，那么请您选择本选项。"
echo "本选项将会终止本Shell，在Shell终止后您就可以使用您新的用户来运行continue.sh了。"
echo ""
while true
do
	read -n1 -p "请输入1或2：" wish
	echo ""

	if [ ${wish} = 2 ];then
		clear
		echo "好的，现在您可以使用logout命令登出您的tty并使用您的新用户“${usrnm}”登录并运行continue.sh了。"
		echo "感谢您的再次使用，再见。"
		exit
	elif [ ${wish} = 1 ];then
		clear
		echo "感谢您的使用，本Shell将继续进行。"
		break
	fi
done
echo ""
echo "#安装必要组件" >> continue.sh
echo "sudo pacman -S --noconfirm wget" >> continue.sh
echo "sudo pacman -S --noconfirm git" >> continue.sh
echo "sudo pacman -S --noconfirm wqy-microhei" >> continue.sh
echo "sudo pacman -S --noconfirm xorg-server" >> continue.sh
echo "sudo pacman -S --noconfirm xorg-xinit" >> continue.sh
echo "cp /etc/X11/xinit/xinitrc ~/.xinitrc" >> continue.sh
echo "sed '\$d' ~/.xinitrc" >> continue.sh
echo "" >> continue.sh

echo "请问您是否想安装Yaourt？Yaourt作为pacman的一个外壳增加了对于AUR的支持。"
echo ""
echo "基本属于必装软件，但是如果不需要的话可以不安装。"
echo ""
echo ""

while true
do
	read -n1 -p "请输入Y或N：" yaourt
	echo ""
	if [ ${yaourt} = Y ] || [ ${yaourt} = y ];then
		echo "#安装Yaourt" >> continue.sh
		echo "mkdir yaourt" >> continue.sh
		echo "cd yaourt" >> continue.sh
		echo "" >> continue.sh
		
		echo "##安装依赖：package-query" >> continue.sh
		echo "wget https://aur.archlinux.org/packages/pa/package-query/package-query.tar.gz" >> continue.sh
		echo "tar zxf package-query.tar.gz" >> continue.sh
		echo "cd package-query" >> continue.sh
		echo "yes|makepkg -si" >> continue.sh
		echo "cd .." >> continue.sh
		echo "" >> continue.sh
		
		echo "##开始安装Yaourt" >> continue.sh
		echo "wget https://aur.archlinux.org/packages/ya/yaourt/yaourt.tar.gz" >> continue.sh
		echo "tar zxf yaourt.tar.gz" >> continue.sh
		echo "cd yaourt" >> continue.sh
		echo "yes|makepkg -si" >> continue.sh
		echo "cd .." >> continue.sh
		echo "rm -rf yaourt" >> continue.sh
		echo "" >> continue.sh
		break
	elif [ ${yaourt} = N ] || [ ${yaourt} = n ];then
		echo "#不安装Yaourt" >> continue.sh
		break
	fi
done

clear
echo "请问您是否想安装Zsh？Zsh是Linux中最强大的Shell，"
echo ""
echo "拥有比Bash更加方便的设置与外观。（注：将同时安装zsh和oh-my-zsh设置组件）"
echo ""
echo ""
while true
do
	read -n1 -p "请输入Y或N：" zsh
	echo ""

	if [ ${zsh} = Y ] || [ ${zsh} = y ];then
		echo "#安装zsh" >> continue.sh
		echo "sudo pacman -S --noconfirm  zsh" >> continue.sh
		echo "git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh" >> continue.sh
		echo "cp -f ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc" >> continue.sh
		echo "echo "${usrpasswd}"|chsh -s /bin/zsh" >> continue.sh
		echo "" >> continue.sh
		break
	elif [ ${zsh} = N ] || [ ${zsh} = n ];then
		echo "#不安装Zsh" >> continue.sh
		break
	fi
done

clear
echo "现在请您选择一个桌面环境：我们默认提供Gnome、3Plasma（KDE5）、Xfce4、Cinnamon、和Mate"
echo ""
echo "如果没有您需要的（如窗口管理器，我们将在下个版本添加）或是您不需要桌面环境"
echo ""
echo "那么请选择不安装然后自行安装您喜欢的桌面环境（或窗口管理器）"
echo ""
echo ""
echo "我们还提供一些扩展包，这些将会在您选择您喜欢的桌面环境后提供选择。"
echo ""
read -p "请按回车继续"  var
clear
echo "现在，请选择一个桌面环境：1、gnome  2、plasma  3、xfce4  4、cinnamon  5、mate。  99、不安装"
echo ""
echo "#安装桌面环境" >> continue.sh

while true
do
	read -n1 -p "请输入1-5：" choose
	echo ""
	case $choose in:
	1)	chose=gnome
		echo "echo "exec gnome-session" >> ~/.xinitrc" >> continue.sh
		echo "sudo pacman -S --noconfirm gnome" >> continue.sh
		clear
		echo "请问您是否要安装${chose}扩展包？其中包含了很多${chose}的原生软件和一些主题等（建议安装）"
		echo ""
		while true
		do
			read -n1 -p "请输入Y/N：" ge
			echo ""
			if [ ${ge} = Y ] || [ ${ge} = y ];then
				echo "sudo pacman -S --noconfirm gnome-extra" >> continue.sh
				break
			elif [ ${ge} = N ] || [ ${ge} = n ];then
				break
			fi
		done
		echo "" >> continue.sh
		break
	;;

	2)	chose=plasma
		echo "echo "exec startkde" >> ~/.xinitrc" >> continue.sh
		echo "sudo pacman -S --noconfirm plasma" >> continue.sh
		echo "" >> continue.sh
		break
	;;

	3)	chose=xfce4
		echo "echo "exec startxfce4" >> ~/.xinitrc" >> continue.sh
		echo "sudo pacman -S --noconfirm xfce4" >> continue.sh
		clear
		echo "请问您是否要安装${chose}扩展包？其中包含了很多${chose}的原生软件和一些主题等（建议安装）"
		echo ""
		while true
		do
			read -n1 -p "请输入Y/N：" ge
			echo ""
			if [ ${ge} = Y ] || [ ${ge} = y ];then
				break
				echo "sudo pacman -S --noconfirm xfce4-goodies" >> continue.sh
			elif [ ${ge} = N ] || [ ${ge} = n ];then
				break
			fi
		done
		echo "" >> continue.sh
		break
	;;

	4)	chose=cinnamon
		echo "echo "exec cinnamon-session" >> ~/.xinitrc" >> continue.sh
		echo "sudo pacman -S --noconfirm cinnamon" >> continue.sh
		clear
		echo "请问您是否要安装mate的扩展包？虽然桌面环境并不相同但是软件完全兼容。"
		echo ""
		echo "而且cinnamon不安装扩展包的话会出现连虚拟终端都没有的尴尬局面。"
		echo ""
		while true
		do
			read -n1 -p "请输入Y/N：" ge
			echo ""
			if [ ${ge} = Y ] || [ ${ge} = y ];then
				echo "sudo pacman -S --noconfirm mate-extra" >> continue.sh
				break
			elif [ ${ge} = N ] || [ ${ge} = n ];then
				break
			fi
		done
		echo "" >> continue.sh
		break
	;;

	5)	chose=mate
		echo "echo "exec mate-session" >> ~/.xinitrc" >> continue.sh
		echo "sudo pacman -S --noconfirm mate" >> continue.sh
		clear
		echo "请问您是否要安装${chose}扩展包？其中包含了很多${chose}的原生软件和一些主题等（建议安装）"
		echo ""
		while true
		do
			read -n1 -p "请输入Y/N：" ge
			echo ""
			if [ ${ge} = Y ] || [ ${ge} = y ];then
				echo "sudo pacman -S  --noconfirm mate-extra" >> continue.sh
				break
			elif [ ${ge} = N ] || [ ${ge} = n ];then
				break
			fi
		done
		echo "" >> continue.sh
		break
	;;

	*)
		echo "#不安装桌面环境" >> continue.sh
		break
	;;
	esac
done

clear
echo "恭喜您完成了多半的配置了，现在让我们来看一下几个日常用的软件吧："
echo ""
echo "#安装Networkmanager网络管理器" >> continue.sh
echo "sudo pacman -S --noconfirm networkmanager" >> continue.sh
echo "sudo systemctl enable NetworkManager" >> continue.sh
echo "sudo systemctl start NetworkManager" >> continue.sh
echo "" >> continue.sh

echo "首先，我们要为您安装中文输入法。"
echo ""
echo "本版本仅支持fcitx框架+Googlepinyin输入法"
echo "（由于一个输入法可能会安装失败所以再加上一个sunpinyin输入法）："
echo ""
echo "但是如果您习惯使用Ibus或是五笔输入法的话请不要安装。所以，请根据您的需求输入Y/N。"
echo ""
echo ""

while true
do
	read -n1 -p "请输入Y/N：" fci
	echo ""
	if [ ${fci} = Y ] || [ ${fci} = y ];then
		echo "#安装中文输入法" >> continue.sh
		echo "sudo pacman -S --noconfirm fcitx" >> continue.sh
		echo "sudo pacman -S --noconfirm fcitx-im" >> continue.sh
		echo "sudo pacman -S --noconfirm fcitx-qt5" >> continue.sh
		echo "sudo pacman -S --noconfirm fcitx-googlepinyin" >> continue.sh
		echo "sudo pacman -S --noconfirm fcitx-configtool" >> continue.sh
		echo "sudo pacman -S --noconfirm fcitx-sunpinyin" >> continue.sh
		echo "" >> continue.sh
		break
	elif [ ${fci} = N ] || [ ${fci} = n ];then
		echo "#不安装中文输入法" >> continue.sh
		echo ""
		break
	fi
done

clear
echo "您现在可以选择一个自己熟悉的文本编辑器了，我们共提供了4款编辑器：分别是emacs、gvim、gedit和leafpad。"
echo ""
echo "其中，emacs和gvim属于专业编辑器。如果您对其不了解千万不要选择，而gedit和leafpad更加简单易用，大家可以随意挑选。"
echo ""
echo ""
echo "现在，请像刚才选择桌面环境那样选择文本编辑器吧：1、gvim  2、emace 3、gedit 4、leafpad  99、不安装"
echo ""
echo "#安装文本编辑器" >> continue.sh

while true
do
	read -n1 -p "请输入1-4或99：" text
	echo ""
	if [ ${text} = 1 ];then
		echo "sudo pacman -S --noconfirm gvim" >> continue.sh
		echo "sudo pacman -S --noconfirm gvim-python3" >> continue.sh
		echo "echo "filetype indent on" >> ~/.vimrc" >> continue.sh
		echo "echo "syntax enable" >> ~/.vimrc" >> continue.sh
		echo "echo "colorscheme murphy" >> ~/.vimrc" >> continue.sh
		echo "" >> continue.sh
		break
	fi

	if [ ${text} = 2 ];then
		echo "sudo pacman -S --noconfirm emacs" >> continue.sh
		echo "" >> continue.sh
		break
	fi
	
	if [ ${text} = 3 ];then
		echo "sudo pacman -S --noconfirm gedit" >> continue.sh
		echo "" >> continue.sh
		break
	fi

	if [ ${text} = 4 ];then
		echo "sudo pacman -S --noconfirm leafpad" >> continue.sh
		echo "" >> continue.sh
		break
	fi

	if [ ${wb} = 99 ];then
		echo "#不安装文本编辑器" >> continue.sh
		echo "" >> continue.sh
		break
	fi
done
clear
echo "现在，我们来挑选一个音视播放器。本版本共提供SMPlayer和VLC，个人推荐SMPlayer。"
echo ""
echo ""
echo "请选择您喜欢的播放器，选择smplayer请输入1，VLC请输入2。不安装请输入99"
echo ""
echo "#安装视频播放器" >> continue.sh

while true
do
	read -n1 -p "请输入1-2或99：" video
	echo ""

	if [ ${video} = 1 ];then
		echo "sudo pacman -S --noconfirm smplayer" >> continue.sh
		echo "" >> continue.sh
		break
	fi

	if [ ${video} = 2 ];then
	       	echo "sudo pacman -S --noconfirm vlc" >> continue.sh
		echo "" >> continue.sh
		break
	fi

	if [ ${wb} = 99 ];then
		echo "#不安装音视频播放器" >> continue.sh
		echo "" >> continue.sh
		break
	fi
done

clear
echo "现在，我们可以开始安装浏览器了：我们当前提供有firefox和opera"
echo ""
echo ""
echo "还是像刚才一样：1、firefox  2、opera 99、不安装"
echo ""

echo "#安装网页浏览器" >> continue.sh
echo "sudo pacman -S --noconfirm flashplugin" >> continue.sh
while true
do
	read -n1 -p "请输入1-2或99：" wb
	echo ""

	if [ ${wb} = 1 ];then
		echo "sudo pacman -S --noconfirm firefox" >> continue.sh
		clear
		echo "请问您是否要安装Firefox的中文支持？安装后浏览器将改为中文界面。"
		echo ""
		read -n1 -p "请输入Y/N：" chs
		if [ ${chs} = Y ] || [ ${chs} = y ];then
			echo "sudo pacman -S --noconfirm firefox-i18n-zh-cn" >> continue.sh
		fi
		echo "" >> continue.sh
		break
	fi

	if [ ${wb} = 2 ];then
		echo "sudo pacman -S --noconfirm opera" >> continue.sh
		echo "" >> continue.sh
		break
	fi

	if [ ${wb} = 99 ];then
		echo "#不安装网页浏览器" >> continue.sh
		echo "" >> continue.sh
		break
	fi
done


clear
echo "如果您现在是实体机安装并且是笔记本电脑而且带有触摸板的话"
echo ""
echo "而没有驱动触摸板将不会工作,如果您确实是上述的情况请安装触摸板驱动："

while true
do
	read -n1 -p "请输入Y/N：" syna
	
	if [ ${syna} = Y ] || [ ${syna} = y ];then
		echo "#安装触摸板驱动" >> continue.sh
		echo "sudo pacman -S --noconfirm  xf86-input-synaptics" >> continue.sh
		echo "" >> continue.sh
		break
	fi

	if [ ${syna} = N ] || [ ${syna} = n ];then
		echo "#不安装触摸板驱动"
		break
	fi
done

reset
mv continue.sh /home/${usrnm}/continue.sh
chmod a+x /home/${usrnm}/continue.sh
chmod 777 /home/${usrnm}/continue.sh
rm -rf /var/log/*
rm -rf /var/tmp/*
rm -rf /tmp/*
cd /usr/share/man && rm -rf `ls | grep -v "man"` > /dev/null 2>&1

clear
echo "恭喜您，您已经完成了本次的配置了。"
echo "现在您可以使用logout命令注销并使用您的“${usrnm}”用户登录。"
echo "然后就可以使用./continue.sh的命令来运行刚刚生成的一个Shell，"
echo "当然您也可以将这个Shell保存以便下次重装系统时使用（下次就无需再次进行复杂的设置了）。"
echo ""
echo ""
echo "感谢您使用ALS。"
		
#echo "#GNOME计算器" >> continue.sh
#echo "yes|sudo pacman -S gcalctool" >> continue.sh

#echo "yes|sudo pacman -S libreoffice-fresh" >> continue.sh
#echo "yes|sudo pacman -S libreoffice-fresh-zh-CN" >> continue.sh

#echo "#Python" >> continue.sh
#echo "yes|sudo pacman -S python" >> continue.sh
#echo "yes|sudo pacman -S ipython" >> continue.sh
