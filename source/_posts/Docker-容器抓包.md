---
title: Docker-容器抓包
date: 2020-04-06 15:04:44
tags:
    - Linux
    - Docker
categories:
    - Docker
---

通常情况下，Linux可以通过tcpdump工具进行抓包。但是，在容器服务日趋盛行的今天，制品base镜像为减小体积，仅会包含必要的核心库和工具。给PaaS服务中容器的网络问题和定位，则需要通过名为 `nsenter` 的工具实现。
<!-- more -->


## nsenter简介
nsenter 包含在绝大部分 Linux 发行版预置的 `util-linux` 工具包中。它可以进入指定进程的关联命名空间。包括
- 文件命名空间（mount namespace）
- 主机名命名空间（UTS namespace)
- IPC 命名空间（IPC namespace）
- 网络命名空间（network namespace）
- 进程命名空间（pid namespace）
- 用户命名空间（user namespace）。

通过进入到指定的命名空间，即可实现在宿主机shell中直接操作指定容器的网络接口，并进行抓包等操作。


## 使用nsenter抓包
1. 获取容器Pid

```shell
docker inspect --format "{{.State.Pid}}" <container id/name>
```

2. 切换当前shell的网络命名空间为指定容器网络命名空间

```shell
# -n 表示切换网络命名空间，-t 指定的 pid 为步骤 1 获取的容器的 root pid：
nsenter -n -t <container root id>
```

3. 使用tcpdump对容器网络接口抓包

```shell
# -i指定网卡，示例为抓取80/tcp相关的包
tcpdump -i eth0 tcp and port 80 -vvv
```


更多的nsenter使用，可以参考 `man nsenter`查阅工具的使用指南。