---
layout: mobile
title:  Spring MVC
category: Tech
---

Spring MVC
=====================
MVC模型有很多种实现，Spring MVC是其中较经典的一种。


# Spring MVC is a Servlet

本质上，Spring MVC是一个Servlet，它需要一个Servlet容器（Tomcat、WAS等）。

<img src="/img/2016/SpringMVC-Servlet.png" width="800">

它提供了3个层次的Servlet：

* HttpServletBean
  直接继承Java的HttpServlet，将Servlet中配置的参数设置到对应的属性中。

* FrameworkServlet
  初始化了WebApplication－Context和对应的组件。

* DispatherServlet
  Spring MVC最核心的类，入口方法是doService，但具体的处理在doDispath里实现，
  doService在调用doDispatch的前后做了相应的请求处理。


## doDispatch  

doDispatch的主要任务有4个：

1. 根据request找到Hanlder
2. 根据Handler找到对应的HanlderAdapter
3. 用HanlderAdapter处理Handler
4. 调用processDispathResult方法处理结果，并找到View渲染给用户。

# A Http Request life cycle

一个Http请求到MVC的处理的主要步骤如下图：

<img src="/img/2016/SpringMVC-Dispatch.png" width="800">


# 参考文献

* 《看透Spring MVC》  

![img](https://img1.doubanio.com/lpic/s28824099.jpg)
