---
title: git submodule入坑指南
date: 2020-11-25 14:37:47
tags:
	- git
categories:
    - git
---

在工程管理实践中，Git submodule可以将多个git仓库以模块的形式集中于主库，方便及时跟进各个库的更改。下面以我的博客为例。

<!-- more -->

# 1. 添加gitsubmodule
为了方便对hexo主题的管理和及时更新，我需要引入gitsubmodule对hexo-theme-next主题进行管理。

```shell
# 添加gitsubmodule
git submodule add https://gitee.com/nutao/hexo-theme-next.git themes/next 
```

上述命令会在目录`themes/next `中clone hexo-theme-next.git。并且，会在当前目录中生成文件`.gitsubmodule`.

```ini
[submodule "themes/next"]
  path = themes/next
  url = https://gitee.com/nutao/hexo-theme-next.git
  branch = master
```

# 2. 更新gitsubmodule

对配置文件`.gitsubmodule`手动更改（比如branch）后，需要对配置的更改刷新到 `.git/config`.

```shell
git submodule sync
```

当然，git submodule有命令可以做相关的配置更改，但是改配置文件更快捷。

# 3. 删除gitsubmodule

> 第一步：删除`.git/config`中对submodule的配置

- 正常情况下(**推荐**)

```
git submodule deinit themes/next
```

- 异常情况下

  直接更改文件`.git/config`中对submodule的配置

> 第二步：清除git缓存

```
git rm --cached themes/next
```

> 第三步：删除`.gitsubmodule`中对该submodule的配置



# 4. submodule初始化

从仓库拉取到项目后，submodule相关的目录一般是空的，如果需要拉取应先执行如下命令：

```shell
git submodule update --init --remote
```

# 5. 其他命令

- 对子模块批量执行某项git操作

  ```shell
  git submodule foreach <command>
  
  # example
  git submodule foreach git checkout master
  ```

- 如果存在嵌套的子模块，应加上 `--revursive` 参数

  ```shell
  git submodule update --init --recursive
  git submodule sync --recursive
  ```

  



