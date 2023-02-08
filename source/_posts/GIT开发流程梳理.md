---
title: GIT开发流程梳理
date: 2023-02-08 15:13:56
tags:
	- git
categories:
    - git
---

# 1. 目的

为了有效的帮助团队更简洁，更统一的管理好源码。

# 2. 分支说明

>  源码仓库的分支按照生命周期分为：

* 长期分支：`master`, `dev`

* 临时分支：`feature/*`, `release/*`, `hotfix/*`


> 源码仓库的分支按照用途又可分为：

* 发布/预发布分支：`master`，`release/*`

* 开发分支：`dev`

* 功能分支：`feature/*`

* 热修复分支：`hotfix/*`

## 分支用途

- `master`：作为发布分支，与生产环境保持一致。在生产环境上发现的问题，必须以 `master` 为基准创建 `hotfix/*` 分支来修复问题。
- `dev`：作为开发分支，所有最新的功能都在该分支下进行开发，`dev` 也是所有分支中功能最全，代码最新的一个分支。
- `feature/*`：命名规则`feature/功能_版本号_日期_开发人员`，作为新功能的开发分支，只能从 `dev` 创建，开发完毕并经过测试之后必须重新合并到 `dev`。命名示例  `feature/xxx_v2.4.0_0507_lanffy` 作为开发分支，xxx是分支具体包含的功能，v2.4.0固定，0507是分支创建日期，lanffy是创建人。
- `release/*`：命名规则`release/v+发布的版本号`，作为预发布分支，只能从 `dev` 创建。如果在预发布过程中发现了问题，在 `release/*` 分支上进行修改。同时，release/* 分支在每个迭代需要保留，作为后续ISV、定制开发的版本基线。
- `hotfix/*`：命名规则`hotfix/v+bug修复的版本号`，作为热修复分支，只能从 `master` 分离出来。仅用于修复在生产环境上发现的 bug，修复完成并测试通过后需要将该分支合并回 `dev` 及 `master` 上，并删除该分支。

## 分支保护

* 通用策略：`master`分支由管理角色Master负责管理，其他人员无权限修改。

# 3. 工作流程

## 3.1 功能开发

![image-20210712142153480](./GIT%E5%BC%80%E5%8F%91%E6%B5%81%E7%A8%8B%E6%A2%B3%E7%90%86/1.png)

### 标准流程

1. 建议每一个功能分支`feature/*`应与TAPD上的feature有明确的对应关系
2. 首先从`dev`拉取最新的分支，然后以最新的 dev 为基准创建新的功能分支，以`feature/f1`为例：

```bash
git pull origin dev
git checkout -b feature/f1 dev
```

3. 开发人员在各自的功能分支上进行开发自测工作。
4. 当前功能分支开发完之后，在代码仓库中提起MR（Merge Request），申请将feature合并回dev分支。
5. MR Code Reviewer代码审查通过后，合并代码，于界面勾选删除feature/f1分支。（如未勾选删除源分支，则手动删除特性分支）

```bash
git branch -d feature/f1
```

## 3.2 发布与预发布

![image-20210712155050843](./GIT%E5%BC%80%E5%8F%91%E6%B5%81%E7%A8%8B%E6%A2%B3%E7%90%86/2.png)

### 标准流程

提交到预发布和生产环境应遵循以下流程：

1. 从 dev 分支创建新的预发布分支 `release/v0.1.0`，并部署到预发布环境上测试。在预发布过程中发现问题则直接在 `release/v0.1.0` 上进行修复

```bash
git checkout -b release/v0.1.0 dev
```

2. 预发布分支 `release/v0.1.0` 在预发布环境中完全测试通过，可以部署到生产环境。但在部署到生产环境之前，需要将分支合并回 `dev` 及 `master`，并打一个正式发布版本的 tag v0.1.0，最后删除 `release/v0.1.0`

```bash
git checkout dev
git merge --no-ff release/v0.1.0
git checkout master
git merge --no-ff release/v0.1.0
git tag v0.1.0
git branch -d release/v0.1.0
```

3. **特别注意**：功能 f2 已经合并到`dev`，但此时已经存在新功能 f1 的预发布分支 `release/v0.1.0`，所以需要等待其发布完成之后才能创建预发布分支 `release/v0.2.0`

生产环境发现Bug，需要Hotfix时应遵循以下流程：

1. 从 master 上分离出一个热修复分支 `hotfix/v0.1.1`，在此分支修复

```bash
git checkout -b hotfix/v0.1.1 master
```

2. 验证通过之后，首先将分支重新合并回 `dev` 及 `master`，然后在 `master` 上打一个热修复 tag v0.1.1，最后删除 `hotfix/v0.1.1`

```bash
git checkout dev
git merge --no-ff hotfix/v0.1.1
git checkout master
git merge --no-ff hotfix/v0.1.1
git tag v0.1.1
git branch -d hotfix/v0.1.
```

# 4. 提交与合并
## 4.1 Git commit message

遵循 [Git 官方使用手册](http://git-scm.com/book/zh/v2/%E5%88%86%E5%B8%83%E5%BC%8F-Git-%E5%90%91%E4%B8%80%E4%B8%AA%E9%A1%B9%E7%9B%AE%E8%B4%A1%E7%8C%AE) 中给出的 commit 书写规范：

> 本次提交 commit 的摘要（50 个字符或更少）

> 如果必要的话，加入更详细的解释文字。在大概 72 个字符的时候换行。在某些情形下，第一行被当作一封电子邮件的标题，剩下的文本作为正文。分隔摘要与正文的空行是必须的（除非你完全省略正文）；如果你将两者混在一起，那么类似变基等工具无法正常工作。

> 空行接着更进一步的段落。

### 最佳实践

每次提交建议添加关键词前缀，用于指示本次改动的主题：

- feat: 新功能（feature）
- fix: 修补 bug
- docs: 文档（documentation）
- style: 格式（不影响代码运行的变动）
- refactor: 重构（即不是新增功能，也不是修改 bug 的代码变动）
- perf: 性能优化
- test: 增加测试
- build: 编译相关的修改（例如 webpack, npm, gulp 等）
- ci: CI 相关的修改（例如 Travis, Circle 等）
- chore: 构建过程或辅助工具的变动
- revert: 回滚上一次 commit

## 4.2 Merge Request (MR) 

- 建议在提交时需在标题中添加 `[MR]` 前缀用于邮件推送时区分 MR 和 ISSUE.
- 每个 MR 应该仅包含针对单一主题的一系列变更，不要在一个 MR 中包含多个主题。举例来说：假设你开发了 X 和 Y 两个不同主题的相关内容，若此时将所有 commit 以同一 MR 的形式进行提交，如若 Reviewer 仅认可与 X 相关的变更但不同意 Y 主题的相关变更——这将导致我们将无法对此 MR 进行合并操作。
- 每个 MR 提交人必须指定一名 Code Reviewer 进行代码审查，并由 Code Reviewer 进行合并。