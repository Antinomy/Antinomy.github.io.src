---
layout: mobile
title:  Test Assert Mock 
category: Art
date: 2015-05-27
---

测试 断言 模拟 
=====================
![img](/img/2015/test-kind.png)

# Test
在很多人眼里，测试是一类东西：交给测试人员做的事情。  
其实，测试有很多不同的种类（详见上图），不同的测试应用场景也不同。  

跟开发者密切相关的测试有：  
+ 提交测试  
+ 单元测试  
+ 组件测试  
+ 集成测试  

## *测试是有成本的。*  
编写要成本，运行要成本，维护更需要成本！  

成本最小的应该是提交测试，顾名思义，提交测试就是提交代码之前必须要运行的测试。   
如果每次提交都要等个半个小时，那么估计很少人愿意频繁提交代码了。 ：）  
提交测试的内容应该是单元测试里面比较重要的部分。  

## *单元测试，必须要快！*  
如何做到唯快不破？ 答案很简单：  
+ No IO  
+ No DB  
+ No Network  

业务代码不应该依赖：文件IO操作、DB读写，以及网络层面的外部调用。  
所以好的设计很重要，把业务代码和IO／DB／Network 分离出来，对设计人员要求是有的。  
DDD（领域驱动开发）在这方面做了很好的研究，例如Repository模式就很好的隔离业务和DB／IO之间的耦合。  

## *DB／IO ／Network 并不是不重要*
关于它们的测试放在组件测试和集成测试的范畴,而这2个测试成本也越高。  
DB和IO操作放在组件测试里去做，RPC之类的远程调用则放在集成测试里。  

# Assert
## System.Out.print()
在Java的世界里，最简陋的测试莫过于System.Out.print()啦。

假如我们有一个方法，我们期待它能返回数字5.

```java
int anNum = getSomeNum5();
```

如果采用print的方法，那么我们就直接的写下，

```java
 System.Out.print(anNum);
```
然后我们在控制台里看print出的数字，看看是不是5.
这样做的缺陷是，必须得人肉验证，你得盯着结果看。  

## Junit
如果你有用过Junit，那么我们就可以使用更高级点的断言了。


```java
/**
 * Created by Antinomy on 15/5/27.
 */
public class SampleTest {

    @Test
    public void test()
    {
        int anNum = getSomeNum5();
        assertEquals(5,anNum);
    }

    private int getSomeNum5() {
        return 0;
    }
}
```
然后，我们就可以愉快的运行测试了，很多IDE都会把结果用绿色和红色显示出来。  

![img](/img/2015/test-sample.png)

assertEquals(5,anNum)的意思期待的返回的值是5，实际返回的是getSomeNum5()的结果。  
我们修改一下getSomeNum5()的“bug”，测试就通过了。  

![img](/img/2015/test-sample-2.png)

## Hamcrest
那么测试通过了，我们就完事了么？  
按照TDD的三部曲，红（失败），绿（通过），重构。  
接下来要做的是重构。为什么要重构？ 因为我们是有追求的人。 ：）  

好吧，如果你也是一个有追求的人，那么让我们来重构吧。  
assertEquals这个关键字有一些生硬的感觉，代码可读性上一般般。  
这个时候，我们该祭出神器[Hamcrest](http://hamcrest.org/JavaHamcrest/javadoc/1.3/)了。
> Hamcrest is a library of matchers, which can be combined in to create flexible expressions of intent in tests.

采用Hamcrest重构过的代码如下：

```java
import org.junit.Test;

import static junit.framework.TestCase.assertEquals;
import static org.hamcrest.core.Is.is;
import static org.junit.Assert.assertThat;

/**
 * Created by Antinomy on 15/5/27.
 */
public class SampleTest {

    @Test
    public void test()
    {
        int anNum = getSomeNum5();
        assertThat(anNum, is(5));
    }

    private int getSomeNum5() {
        return 5;
    }
}
```

assertThat(anNum, is(5)); 假设anNum is 5， 可读性层面立马上去了。  
重构完，如何保证之前的修改不容易扯到蛋？  
当然是之前写的测试啦，用了成本的投资必须要有回报，所以重新跑一下之前的测试就知道重构的质量如何了。  

![img](/img/2015/test-sample-3.png)

# Mock
以上的例子，只是一个很理想的例子。  
生活中总有许多不如意的事情，比如，如果getSomeNum5()方法不是本地实现的，而是来自于某个神秘的国度。  
你甚至不知道它是用什么语言实现的，那么测试的难度也提高了很多。  

如下：

```java

/**
 * Created by Antinomy on 15/5/27.
 */
public class SampleTest {

    @Test
    public void test() {
        Num5 someWhere = new SomeWhere();

        int anNum = someWhere.getSomeNum5();

        assertThat(anNum, is(5));
    }

}

// interface
public interface Num5 {

    int getSomeNum5();
}

// SomeWhere
public class SomeWhere implements Num5 {
    public int getSomeNum5() {
        return 5;
    }
}


```

如果你知道有一个叫Num5的接口，而它的具体实现是有另外一个团队来实现的，不幸的是那个团队还没完成功能。

难道我们能做的事情只能是等待？？  
*NO！*


我们已经知道接口了，知道它该有的功能是什么。  
所以我们可以假扮它了，嘿嘿～  


## Mockito
这个时候我们该祭出神器 [Mockito](http://mockito.org/)了。  

![img](/img/2015/test-mockito.png)

> Tasty mocking framework for unit tests in Java

使用Mockito，你就不需要知道真正的SomeWhere是这么实现的，你只需要假扮它。  

```java
import static org.hamcrest.core.Is.is;
import static org.junit.Assert.assertThat;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

/**
 * Created by Antinomy on 15/5/27.
 */
public class SampleTest {

    @Test
    public void test() {
        Num5 someWhere = getNum5Mock();

        int anNum = someWhere.getSomeNum5();

        assertThat(anNum, is(5));
    }

    private Num5 getNum5Mock() {
        Num5 result = mock(Num5.class);

        when(result.getSomeNum5()).thenReturn(5);
        return result;
    }

}
```

在以上的这段代码里，我们并不知道Somewhere是怎么实现的， 我们用了一个假扮的result去模拟Num5接口的实现。  
when(result.getSomeNum5()).thenReturn(5);  
当call到getSomeNum5()方法时，then Return 5 了。  

这样，我们就可以在Somewhere团队完成功能之前，模拟返回5，返回不是5的各种情况。  
事先调试好集成代码，等到他们完工的时候，再切换成真正代码的调用。  

![img](/img/2015/test-sample-4.png)

*mock不是上策，它只是对不完美的设计的一种妥协。*
# 小结
好吧，我们成功地把一句print语句，复杂到要用接口，mock等方式来实现。  
宇宙的熵就是这么来的，哈哈。

*写测试的时候需要精心设计测试用例，需要有丰富的想象力，需要有一颗跨界的心。*

# Further Reading
[你应该更新的Java知识之常用程序库（二）](http://dreamhead.blogbus.com/logs/226738756.html)

[Sample Codes][https://github.com/Antinomy/Antinomy.github.io/tree/master/sampleCodes/testWithMock/]

