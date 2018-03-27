---
layout: mobile
title:  Java Concurrency
category: Tech
---

Java 并发
=====================
一谈起并发，就离开不了同步机制、线程安全。

# 同步机制
Java常用的同步机制有： volatile , synchronized

## volatile
用volatile修饰的变量就拥有2个特性： *可见性、禁止指令重排序优化。*

### 可见性
保证变量对所有线程的的可见性，普通变量无法做到这点，只能通过主内存来传递。  

<img src="/img/2016/JavaCurrentMem.png" width="400">

Java里的运算并非原子操作，导致volatile变量的运算在并发下也是不安全的。

从内存可见性的角度，读取volatile变量等于进入同步代码块，写入volatile等于推出同步代码块。
  
### 禁止指令重排序优化
指令重排序是指CPU允许多条指令不按程序规定的顺序分开发送给各相应电路单元处理。
volatile能保证处理器不发生乱序执行。

## synchronized
synchronized是最基本的互斥同步手段。

synchronized关键字经过编译之后，会在同步块前后形成monitorenter 和monitorexit 2个字节码指令。根据虚拟机规范，执行monitorenter会尝试加锁， 执行monitorexit会释放锁。

synchronized中的锁是非公平的，java.util.concurrent包下的ReentrantLock也有类似功能，但可以通过构造函数来实现公平锁。


##  volatile vs. synchronized

|-----------+------------|
|volatile   | synchronized |
|:---------|-------:|
|最轻量级   | 较重（悲观并发策略）|
|线程不安全 | 线程安全|
{: rules="groups"}


# 线程安全

	当多个线程访问一个对象时，如果不用考虑这些线程在运行时环境下的调度和交替执行，也不需要进行额外的同步，或者在调用方进行任何其它的协调操作，调用这个对象的行为都可以获得正确的结果，那这个对象是线程安全的。  

* 无状态对象一定是线程安全的。
* 不可变对象一定是线程安全的。

Immutable对象一定是线程安全的，final关键字可以保证它是不变的。

  java.util.concurrent包下的对象也都是线程安全的。

|线程安全 | 线程不安全|
|:---------|----------:|
|Vector、CopyOnWriteArrayList | ArrayList|
|HashTable、ConcurrentHashMap  | HashMap|
{: rules="groups"}




# 参考文献

* 《深入浅出Java虚拟机》  

![img](https://img3.doubanio.com/lpic/s27458236.jpg)


* 《Java并发编程实战》  

![img](https://img3.doubanio.com/lpic/s7663093.jpg)
