---
title: Ubuntu16.04 Grub Rescue
date: 2017-07-13 23:49:08
tags:
    - Ubuntu
    - Linux
categories:
    - Ubuntu
---
如果某一天, 你不小心扩展了一下你的 / 目录, 又忘记了更新 grub 引导. 不好意思, 你有麻烦了

![grub](/images/1.png)

### 解决办法
<!-- more  -->
#### 1. ls 一下所有的盘符

```
grub rescue> ls
```
#### 2. 找/boot/grub的分区
> 如果你的 /boot 没有单独分区, 请执行

```
grub rescue> ls (hd0,msdosx)/boot/grub
```

> 如果你的 /boot 单独分区啦, 请执行

```
grub rescue> ls (hd0,msdosx)/grub
```

ls出如下的目录, 恭喜你找到 /boot 路径了

#### 3. 修复grub引导
> 假设/boot 在(hd0,msdos3) 中

```
# /boot 单独分区
set root=(hd0,msdos3)
set prefix=(hd0,msdos3)/grub
insmod normal
normal
```


```
# /boot 没有单独分区
set root=(hd0,msdos3)
set prefix=(hd0,msdos3)/boot/grub
insmod normal
normal
```
正常情况下, 执行完后, 电脑就能开机进入桌面啦
然后, 还没有结束. (这时千万不要关机, 否则前面步骤再来一次)
**在正常进入系统以后...**

#### 4. 更新系统 grub 引导

```
sudo update-grub
sudo update-grub2
```
> 打印出如下日志(我是双系统)
```bash
Generating grub configuration file ...
Found linux image: /boot/vmlinuz-4.4.0-66-generic
Found initrd image: /boot/initrd.img-4.4.0-66-generic
Found memtest86+ image: /memtest86+.elf
Found memtest86+ image: /memtest86+.bin
Found Windows 10 (loader) on /dev/sda1
done
```
> 然后重新安装grub

```
nutao@nutao-HP:~$ sudo grub-install /dev/sda
# 日志
Installing for i386-pc platform.
Installation finished. No error reported.
```

#### OK, 一切搞定
