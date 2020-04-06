---
title: Mongodb ReplicatSet 认证（KeyFile）
date: 2017-07-27 18:32:20
tags:
    - Ubuntu
    - Linux
    - MongoDB
categories:
    - MongoDB
---

MongoDB 是由C++语言编写的，是一个基于分布式文件存储的开源数据库系统。在高负载的情况下，添加更多的节点，可以保证服务器性能。MongoDB的安全设置（**特别是集群安全**）一直是比较恼人的。那今天这篇文章就是来和大家聊聊使用Key File的ReplicatSet + User Role认证。

<!-- more -->

## 1. 下载MongoDB并创建数据文件夹

MongoDB的下载可以直接通过镜像源或者是去官网下载安装包的方式，这里就不再赘述了。默认大家都会下载和安装。

```bash
# 配置文件夹
mkdir conf
# 日志文件夹
mkdir log
# 日志文件
touch log/1.log
# 认证文件夹
mkdir key
```

## 2. 生成KeyFIle

> 随机生成keyFile或者手动写入,key的长度必须是6-1024的base64字符，unix下必须相同组权限

```bash
cd key
openssl rand -base64 600 > mongodb.key
```
- 查看内容

```bash
xV7Ilo4O3+GHb57LECdoQwJ2u5DrcUsgHhzfXRrvvRVsnDaGNpp3qOvlTm1p3PjC
L8gkVAV2vG/L8yG+HdBYgbZ/cEW49tlj/CSuK7wd4g/E40jk3uJPb8nMyXsZk4W1
6TAL/5Teq5mY4VqAnuY1JqfPwgIyOYMn9ZCs5Wv/htnYR2n14hiw4bXe2ADaiD42
kn7QhbuXxQBHxx3Yb/KTlEBqAm0aOAAueSbDvDwcnrsxoEcMnWq9gAhxzNmh9nv7
E3b7JqKn/jo+ZIrfAropvbz7JqcPIUp0yfDsrolIlvRn965Z/+3ZJMQgU/QrLNjY
wNcj7SqMXoXikTCalLycIbSWymX9dCMjOJ259k/ieU3LlGtLvWmozFlsG/Yu50w+
kQ3uIH1Rq8KH1Gg35dtjr8sbObD/W4KEelwdTm3WqJIRZVVu6CYkDjBeSpXPSnrx
C+DnN4U7PEZ8O07MRDps/oXcK2dXv1FmaoeTnQ7BzLITc0FSAa8oT4llBN2rXzQn
XXdlLoZ8H71Z0+OeD1/h9qGIYfB3bKWzeoPY2cd3b37lQe9a5UVPX+1GEyiut5kv
LgF3dgJ99/VmSvzBCdgwiMOu0eNxBvedqFnchMtqth85WJRMIcS5p2Pa8z7Wkjav
8wUdPDf4udv7b4x8cgEdv4kNB/PPtHTUTsP51Y0Zlds=
```
- 修改key的权限

```bash
# 这里的权限一定要比 600(rw) 低, 否则会报 Permission 太高的错误(在log中)
chmod 600 mongodb.key
# 查看权限
ls -l
```

```bash
-rw------- 1 root root 1085 Jul 26 16:03 mongodb.key
```
**`将 keyFile 分发到每一个节点（如果是物理机）`**
## 3. 配置文件

> 模板 mongod.conf

```yaml
# for documentation of all options, see:
#   http://docs.mongodb.org/manual/reference/configuration-options/

# Where and how to store data.
storage:
  dbPath: /db/mongodb3/data
  journal:
    enabled: true
  directoryPerDB: true
#  engine:
#  mmapv1:
#  wiredTiger:

# where to write logging data.
systemLog:
  destination: file
  logAppend: true
  path: /db/mongodb3/log/1.log

# network interfaces
net:
  port: 28017
 # bindIp: 127.0.0.1

processManagement:
  fork: true

# 指定keyFile后会自动开启auth
security:
  keyFile: /db/mongodb3/key/key
#operationProfiling:

replication:
  replSetName: DBTEST
  oplogSizeMB: 20480

#sharding:
## Enterprise-Only Options:
#auditLog:
#snmp:
```

