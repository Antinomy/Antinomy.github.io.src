---
layout: mobile
title:  IntelliJ Tips
category: Tech
---

IntelliJ Tips
=====================
![img](/img/2015/IntelliJTips1.png)

从RAD切换到IntelliJ已有一段时间，学习曲线总的来说，还不是很高。  
直到我从windows换到Mac系统，一些奇怪到问题也出现了。  

# 忽然失效的SpringUnitTest
对我这种不写测试就写不了代码的码农来说，没什么比测试用例突然运行不了更打击人的了。  
万万没想到，切换到高大上到mbp之后，IntelliJ的SpringUnitTest就跑不起来了。  

看了一下日志，原因是*SpringJUnit4ClassRunner*无法读取配置文件的路径。  
在win系统下Eclipse和IntelliJ工作的正常的代码如下：  

```java
@RunWith(SpringJUnit4ClassRunner.class)
@ActiveProfiles("test")
@ContextConfiguration(locations = {"classpath:applicationContext*.xml"})
public class Test {
...
}
```

经过一系列的排查和祈祷（囧），问题出在mac版的IntelliJ无法通过 通配符 ＊ 去载入所有的配置文件。  
修改如下：  

```java
@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(locations = {
        "classpath:applicationContext.xml",
        "classpath:applicationContext-IoC.xml",
        "classpath:applicationContext-persistence.xml"})
@ActiveProfiles("test")
public class Test {
...
}
```

问题是解决了，具体的因果要深入到IDE的内部工作原理才行了。  
我最近学会了一件事，不要凡事都非要求个因果。 ：）   

## ps： 最终还是完美解决了这个问题：

```java
@RunWith(SpringJUnit4ClassRunner.class)
@ActiveProfiles("test")
@ContextConfiguration(locations = {"classpath*:applicationContext*.xml"})
public class Test {
...
}
```

*classpath* 后面必须加多个*， 在
[Spring 文档](http://docs.spring.io/spring/docs/4.0.1.RELEASE/spring-framework-reference/htmlsingle/#resources-wildcards-in-path-other-stuff)有提到，不过win平台没有这个问题。。

Other notes relating to wildcards

Please note that " classpath*:" when combined with Ant-style patterns will only work reliably with at least one root directory before the pattern starts, unless the actual target files reside in the file system. This means that a pattern like " classpath*:*.xml" will not retrieve files from the root of jar files but rather only from the root of expanded directories. This originates from a limitation in the JDK’s ClassLoader.getResources() method which only returns file system locations for a passed-in empty string (indicating potential roots to search).

Ant-style patterns with " classpath:" resources are not guaranteed to find matching resources if the root package to search is available in multiple class path locations. This is because a resource such as

com/mycompany/package1/service-context.xml
may be in only one location, but when a path such as

classpath:com/mycompany/**/service-context.xml
is used to try to resolve it, the resolver will work off the (first) URL returned by getResource("com/mycompany");. If this base package node exists in multiple classloader locations, the actual end resource may not be underneath. Therefore, preferably, use " classpath*:" with the same Ant-style pattern in such a case, which will search all class path locations that contain the root package.
