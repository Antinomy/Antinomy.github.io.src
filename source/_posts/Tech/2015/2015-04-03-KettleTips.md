---
layout: mobile
title: Kettle Tips
category: Tech
---

Kettle Tips
=====================
![img](/img/2015/kettle.png)

Kettle作为一个开源的ETL工具，功能也算挺齐全的，当然坑也不会少。：）  
so A生也小小的分享一下遇到的其中一些坑。



# 解决中文乱码问题

DB 链接处设置：

![img](/img/2015/KettleTips1.png)

	characterEncoding=utf8;
	characterSetResults=utf8;
	useUnicode=true
	
	去掉简易设置的选项：
	
![img](/img/2015/KettleTips2.png)	


# 更新修改过的表结构

清除DB的缓存

![img](/img/2015/KettleTips3.png)

# 使用变量

变量名字不能与Job/Trans命令参数同名，否则变量读取会失效。

	变量引用格式 ：	${param}

# 去掉自动增加的小数点

输入输出字段定义格式

![img](/img/2015/KettleTips4.png)

# Kettel 系统配置文件
在第一次运行kettle之后，kettle会在%HOME_USER_FOLDER%菜单里面创建一个 .kettle文件夹，  

windows  *C:\Documents and Settings\${your user name}\.kettle\kettle.properties*  
linux */home/${your user name }/.kettle/kettle.properties*  


# 命令行运行Job/Trans

*Job*
./kitchen.sh -file=? -debug=debug -log=log.log  
*Trans*
./pen.sh -file=? -debug=debug -log=log.log  