**`注意:`**
- 所有的机器节点都要在防火墙上**开启 mongodb 需要的端口**
- keyFile的路径, 以及各种参数的**`大小写`**
- 分片集或者复制集的**`每一个节点`**(物理或者虚拟)都要分开配置配置文件以及keyFile

## 3. 启动
**`在每一个节点执行`**

```bash
# 配置文件名自定（可以使用conf，yaml）
mongod -f mongod.conf
```

```bash
about to fork child process, waiting until server is ready for connections.
forked process: 9221
child process started successfully, parent exiting
```
## 4. 配置复制集

> 连接Mongo [**`任意一个节点`**]

```bash
mongo --port 28017
```

> 配置:

```bash
# 最好是一次性初始化
rs.initiate({_id:"cisdi",members:[
{_id:0,host:"x.x.x.x:28017",priority:5},
{_id:1,host:"x.x.x.x:28017",priority:10},
{_id:2,host:"x.x.x.x:28018",arbiterOnly:true}
]})
```

或者用

```powershell
# 添加rs节点
rs.add("xxxx:port")
# 添加rs仲裁节点
rs.addArb("xxxx:port")
# 删除rs节点
rs.remove("xxxx:port")
```

> 创建用户:

**`Notice：`**
- 你创建的第一个用户后，本地实例登陆失效，必须进行验证。
- 第一个用户**必须创建其他用户的权限**，如<kbd>**`userAdminAnyDatabase`**</kbd>,<kbd>**`root`**</kbd>权限用户
- 如果至少有一个用户没有创建用户的权限，一旦本地异常关闭你可能无法创建或修改新的特权用户

> 创建命令：


```
db.createUser(
{
	user:"root",
	pwd:"123456",
	roles:[{role:"root",db:"admin"}]
});
```

> 用户权限


```bash
# 全局超级管理员
{role:"root",db:"admin"}
# userAdminAnyDatabase 任何一个数据库的Admin用户
{ role: "userAdminAnyDatabase", db: "admin" }
# clusterAdmin角色授予对复制操作的访问权限，例如配置副本集。
{ "role" : "clusterAdmin", "db" : "admin" }
```

数据库 Role:
- **dbAdmin**
- **dbOwner**
数据库所有者可以对数据库执行任何管理操作。这个角色组合由授予的权限readWrite， dbAdmin和userAdmin角色
- **userAdmin**
提供在当前数据库上创建和修改角色和用户的功能。该角色还间接地提供 对数据库的超级用户访问，或者如果作用于admin数据库的集群。该userAdmin角色允许用户授予任何用户任何特权，包括自己。
- **read**
对当前数据库的读操作
- **readWrite**
对当前数据库的读&写操作

全局 Role：
- readAnyDatabase （全局任何数据库读）
- readWriteAnyDatabase
- userAdminAnyDatabase （全局用户管理）
- dbAdminAnyDatabase（全局数据库管理）

集群 Role：
- **clusterAdmin**
提供最大的集群管理访问。这个角色组合由授予的权限clusterManager， clusterMonitor和hostManager角色
- **clusterManager**
在集群上提供管理和监控动作。具有该角色的用户可以访问config和local数据库，其在分片和复制所使用的
- **clusterMonitor**
提供对监控工具（如MongoDB Cloud Manager和Ops Manager监控代理）的只读访问 。
- **hostManager**
提供监控和管理服务器的能力。

### 设置从库可读

```bash
rs.slaveOk()
```

> 设置读写方式

```bash
#Primary               #从主的读，默认
#primaryPreferred      #基本上从主的读，主不可用时，从从的读
#secondary             #从从的读
#secondaryPreferred    #基本上从从的读，从不可用时，从主的读
#nearest               #从网络延迟最小的读
db.getMongo().setReadPref('secondaryPreferred')
```

### 关闭服务

> 使用db admin关闭

```bash
# 1. 登陆mongo
# 2. 使用admin
use admin
# 3. 关闭mongodb服务
db.shutdownServer();
```

> 通过mongod关闭

```bash
mongod --shutdown --dbpath path
```

> 通过PID关闭

```bash
# 找到mongodb.pid
kill -2 mongodb.pid
```
