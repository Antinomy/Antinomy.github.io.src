---
layout: mobile
title:  JVM Class Loader
category: Tech
---

浅谈类加载机制
=====================
本文以JDK1.7为例子，简单地介绍一下类加载的原理。

# 类生命周期

说起类加载，就不得不先谈一下类的生命周期。
主要有以下7个阶段：

* 加载（Loading）
* 连接 （Linking）
    * 验证 （Verification）
    * 准备 （Preparation）
    * 解析 （Resolution）
* 初始化 （Initialization）
* 使用 （Using）
* 卸载 （Unloading）

<img src="/img/2016/Jvm-ClassLife.png" width="800">  

验证、准备、解析3部分统称连接。  

## 加载
在加载阶段，虚拟机需要完成以下3件事情：  

* 通过一个类的全限定名来获取定义此类的二进制字节流。
* 将这个字节流所代表的静态存储结构转化为方法区的运行时数据结构。
* 在内存中生成一个代表这个类的java.lang.Class对象，作为方法区这个类的各种数据的访问接口。

## 初始化时机
虚拟机规范严格规定 *有且只有* 5种情况必须立即对类进行初始化：  

* 使用关键字new实例化一个对象、读取或设置静态字段的时候  
* 使用java.lang.reflect包进行反射调用的时候
* 初始化一个子类的时候，如果其父类为初始化，需要先触发。
* 虚拟机启动，用户指定的一个包含main（）方法的执行主类的时候。
* 使用动态语言，一个java.lang.invoke.MethodHandle实例，
  最后解析结果"REF_getStatic, REF_putStatic,REF_invokeStatic"句柄所对应的未进行过初始化的类。


# 类加载器

类加载器的主要作用：就是实现“通过一个类的全限定名来获取定义此类的二进制字节流” 这个动作的。


类加载器主要有3种：

* 启动类加载器 （Bootstrap ClassLoader）:  C＋＋实现，负责加载<JAVA_HOME>\lib目录下（或-Xbootclasspath指定路径）的类库。
无法被Java程序直接引用。

* 扩张类加载器 （Extension ClassLoader）:  sun.misc.Launcher$ExtClassLoader实现，负责加载<JAVA_HOME>\lib\ext目录下(或java.ext.dirs指定路径)的类库。
开发者可以直接使用。

* 应用程序类加载器（Application ClassLoader）: sun.misc.Launcher$ClassLoader实现，负责加载用户类路径（ClassPath）下的类库。
开发者可以直接使用。

## 双亲委托模型 （Parents Delegation Model）

<img src="/img/2016/Jvm-ClassLoader.png" width="800">  

除了顶层启动类加载器之外，其余的类加载器都有自己的父类加载器，他们的父子关系一般不会以继承（Inheritance）的关系来实现，而是通过组合（Composition）关系来复用。  


双亲委托模型的原理是：

* 当收到类加载请求，不会自己去加载，而是委托给父类加载器。
* 每一层都一样，最终都到达顶层的启动类加载器中。
* 只有父加载器无法加载，子加载器才会尝试自己加载。

好处：  

	Java类有顶级优先级，保证了Java程序的稳定运作。
	（例如rt.jar里的java.lang.Object,无论哪一个类加载器加载，最终都会委派给启动类加载器加载）


双亲委托模型并不是强制性的约束模型，某些情况下也有例外：

* JDK1.2之后才引入“双亲委托” ，向前兼容JDK1.0的用户自定义ClassLoader。
* 涉及SPI的加载方式： JNDI、JDBC、JCE、JAXB、JBI等。
* OSGi环境下，类加载器不再是双亲委托模型的树状结构，而是更加复杂的网状结构。


# 参考文献

* 《深入浅出Java虚拟机》  

![img](https://img3.doubanio.com/lpic/s27458236.jpg)
