---
layout: mobile
title: The Little Mocker
category: Art
---

The Little Mocker
=====================
![img](http://files.colabug.com/forum/201405/09/122549a1wfhyfn11wsrfsr.jpg.thumb.jpg)

关于Mock和Stub之间的区别，我一直没搞明白。

直到看了Uncle Bob的[The Little Mocker](http://blog.8thlight.com/uncle-bob/2014/05/14/TheLittleMocker.html) ，才知道里面的水还挺深的，我姑且尝试把它翻译一下：

---

# 小Mocker
作者:Uncle Bob  
译者:A生  

接下来的讨论是关于mocking：

这是什么？

```java
interface Authorizer {
  public Boolean authorize(String username, String password);
}
```
>一个interface.

那么这样呢?

```java
public class DummyAuthorizer implements Authorizer {
  public Boolean authorize(String username, String password) {
    return null;
  }
}
```
>那是Dummy

那你拿Dummy做什么呢?

>你把它传入某地方,但你并不在意怎么用它的时候.
	
就像?

>作为测试的一部分,当必须要传入一个参数,但你知道那个参数永远不会用到的时候.

能举个例子么?

>当然.

```java
public class System {
    public System(Authorizer authorizer) {
        this.authorizer = authorizer;
    }

    public int loginCount() {
        //returns number of logged in users.
    }
  }

  @Test
  public void newlyCreatedSystem_hasNoLoggedInUsers() {
    System system = new System(new DummyAuthorizer());
    assertThat(system.loginCount(), is(0));
  }
```

我懂了.为了能构造系统,必须传入一个Authorizer到构造函数里;但authorize方法永不会被调用到,所以在这个测试里,没有人会登陆入.

>你懂的.

所以DummyAuthorizer的authorize方法返回一个null并不是一个错误.

>其实不是.事实上,一个Dummy最好能有所返回.

为什么呢?

>因为任何人尝试用这个Dummy,他们会得到一个NullPointerException.

啊,你不想这个Dummy被使用.

>对!它只是一个dummy.

但这不是一个mock?我以为那些测试对象叫做mocks.

>它们是;但那是行话.

行话?

>是的,"mock"这个词汇,有时被用于一种非正式的场合,用来代表测试对象的整个家族.

那么这些测试对象们有一个正式的名字么?

>有,它们叫做"Test Doubles" [1].

你指像电影里的"替身"么?

>必须滴.

那么"mock"这个词只是通俗的行话?

>不,它也有一个正式的含义;但当我们非正式说mock时,它是Test Double的同义词.

为什么我们得有2个词?不能只用Test Double代替Mock么?

>历史原因.

历史?

>是的,很久之前某个很聪明的人写了一篇[文章](http://www.ccs.neu.edu/research/demeter/related-work/extreme-programming/MockObjectsFinal.PDF)来介绍和定义什么Mock对象.很多人读过并且开始使用这个词.没有读过的人听到这个词,也开始广义地使用.他们甚至把它变成动词,他们会说:"让我们mock那个对象吧",或 "我们有很多的mocking要做".

很多词汇都发生过类似的事情,不是么?

>的确是的.特别是当一个词只有一个音节,那是容易说出的.

耶，我猜那会容易说些：“让我们mock它吧” 而不是 “让我们为此做个测试替身吧”.

> 对, 口语是生活的一种现实.

OK,但我们需要精确的说呢...

> 那你应该用正式的语言.

那什么是Mock呢?

> 在我们说那之前,我们应该看下其他种类的测试替身.

比如?

> 先看下Stubs

什么是stub?

> 这,就是一个stub:

```java
public class AcceptingAuthorizerStub implements Authorizer {
  public Boolean authorize(String username, String password) {
    return true;
  }
}
```

它返回ture.

> 那就是.

为什么?

> 好的,假设你要测试你的系统的一部分其中需要你先登陆.

那我就登陆咯.

> 但你早已知道登陆是可行的,你在其他地方测试了它,为什么要测试多一次?

因为那样容易?

> 但是那样耗时,也需要做配置先. 如果登陆里有bug,那你的测试会失败.
> 毕竟, 那是不必要的耦合.

Hmmm,好吧,为了有效的辩论,当我同意吧,下一步应该?

> 你为了那测试,简单注入AcceptingAuthorizerStub到你的系统里.

它会毫无疑问地去授权用户.

> 对

所以如果我想测试没有授权过的用户时,我应该用一个返回false的stub.

> 又对了.

Ok,那还有别的什么?

> 还有这个:

```java
public class AcceptingAuthorizerSpy implements Authorizer {
  public boolean authorizeWasCalled = false;

  public Boolean authorize(String username, String password) {
    authorizeWasCalled = true;
    return true;
  }
}
```

我觉得那叫作Spy.

> 正确.

所以我为什么要这样用呢?

> 当你需要确定authorize方法一定会被系统调用的时候,你会这么做.


啊,我懂了.在我的测试里注入像一个stub的东西,但在测试的最后会检测变量authorizerWasCalled去确保系统是否真的调用了authorize方法.

> 完全正确.

所以一个Spy,侦查了调用者,我觉得它能记录所有这种类型的事情.

> 它的确能做到,例如,它能算出调用的总次数.

yeah,或者它能保持一个列表来记录每次传入的参数.

> 对的,你可以通过Spies去了解,在测试的对象里的算法是如何工作的.

听起来像耦合.

> 那是!你不得不小心点. Spy用得越多,你的测试就越耦合你系统的实现,最终导致易脆的测试.

什么是易脆的测试?

> 一个测试破坏了一些不应该去破坏一个测试的理由.

如若你改变系统里的代码,某些测试也会受到破坏.

> 对,但设计良好的测试能最小化那种破坏,Spies恰恰与之相反.


OK,我懂了.那还有别的测试替身么?

> 还有2种,第一种是:

```java
public class AcceptingAuthorizerVerificationMock implements Authorizer {
  public boolean authorizeWasCalled = false;

  public Boolean authorize(String username, String password) {
    authorizeWasCalled = true;
    return true;
  }

  public boolean verify() {
    return authorizedWasCalled;
  }
}
```
当然,这是一个mock.

> 对,一个真正的Mock.

真正的?

> 对,这是一个正式的mock对象,与字面上的含义一致.

我明白了,它看起来像你把测试里的断言移至verify方法里,真正的mock.

> 对,Mocks知道他们在测试什么.

所以那是?你只是把断言放入mock里?

> 不完全,是,断言放入了mock里.然而,mock在测试的是*行为*.

行为?

> 对, mock并不关心函数返回的值.它关心的什么函数被调用,调用了什么参数,什么时候和有多频繁被调用.

所以一个mock经常是一个spy?

> 对,一个mock调查了被测试模块的行为,它知道什么样的行为是被期待的.

Hmmm,把期望搬入mock里感觉上是一种耦合.

> 那是.

那为什么呢?

> 那样写一个mocking工具会容易的多.

一个mocking工具?

> 是的,像JMock,EasyMock,或Mockito等.那些工具能让你飞一般去创建mock对象.

看起来很复杂.

> 那倒不会,[这里](http://martinfowler.com/articles/mocksArentStubs.html)有Martin Fowler一篇介绍它的著名文章.

那是不是还有一本关于它的书,有么?

> 有,[Growing Object Oriented Software, Guided by Tests](http://www.amazon.com/Growing-Object-Oriented-Software-Guided-Tests/dp/0321503627)就是一本关于驱动mock的主流设计哲学的书.

Ok, 所以完了? 你说过还有另外一种的.

> 对, 再多一种, Fakes.

```java
public class AcceptingAuthorizerFake implements Authorizer {
      public Boolean authorize(String username, String password) {
        return username.equals("Bob");
      }
  }
```

ok,那样很奇怪,所有叫做"Bob"的用户都会被授权.

> 对, 一个Fake有业务上的行为. 你可以驱动一个fake根据不同的数据表现出不同的行为.

看起来像虚拟器.

> 对,虚拟器是fakes.

Fakes不是stubs吧?

> 不是,faker有真正业务上的行为;stubs没有. 事实上,我们之前谈论的测试替身没有一种包含真正业务行为.

所有fakes在基础概念上完全不同的.

> 的确是.我们可以这样说: 一个Mock是一种spy,一个spy是一种stub,而一个stub是一种dummy. 不是fake 不是它们中的任何一种. 它是完全不同类型的测试替身.

我可以想象fakes会复杂起来.

> 它们可以变得极端的复杂,所以它们会复杂到需要自己的单元测试.在极端情况下,fakes变成了真正的系统.

Hmmm.

> 对,Hmmm. 我不常写fakes,事实上,三十多年来我没有写过一个.

Wow! 那你会写什么? 其他剩下的测试替身么?

> 最多用的是stubs和spyies. 我自己写的,我不常用mocking工具.

那你用Dummies么?

> 对, 但极少.

那mocks呢?

> 只有我用mocking工具的时候用.

但你说过你不用mocking工具.

> 对,我通常不会用.

为什么不?

> 因为stubs 和 spies是很容易写的, 我的IDE让此变的简单.我只要指着接口告诉IDE去实现它,瞧!它就给我一个dummy了.所以我只需要一个小小改变就能变成stub 或spy.所以我真的很少用mocking工具.

所以它只是为了方便?

> 对, 事实上我不喜欢mocking工具的奇怪语法,还有配置它们的复杂性. 我发现写自己的测试替身在多数情况下会比较简单.

OK, 好的, 谢谢你的对话.

> 随时欢迎.

---
[1] [xUnit Test Patterns](http://www.amazon.com/xUnit-Test-Patterns-Refactoring-Code/dp/0131495054)

---
PS: 最后,A生简单的介绍它们之间的关系:

![img](/img/2014/Mocks.png)
