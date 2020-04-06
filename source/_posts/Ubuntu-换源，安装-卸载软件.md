---
title: Ubuntu 换源，安装&卸载软件
date: 2017-07-17 18:34:57
tags:
    - Ubuntu
    - Linux
categories:
    - Ubuntu
---

国内的筒子们，经常发现在update的时候各种卡。。。有时候心情好，等等也就罢了。万一某一天急着安装软件，那种状态下，真的是多等一秒感觉都是心烦气躁的。所以，本文就来跟大家聊聊在Ubuntu 中换源，安装&卸载软件的那些事，欢迎各位一起交流。。。
![Ubuntu16.04](/images/ubuntu16.04.png)
<!-- more -->
## 1. 查找国内的开源镜像提供的源地址

> Ubuntu的源的list文件位于 `/etc/apt/sources.list`

- 高校镜像源（国内其他大学也有提供，可自行查找）
[清华大学开源镜像站 ][c1c73b3e]
[中科大开源镜像站][9e517fb6]

  [c1c73b3e]: http://link.zhihu.com/?target=https%3A//mirrors.tuna.tsinghua.edu.cn/help/ubuntu/ "清华大学开源镜像站"
  [9e517fb6]: http://link.zhihu.com/?target=https%3A//mirrors.ustc.edu.cn/repogen/ "中科大开源镜像站"

- 企业镜像源（其他企业的请自行查找）
[阿里云开源镜像站 ][a22d80c3]
[网易开源镜像站][a346c5fb]

  [a22d80c3]: http://link.zhihu.com/?target=http%3A//mirrors.aliyun.com/help/ubuntu "阿里云开源镜像站"
  [a346c5fb]: http://link.zhihu.com/?target=http%3A//mirrors.163.com/.help/ubuntu.html "网易开源镜像站"

**这里以清华源为例**

先去查一下清华源的帮助文档，戳 [清华大学开源镜像站 ][c1c73b3e]，选择相匹配的Ubuntu的版本，会得到软件源镜像的地址。

接下来直接替换一下系统的source.list文件~~~

```bash
# 备份一下
sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
# 修改
sudo vi /etc/apt/sources.list
```
将文档里面所有的内容删除，然后替换为清华镜像提供的软件源镜像的地址。
例如我用的 16.04 版， 替换为：

```bash
# 默认注释了源码镜像以提高 apt update 速度，如有需要可自行取消注释
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-updates main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-updates main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-backports main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-backports main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-security main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-security main restricted universe multiverse
```
然后再update一下，你会发现速度还是有明显的提升的。
```bash
sudo apt update
```
## 2. 使用apt安装软件

这个就不多说了，比较简单，譬如安装tree
```bash
sudo apt install tree -y
```
这里的 -y 参数是为了在安装的时候默认选择yes

## 3. deb包安装&卸载（需要先下载好）

- 安装命令
```bash
sudo dpkg -i xxx.deb
```
- 安装依赖（如果提示需要的话）
```bash
sudo apt-get install -f
```
- 自动清除残留配置文件
```bash
sudo apt-get autoclean
sudo apt-get autoremove
```
- 完全卸载
```bash
sudo apt-get remove --purge name
```
一般来说，这样的卸载会比较干净地卸载掉软件。有些没有办法自动删除的文件，可以手动去删除掉

## 4. 另一种deb包安装方式
```bash
# cd到安装包目录
sudo apt install ./xxxx.deb
```
## 5. 安装filename.tar.gz软件

- 解压

```bash
tar -xzvf file.tar.gz
```
- 然后在解压目录或者bin文件夹中执行setup.sh文件。。。这个一般不定，安装前最好查一下官网说明

## 6. 源码安装

有些软件没有被收录进软件镜像源，或者说开发者需要去使用他们最新的版本，这时候就要自己去他们的官网或者是代码托管平台下载最新的Linux源码，自己来build。

这种方式安装需**要解决很多的依赖**。。。。安装前，多问问度娘，Google

此处还是以tree为例：

- 先去 [Tree FTP][30568cff] 下载最新的源码包
- 解压

```bash
tar zxf tree-1.7.0.tgz
cd  tree-1.7.0/
make and install
sudo make
sudo make install
```
**如果没有配置g++环境，先用apt安装build-essential**
- OK, 大功告成
```bash
nutao@master:~/Public/tree-1.7.0$ tree
.
├── CHANGES
├── color.c
├── color.o
├── doc
│   ├── tree.1
│   ├── tree.1.fr
│   └── xml.dtd
├── hash.c
├── hash.o
├── html.c
├── html.o
├── INSTALL
├── json.c
├── json.o
├── LICENSE
├── Makefile
├── README
├── strverscmp.c
├── TODO
├── tree
├── tree.c
├── tree.h
├── tree.o
├── unix.c
├── unix.o
├── xml.c
└── xml.o
```

## 常用压缩文件的解压命令

  [30568cff]: http://link.zhihu.com/?target=ftp%3A//mama.indstate.edu/linux/tree/ "Tree FTP"

1、*.tar 用 tar –xvf 解压
2、*.gz 用 gzip -d或者gunzip 解压
3、.tar.gz和.tgz 用 tar –xzf 解压
4、*.bz2 用 bzip2 -d或者用bunzip2 解压
5、*.tar.bz2用tar –xjf 解压
6、*.Z 用 uncompress 解压
7、*.tar.Z 用tar –xZf 解压
8、*.rar 用 unrar e解压
9、*.zip 用 unzip 解压
