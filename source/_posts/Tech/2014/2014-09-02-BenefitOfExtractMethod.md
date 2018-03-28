---
layout: mobile
title: Benefit of Extract Method
category: Tech
date: 2014-09-02
---

提炼方法的好处？
=====================

  在最近的一次Code Review里，我和同事在一个基本的问题上产生了分歧。三言两语很难说的清楚，我决定尝试把它写清楚。

  分歧的起因在于我把以下的这段代码：
- - -
```c++
// some method
memset( pData->field1 , ' ' ,sizeof(pData->field1));
memset( pData->field2 , ' ' ,sizeof(pData->field2));
memset( pData->field3 , ' ' ,sizeof(pData->field3));
memset( pData->field4 , ' ' ,sizeof(pData->field4));
memset( pData->field5 , ' ' ,sizeof(pData->field5));
memset( pData->field6 , ' ' ,sizeof(pData->field6));
...
```

  写成:

```c++

void Init_String(CHAR *str)
{
	memset(str ,' ',sizeof(str))
}
// some method
Init_String(pData->field1);
Init_String(pData->field2);
Init_String(pData->field3);
Init_String(pData->field4);
Init_String(pData->field5);
Init_String(pData->field6);
...
```
	
- - -	
##	同事对此有以下几点疑问:
	1. 有什么好处?
	2. 多了个方法，性能会变低。
	3. 与过去的风格不同，增加学习曲线。

- - -
## 动机
在回答所有的问题之前,我先说下我的动机,在原先的方法里
  
```c++
memset( pData->field1 , ' ' ,sizeof(pData->field1));
```
看来好简单的一句程序里，出现了2次"pData->field1"。
这里已经出现了重复的臭味道，随着这样的写法数量增多，这段代码就越来越臭了。
  
有代码洁癖的我是觉得难以忍受的。
  
根据DRY原则（Dont Repeat Yourself）,我把代码里不变的部分用Extract Method的手法重构到一个方法里。

方法名叫Init_String（），我简单的把一个内存的操作的工作封装到‘初始化字符串’的方法里。

下次我再看到这里我就只需要知道它能帮我初始化‘字符串’就行，而不需要分神去理会它是如何的实现。

然后，我再来一一解答所有问题：
- - -
## 有什么好处?
	1. 符合DRY原则 (一次且仅一次)
	   去除重复的代码,消除坏味道.
	2. 符合OCP原则 (开闭原则）
	   拆分不变与变化的代码，对于扩展是开放的，但是对于修改是封闭的.
	3. 更整洁的代码 (Clean Code)

- - -
## 多了个方法，性能会变低?
多了一个新方法,每次memset时就call 多次 Init_String（）.
看上去是会多耗点性能,但是新的method跟原来的代码是在同一个文件里的.
从内存的角度,其内存地址也应该相近,在数量有限的call里,我认为性能是人感受不出来的.
当然要更深入讨论,可以去了解C函数的调用机制.
	
- - -	
## 与过去的风格不同，增加学习曲线。
的确,这里是个问题。
例如100个文件里就1个文件是这种写法，风格不统一会对新人造成一点点阅读困难。
	
我们当然做不到一夜之间就改变所有文件，也没有这个必要。
这不应该成为阻止我们改进的绊脚石。
我一直认为改进应该是增量的，每一次随着需求变化可以适当在满足需求的同时，改善现有的代码。
	
重构是有成本的，但也是有回报的。我觉得值得投资。
	

- - -
## Extract Method
最后再啰嗦下什么是Extract Method （提炼函数）.

Extract Method （提炼函数）是最常用的重构手法之一。当看见一个过长的函数或者一段需要注释才能让人理解用途的代码，就应该将这段代码放进一个独立函数中。

简短而命名良好的函数的好处：首先，如果每个函数的粒度都很小，那么函数被复用的机会就更大；其次，这会使高层函数读起来就想一系列注释；再次，如果函数都是细粒度，那么函数的覆写也会更容易些。

[Further Read](http://msdn.microsoft.com/en-us/library/0s21cwxk.aspx)

- - -
# Reference
[memset](http://www.cplusplus.com/reference/cstring/memset/)

[一次且仅一次](http://zh.wikipedia.org/wiki/%E4%B8%80%E6%AC%A1%E4%B8%94%E4%BB%85%E4%B8%80%E6%AC%A1)

[开闭原则](http://zh.wikipedia.org/wiki/%E5%BC%80%E9%97%AD%E5%8E%9F%E5%88%99)

[代码重构](http://zh.wikipedia.org/wiki/%E4%BB%A3%E7%A0%81%E9%87%8D%E6%9E%84)

