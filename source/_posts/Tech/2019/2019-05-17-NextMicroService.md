---
layout: mobile
title: 下一代的微服务
category: Tech
date: 2019-05-17
---


# 侵入式开发框架

人们对分布式架构的追求从未停止,从十几年前以SSH为首的单体架构,到现在以SpringCloud为主流的微服务架构.

SpringCloud为我们带来不少好处:
1. 服务发现（Eureka）
2. 智能路由（Zuul）
3. 客户端负载均衡（Ribbon）
4. ......

![img](/img/2019/istio1.jpg)

在为我们带来不少微服务架构的福利的同时,也带来了不少的挑战.

SpringCloud和Dubbo一样,都属于传统基于SDK的侵入式开发框架.

如果从零开始的项目,使用SpringCloud会很舒服.但是如果你的业务正跑着一个历史悠久的SSH架构上,侵入式开发框架带来了改造的复杂性.

笔者经历过这样的项目,一个跑在Struts2的金融项目,每天都有几千万左右的交易量,同时还在不断迭代新功能.把它慢慢拆分,迁移到SpringCloud架构,花了差不多2年的时间.

    人生又有多少个2年呢?

运气不好遇到非Java技术栈的项目,改造的成本就更让人难以接受了!

直到我听说了Service Mesh,事情才有了新的方向...

# 非侵入式开发框架

    直到 2017 年年底，当非侵入式的 Service Mesh 技术终于从萌芽到走向了成熟，当 Istio/Linkerd 横空出世，
    人们才惊觉：微服务并非只有侵入式一种玩法，更不是 Spring Cloud 的独角戏！


![img](/img/2019/istio2.png)

Service Mesh架构通过SideCar模式来实现非侵入式,就好比给一个传统的摩托车加入一个边车,不影响摩托车原有的内部构造前提下,增加新的功能.

![img](/img/2019/istio4.png)

原来的业务继续跑在单独的进程里,与微服务相关的功能(服务治理,流量控制,熔断等)放到SideCar里并注入到同一个的系统/容器里.

Service Mesh中分为控制平面和数据平面.以istio架构为例,

![img](/img/2019/istio5.jpg)


# 跨语言技术栈

业务服务与SideCar的通讯可以通过HTTP、gRPC、WebSocket 和 TCP等通用方式,因此也带来不同语言技术栈,可以联合起来组成一个服务网格的可能性.

如下图的官方实例,3个语言技术栈可以组合起来,实现了在线书店的功能.

![img](/img/2019/istio3.png)

# 难点与挑战
新的技术带来机遇的同时,总会带来新的挑战

1. Istio与K8s更搭,所以容器化是一个很重要的前提,改造成本也是有的.

2. Istio目前性能不是特别理想,而且处于高速发展阶段,坑还是有的.

3. 新的技术适合小范围使用,等待成熟再大规模推广.


# 参考文献:
================

[解读 2017 之 Service Mesh：群雄逐鹿烽烟起](https://www.infoq.cn/article/2017-service-mesh)

[istio.io示例](https://istio.io/zh/docs/examples/bookinfo/)

[Sidecar 模式](http://www.servicemesher.com/istio-handbook/concepts-and-principle/sidecar-pattern.html)

