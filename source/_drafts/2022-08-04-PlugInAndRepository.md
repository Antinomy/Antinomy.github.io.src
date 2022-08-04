---
layout: mobile
title:  PlugIn And Repository
category: Dao
date: 2022-08-04
---

插件式架构与仓储模式
=====================

# 插件式架构
![plugin](/img/2022/plugin_arch.png)


Uncle Blob 在《Clean Architecture》提到了一种叫插件式架构的架构模式。
具体实现就是把数据库和GUI这2个层当做插件， 系统的核心就是业务逻辑层。
既然是插件就是代表可以切换别的插件，比如数据库可以是mysql，Oracle， 也可以是NoSQL，甚至是文件系统。GUI可以是VUE实现，也可以是react实现。

# 仓储模式
将业务逻辑与数据存储隔离的做法，和DDD里的仓储模式（Repository）不谋而合。 

![repo](/img/2022/ddd-repo.png)

# 真正的单元测试
业务逻辑不依赖具体实现的好处就是可以独立测试，这是单元测试实现的最理想的方式了，如果你的测试需要一个正在的运行的数据库，或者一个支持控制逻辑运行的web容器，那这绝对是一个假的单元测试， 通常我们叫这种测试为集成测试，而且它通常是不稳定，且易碎的。

