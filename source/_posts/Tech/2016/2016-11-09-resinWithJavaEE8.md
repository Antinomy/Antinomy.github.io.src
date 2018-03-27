---
layout: mobile
title:  Resin 3 With JavaEE8
category: Tech
---

Resin 3 With JavaEE 8
=====================
![img](/img/2016/resin.png)

Resin 3 本身只支持JavaEE 6，要让它能允许JavaEE 8的应用是需要踩一些坑的。 ：）

# NoSuchMethodError: javax.persistence.Table.indexes()[Ljavax/persistence/Index

Resin 3 支持JavaEE 6的规范， 对应的JPA版本是JPA 2， 而Hibernate 4.3开始使用JPA 2.1。

运行时的会默认用resin/lib下的JPA 2，因为JPA 2的@Table不支持indexes属性，所以初始化Hibernate 4.3以上版本的时候会抛出javax.persistence.Table.indexes()错误。

*解决方案*

	简单粗暴的做法，就是禁止掉resin/lib/jpa-15.jar， 重命名成jpa-15.jar_bak之类，应用在运行的时候会用回Hibernate本身自带的JPA版本。



# Unsupported major.minor version 52.0
某些Resin 3的运行环境里会默认使用较低的JDK版本，比如Open JDK 7之类，所以运行JDK8编译过的类的时候会抛出Unsupported major.minor version。  
查看resin的启动脚本/bin/httpd.sh  

```bash

...

if test -n "${JAVA_HOME}"; then
  if test -z "${JAVA_EXE}"; then
    JAVA_EXE=$JAVA_HOME/bin/java
  fi
fi

if test -z "${JAVA_EXE}"; then
  JAVA_EXE=java
  fi
...

exec $JAVA_EXE  -jar ${RESIN_HOME}/lib/resin.jar $*
```

一般情况下设置${JAVA\_HOME} 的环境变量为JDK8就好，我遇到一个比较坑的情况是Jenkins远程调用的时候，${JAVA\_HOME}被变成了JDK7.

*解决方案*

	在启动脚本里指定指定${JAVA\_HOME}，并且export JAVA_HOME到环境变量 



# Ref
＊ http://stackoverflow.com/questions/20734540/nosuchmethoderror-in-javax-persistence-table-indexesljavax-persistence-index


