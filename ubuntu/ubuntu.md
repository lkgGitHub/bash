# Unity 位置移到底部
> gsettings set com.canonical.Unity.Launcher launcher-position Bottom
> gsettings set com.canonical.Unity.Launcher launcher-position Left

# 软链接：
> ln -s  /usr/local/bin/node
# 环境变量设置：
> vim ~/.bashrc

# 在linux下解压tar.xz文件步骤
> xz -d ***.tar.xz  //先解压xz
> tar -xvf  ***.tar //再解压tar


# 安装nodejs和输入法
=====================install software==============================
软件：java,,go1.8,git,maven,nodejs
sudo apt-get install libssl-dev

1.Debian/Ubuntu 安装git
  $ apt-get install git
  apt install maven
  dpkg 安装失败
  解决办法：
  在系统终端中执行命令：apt-get install -f
  安装包含的所有依赖，执行命令完后再执行dpkg命令：sudo dpkg -i XXX.deb（XXX为该deb包的文件名）即可。
2.ubuntu安装rpm包
  sudo apt-get install alien
  sudo alien --scripts ＊.rpm
