---
layout: mobile
title:  Java Memory Model
category: Tech
---

Java 内存模型
=====================
Java不像C＋＋由程序员直接管理内存，而是由虚拟机内存管理机制管理。

以JDK1.7为例子，内存模型如下：

# 内存模型
<img src="/img/2016/JMM.png" width="600">

* 程序计数器 （Program Counter Register）
* Java虚拟机栈 （Java Virtual Machine Stacks）
* 本地方法栈 （Native Method Stack）
* Java堆 （Java Heap）
* 方法区 （Method Area）
* 运行时常量池 （Runtime Constant Pool）
* 直接内存 （Direct Memory）


## 程序计数器 （Program Counter Register）

程序计数器是一块较小的线程私有的内存空间，用了记录正在执行的虚拟机字节码指令的地址。
通过改变这个计数器的值来选取下一条字节码指令，分支、循环、跳转、异常处理、线程恢复等功能都需要依靠它来实现。

执行Native方法的时候，其值为空（Undefined）。

此内存区域是虚拟机规范唯一没有规定任何OutOfMemoryError的区域。


## Java虚拟机栈 （Java Virtual Machine Stacks）
Java虚拟机栈也是线程私有的内存空间，它的生命周期和线程一样。

它是描述Java方法执行的内存模型：

	每个方法在执行的同时都会创建一个栈桢（Stack Frame），用于存储局部变量表、操作数栈、动态链接、方法出口等信息。

每个方法从调用到结束，就对应一个栈桢在虚拟机栈中入栈到出栈的过程。


## 本地方法栈 （Native Method Stack）

本地方法栈 （Native Method Stack）与Java虚拟机栈的作用非常相似，其区别是：

	虚拟机栈为Java方法服务，本地方法栈为虚拟机用到的Native方法服务。

## Java堆 （Java Heap）
Java堆是所有线程共享的内存区域，是最大的一块。

其唯一目的就是存放对象实例，也是GC管理的主要区域。

从内存回收的角度，还可以细分为： 新生代（Young Generation）和老年代（Old Generation）等。

![img](http://cdn1.infoqstatic.com/statics_s2_20160914-0333/resource/news/2016/09/APM-jClarity-jvm-heap-oldgen/zh/resources/2.png)

年轻代为创建的短期对象，失效之后很快会被垃圾回收。该区又被划分为Eden和两个Survivor区域。

老年代存放的多数为存活时间较长的对象。

垃圾回收GC分为两种Minor GC、Full GC；

Minor GC发生频繁，但是仅针对年轻代。

### Full GC 触发条件

* 调用System.gc()
* 老年代空间不足
* 永久代空间不足
* 空间分配担保失败
* Cocurrent mode failure


## 方法区 （Method Area）

方法区用于存储已被虚拟机加载的类信息、常量、静态变量、即时编译器编译后的代码等数据。

虽然和Java堆一样是各个线程共享的内存区域，却有一个别名 Non－Heap （非堆）

在HotSpot虚拟机上“方法区”被更多人称为“永久代” （Permanent Generation），但对其它虚拟机并不存在这样的概念。


<img src="/img/2016/Java7MM.png" width="800">

而且在JDK8里，永久代也被Metaspace所替代，位置也移到native memory里。

这样做的好处在于：简化GC的算法，full gc的时候更高效率。

<img src="/img/2016/Java8MM.png" width="800">

## 运行时常量池 （Runtime Constant Pool）

运行时常量池 是方法区的一部分，用于存储编译期生成的各种字面量和符号引用，在类加载后进入方法区的运行时常量池中。

## 直接内存 （Direct Memory）

直接内存不是虚拟机运行时数据区的一部分，也不是Java虚拟机规范中定义的内存区域。
它属于堆外内存，受到本机内存大小、寻址空间的限制。


# 参考文献

* 《深入浅出Java虚拟机》  

![img](https://img3.doubanio.com/lpic/s27458236.jpg)

* [JVM堆内存监测的一种方式，性能调优依旧任重道远](http://www.infoq.com/cn/news/2016/09/APM-jClarity-jvm-heap-oldgen)


