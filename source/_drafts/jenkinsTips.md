---
layout: mobile
title:  jenkins tips
category: Tech
---

Jenkins插件小贴士
=====================

![img](/img/2020/Jenkins-1.png)

Jenkins是CI/CD最常见的一个工具,通过丰富的插件,可以实现很多实用的功能.
本文以Java Web的应用一键部署为例, 简单介绍常用的插件.

# CI的流程
持续集成的常见的流程如下:
1. 代码拉取
2. 代码自动化构建
3. 发布构建后的包到目标服务器
4. 在目标服务器执行发布流程

# 代码拉取
首先的插件是Jenkins默认自动的Git插件,所以你的代码仓库建议是Git,而不是CVS之类的老旧代码管理工具.
Git在分支管理要比CVS先进很多,具体差别请自行google.

# Git plug-in tips
![img](/img/2020/Jenkins-2.png)

1. Repository URL 配置代码的Git地址
2. Credentials 配置Git账号,推荐创建团队账号,避免因为个人账号问题导致拉取失败.
3. Branch Specifier 配置对应的分支或标签.

> 通过适当的分支管理,可以区分生产,测试,开发环境.
项目结构需做到支持多环境配置,能做到一个包可以发布到任何环境是实现CI的主要条件.
通过合理的使用标签,可以很方便做到应用的发布与回滚,
每次生产发布完成就在分支上打上tag,下次生产发布如果遇到问题就可以很方便利用tag回滚.


#  代码自动化构建
![img](/img/2020/Jenkins-3.png)

Java应用最普遍的构建工具就是maven了,Jenkins也是首先maven插件来完成自动化构建
maven插件配置也很简单, Goals里写的都是maven本身的命令.
例如: clean清除旧包,package重新打包,-DskipTests可以跳过集成的测试(不推荐 :))

# 发布构建后的包到目标服务器 & 在目标服务器执行发布流程

通过Maven构建的war包,jar包一般是通过ssh发布对应的liunx服务器上去.
每一个应用都有其特殊的发布脚本,这些脚本需要有一定的运维能力去编写.

常用的插件有	"Publish Over SSH" 可以很方便地实现.
![img](/img/2020/Jenkins-4.png)

以常见的tomcat为例,一般会在对应的服务器上创建几个文件夹和编写几个shell脚本.

SSH Server Name: 对应的Linux服务器名,具体ip和账号都在Jenkins的管理后台配置
Source files : 为Jenkins本地workspace的的文件,按照maven的结构,构建好的二进制包位于target目录之下.
Remove prefix : 去掉本地路径前缀
Remote directory : 对应目标服务器的相对路径,其实目录是配置好的账号默认登陆目录.
Exec command :当二进制包发送完毕之后需要之下的命令,部署的具体步骤在这里执行.

部署的步骤包括:
1. 停掉tomcat
2. 备份当前的二进制包
3. 更新最新的二进制包
4. 启动tomcat


至此一个部署流程就完毕了,部署的脚本因具体应用而异,如有中间件,需要在脚本做对应控制.

# 通过定时任务完成CI

![img](/img/2020/Jenkins-5.png)

通过定时任务和团队约定,可以在每一天的约定时间定时进行构建,便可完成日常的CI.
定时的规则参考Linux的cronjob.



