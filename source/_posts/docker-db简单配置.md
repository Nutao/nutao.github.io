---
title: docker-db简单配置
date: 2021-09-07 15:56:21
tags:
    - Linux
    - Docker
categories:
    - Docker
---

一些docker快速启动服务的笔记
<!-- more -->

### 1. MongoDB 本地服务

#### 1.1 创建MongoDB容器实例

GUI 工具：**robo 3t**

```shell
# 创建卷
docker volume create mongo

# 启动mongo容器实例
docker run -p 27017:27017  --restart=always  --mount source=mongo,destination=/var/lib/mongodb --name mongo -d mongo --auth

# 登录container
docker exec -it mongo mongo admin
```

- 添加admin作为**用户管理用户**

```shell
# 创建用户
db.createUser({ user:'admin',pwd:'123456',roles:[{ role:'userAdminAnyDatabase', db: 'admin'}]});

# 登录用户
db.auth('admin','123456')
```

- 创建用户和自测用的collection

```shell
db.createUser({ user:'nutao',pwd:'123456',roles:[ { role:'dbOwner', db: 'nutao'}]});
db.auth('nutao','123456')
use nutao
db.nutao.insert({"test": "test"})

db.createUser({ user:'nutao2',pwd:'123456',roles:[{ role:'readWriteAnyDatabase', db: 'admin'},{ role:'dbAdmin', db: 'nutao'}]});
```

#### 1.2 MongoDB内置用户角色

  - 数据库用户角色：read、readWrite;
  - 数据库管理角色：dbAdmin、dbOwner、userAdmin；
  - 集群管理角色：clusterAdmin、clusterManager、clusterMonitor、hostManager；
  - 备份恢复角色：backup、restore；
  - 所有数据库角色：readAnyDatabase、readWriteAnyDatabase、userAdminAnyDatabase、dbAdminAnyDatabase
  - 超级用户角色：root  
  -  // 这里还有几个角色间接或直接提供了系统超级用户的访问（dbOwner 、userAdmin、userAdminAnyDatabase）
  - 内部角色：__system 



具体角色的功能： 

- Read：允许用户读取指定数据库
- readWrite：允许用户读写指定数据库
- dbAdmin：允许用户在指定数据库中执行管理函数，如索引创建、删除，查看统计或访问system.profile
- userAdmin：允许用户向system.users集合写入，可以找指定数据库里创建、删除和管理用户
- clusterAdmin：只在admin数据库中可用，赋予用户所有分片和复制集相关函数的管理权限。
- readAnyDatabase：只在admin数据库中可用，赋予用户所有数据库的读权限
- readWriteAnyDatabase：只在admin数据库中可用，赋予用户所有数据库的读写权限
- userAdminAnyDatabase：只在admin数据库中可用，赋予用户所有数据库的userAdmin权限
- dbAdminAnyDatabase：只在admin数据库中可用，赋予用户所有数据库的dbAdmin权限。
- root：只在admin数据库中可用。超级账号，超级权限



### 2. Redis本地服务

#### 2.1 创建容器实例

```shell
docker run -itd --name redis -p 6379:6379 -m 500m redis:latest --requirepass "123456" --tcp-keepalive 50
```

- 参数意思：

```
-d          后台运行容器，并返回容器ID
-i          以交互模式运行容器，通常与 -t 同时使用
-t          为容器重新分配一个伪输入终端，通常与 -i 同时使用
--name      指定容器名称为myredis
-p          指定容器端口
-m          指定容器内存使用限制
```

- 连接服务

```shell
docker exec -it redis redis-cli
127.0.0.1:6379> AUTH 123456
```

### 3. Mysql、mariadb本地服务

#### 3.1 创建容器实例

```shell
# 创建卷
docker volume create mariadb

# 启动服务
docker run -p 3306:3306  --restart=always  --mount source=mariadb,destination=/var/lib/mysql  --name mariadb -e MYSQL_ROOT_PASSWORD=123456 -d mariadb:latest


# 导出
mysqldump -uroot -pDo1cloudUserCenter123456 -h 10.22.0.49 -P 3306 usercenter_resource > usercenter_resource.sql

# 导入

```

### 4. swagger

```
docker run -p 20000:8080 -v /root/devops/docker-volume/swagger/swagger.json:/app/swagger.json --name swagger swagger:latest
```



### 5 rabbitMq

