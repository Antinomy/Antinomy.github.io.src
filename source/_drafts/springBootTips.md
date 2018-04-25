---
layout: mobile
title:  Spring Boot Tips
category: Tech
---

Spring Boot Tips
=====================

# img
![img](/img/2015/0629-XP.png)

# contorl img size
<img src="/img/2016/AgileTest1.png" width="800">

# JPA

## 骆驼式列名映射
JPA默认的列命名策略： org.hibernate.cfg.ImprovedNamingStrategy  
会自动把骆驼式*CamelCase*变成蛇式*SNAKE_CASE*列名映射，如果数据库命名不规范，会导致映射不到的错误 。
不想改命名策略的时候，用@Column(name="testname")就好，注意列名必须是*全部小写*。

## 物理列名映射
做服务拆分的时候,需要建立新的服务,同时跟旧服务使用同一个数据库,这个时候需要让JPA实体列名与物理表列名完全一致.
这个时候需要在配置文件里添加:

    spring.jpa.hibernate.naming.physical-strategy=org.hibernate.boot.model.naming.PhysicalNamingStrategyStandardImpl










# Ref
＊ http://stackoverflow.com/questions/25283198/spring-boot-jpa-column-name-annotation-ignored