```
docker run -d --hostname my-rabbit --name rabbitmq -e RABBITMQ_DEFAULT_USER=admin -e RABBITMQ_DEFAULT_PASS=admin -p 15672:15672 -p 5672:5672 -p 25672:25672 -p 61613:61613 -p 1883:1883 rabbitmq:management
```

1. 15672：控制台端口号
2.  5672：应用访问端口号

### 6. postgresql

```sh
# 创建卷
docker volume create pgsql 

# 创建容器
docker run --name postgres -e POSTGRES_PASSWORD=123456 -p 5432:5432  --restart=always  --mount source=pgsql,destination=/var/lib/postgresql  -d postgres:latest

# 账号 postgres 123456
```

- 常用命令

```
除了前面已经用到的\password命令（设置密码）和\q命令（退出）以外，控制台还提供一系列其他命令。
\h：查看SQL命令的解释，比如\h select。
\?：查看psql命令列表。
\l：列出所有数据库。
\c [database_name]：连接其他数据库。
\d：列出当前数据库的所有表格。
\d [table_name]：列出某一张表格的结构。
\du：列出所有用户。
\e：打开文本编辑器。
\conninfo：列出当前数据库和连接的信息。
\x: 转换为列模式
```

- 查询表结构

```sql
SELECT 
	a.attnum  AS "id",
	c.relname AS "表名",
	CAST(obj_description(relfilenode, 'pg_class') as VARCHAR ) as "table desc",
	a.attname as "column name",
	concat_ws('', t.typname, SUBSTRING(format_type(a.atttypid, a.atttypmod) FROM '\(.*\)')) as "column type",
	d.description as "COLUMN comment"
FROM 
	pg_class as c, pg_attribute as a, pg_type as t, pg_description as d
WHERE c.relname = 'mfa_consul_order'
	AND a.attnum > 0
	AND a.attrelid = c.oid
	AND a.atttypid = t.oid
	AND d.objoid = a.attrelid
	AND d.objsubid = a.attnum
ORDER BY c.relname DESC, a.attnum ASC
```

- 查询db占用空间

```sql
select pg_database.datname, pg_size_pretty (pg_database_size(pg_database.datname)) AS size from pg_database; 
```



### 7.  Consul

- 创建单机consul

  ```shell
  docker run -d --name=consul-node1 -p 8500:8500 -e CONSUL_BIND_INTERFACE=eth0 consul:1.10
  ```

- 创建集群

  ```shell
  # 查看第一个节点的IP
  docker inspect -f='{{.NetworkSettings.IPAddress}}' consul-node1
  
  # 创建并启动第二个节点，172.17.0.3是第一个节点的IP
  docker run -d --name=consul-node2 -p 8501:8500 -e CONSUL_BIND_INTERFACE=eth0 consul:1.10 agent -dev -join=172.17.0.3
  
  # 创建并启动第三个节点，172.17.0.3是第一个节点的IP
  docker run -d --name=consul-node3 -p 8502:8500 -e CONSUL_BIND_INTERFACE=eth0 consul:1.10 agent -dev -join=172.17.0.3
  
  # 在第一个容器中运行consul命令来查询集群中的所有成员
  docker exec -t consul-node1 consul members
  ```

- 目录说明
  - /consul/data：Consul 存放数据的目录
  - /consul/config：Consul 存放配置文件的目录

### 8 Minio（块存储）

http://docs.minio.org.cn/docs/master/minio-erasure-code-quickstart-guide

- 单机单节点运行

```shell
docker run -p 9000:9000 --name minio1 \
  -e "MINIO_ACCESS_KEY=AKIAIOSFODNN7EXAMPLE" \
  -e "MINIO_SECRET_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY" \
  -v /mnt/data:/data \
  -v /mnt/config:/root/.minio \
  minio/minio server /data
```

- 以纠删码模式运行Minio (8个盘)

```shell
docker run -p 9000:9000 --name minio \
  -v /mnt/data1:/data1 \
  -v /mnt/data2:/data2 \
  -v /mnt/data3:/data3 \
  -v /mnt/data4:/data4 \
  -v /mnt/data5:/data5 \
  -v /mnt/data6:/data6 \
  -v /mnt/data7:/data7 \
  -v /mnt/data8:/data8 \
  minio/minio:latest server --console-address ":9999" /data1 /data2 /data3 /data4 /data5 /data6 /data7 /data8
```


