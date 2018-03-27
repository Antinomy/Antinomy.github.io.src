---
layout: mobile
title:  Richardson Maturity Model
category: Art
---

Richardson Restful成熟度模型
=====================

# 走向荣耀的REST
Leonard Richardson提出的一个模型，把REST方法的主要元素分解成三步。
它们包括：资源，http 动词，超媒体控制。

作者 : Martin Fowler  
译者 : A生
[原文地址](http://martinfowler.com/articles/richardsonMaturityModel.html#level0)

---

内容  

[Level 0]  
[Level 1 - 资源][]  
[Level 2 - http 动词][]  
[Level 3 - 超媒体控制][]  

---
最近我正在读《 [Rest In Practice](http://www.amazon.com/gp/product/0596805829?ie=UTF8&tag=martinfowlerc-20&linkCode=as2&camp=1789&creative=9325&creativeASIN=0596805829) 》的草稿， 一本我的同事们写的书。
他们的目的是解释如何使用Restful web服务来处理许多企业面临着的集成问题。
这本书的核心是认为网络是一个存在的、经证实工作得很好的、大规模可伸缩的分布式系统。
我们根据这样的想法，可以更容易地构建集成系统。  


![img](/img/2015/rmm-overview.png)  
Figure 1: Steps toward REST  

为了更好的解释一个web风格系统的特殊属性，作者们用了一个由Leonard Richardson提出的restful成熟度模型，并在一个QCon talk的时候解释过它。
这个模型是很好的方式去思考那些技术，所以我把自己的解释也穿插在内。
（这里关于协议的例子只是为了说明问题，我不认为它值得去写代码和测试，所以在细节实现上可能会有些问题。）

---

# [Level 0]
这个模型的起点是，为了远程调用，使用HTTP来作为一个传输系统，但不使用任何web的机制。
基本上你所做的是使用HTTP作为隧道机制为自己的远程交互机制,通常基于[远程过程调用](http://www.eaipatterns.com/EncapsulatedSynchronousIntegration.html)。

![img](/img/2015/rmm-level0.png)  
Figure 2: An example interaction at Level 0

让我们假设我要预约我的医生。
我的预约软件首先需要知道我的医生什么时候有空，所以它向医院的预约系统请求这些信息。
在level 0的情景下，医院将在某个URL开放一个服务端点。
然后我向该端点post一个带有我的请求所有细节的文档。  


``` xml
POST /appointmentService HTTP/1.1
[various other headers]

<openSlotRequest date = "2010-01-04" doctor = "mjones"/>
```

服务器会返回一个给我对应信息的文档。  

``` xml
<openSlotList>
  <slot start = "1400" end = "1450">
    <doctor id = "mjones"/>
  </slot>
  <slot start = "1600" end = "1650">
    <doctor id = "mjones"/>
  </slot>
</openSlotList>
```

我在这里用了XML作为例子，但其内容可以实际上可以是任何格式：JSON、YAML、key－value pairs，或者其他自定义格式。

我的下一步是进行预约，所以我可以向服务端点再次post一个文档。  

``` xml
POST /appointmentService HTTP/1.1
[various other headers]

<appointmentRequest>
  <slot doctor = "mjones" start = "1400" end = "1450"/>
  <patient id = "jsmith"/>
</appointmentRequest>
```

顺利的话，我会收到一个告诉我预约成功的回应。  

``` xml
HTTP/1.1 200 OK
[various headers]

<appointment>
  <slot doctor = "mjones" start = "1400" end = "1450"/>
  <patient id = "jsmith"/>
</appointment>
```

如果出现问题，某人在我之前就预定了，那我会在回答的结构内得到某种错误消息。  

``` xml
HTTP/1.1 200 OK
[various headers]

<appointmentRequestFailure>
  <slot doctor = "mjones" start = "1400" end = "1450"/>
  <patient id = "jsmith"/>
  <reason>Slot not available</reason>
</appointmentRequestFailure>
```

目前为止，这就是一个直截了当的RPC风格的系统。
它很简单，它只是来回抛出普通XML（POX）。
同样原理，如果你使用SOAP 或 XML－RPC的话，唯一的不同就是你怎样去封装XML消息。  

# [Level 1 - 资源]
向RMM迈向荣耀的第一步是引入资源。


![img](/img/2015/rmm-level1.png)  
Figure 3: Level 1 adds resources

所以我们初始的查询里，我们会有给医生的一个资源。


``` xml
POST /doctors/mjones HTTP/1.1
[various other headers]

<openSlotRequest date = "2010-01-04"/>
```

答复里携带同样基本的消息，但是每一个时间段都是一个可以独立对应的资源。

```xml
HTTP/1.1 200 OK
[various headers]


<openSlotList>
  <slot id = "1234" doctor = "mjones" start = "1400" end = "1450"/>
  <slot id = "5678" doctor = "mjones" start = "1600" end = "1650"/>
</openSlotList>
```

带着特殊资源的预约意味着post着一个特定的时间段。

```xml
POST /slots/1234 HTTP/1.1
[various other headers]

<appointmentRequest>
  <patient id = "jsmith"/>
</appointmentRequest>
```
一切顺利的话，我会得到一个跟之前相似的回应。

```xml
HTTP/1.1 200 OK
[various headers]

<appointment>
  <slot id = "1234" doctor = "mjones" start = "1400" end = "1450"/>
  <patient id = "jsmith"/>
</appointment
```
现在的区别是任何人需要做关于预约的任何事情，如测试一些预定，
他们会先持有预约的资源，那可能是一个URL（e.g. http://royalhope.nhs.uk/slots/1234/appointment）,
然后post那个资源。  

对于像我这样一个（面向）对象佬，这个就像是去定义对象的概念。
而不是在以太之间调用函数和传参，我们调用一个为其他信息提供参数的特别的对象。  

# [Level 2 - http 动词]
我在所有level 0 和 1之间的交互里使用HTTP POST 动词，但是一些人用GETs 来取代或添加。
在那些level里，那并没有多少不同，他们都是被用作于允许您通过HTTP交互的隧道传输机制。
level 2 比这个更进一步，在HTTP本身的机制里尽可能地使用HTTP动词。

![img](/img/2015/rmm-level2.png)  
Figure 4: Level 2 addes HTTP verbs  

为了我们列表中的时间段，这个意味着我们要使用GET。

``` xml
GET /doctors/mjones/slots?date=20100104&status=open HTTP/1.1
Host: royalhope.nhs.uk
```

答复和之前一样使用POST，

``` xml
HTTP/1.1 200 OK
[various headers]

<openSlotList>
  <slot id = "1234" doctor = "mjones" start = "1400" end = "1450"/>
  <slot id = "5678" doctor = "mjones" start = "1600" end = "1650"/>
</openSlotList>
```

在level 2里，像这样在请求中使用GET是至关重要的。
HTTP定义GET为一个安全的操作，它不会对任何事物的状态作出重大改变。
这样允许我们在任何次数、任何顺序去安全地调用GETs，每次都得到相同的结果。
一个重要的结论是：它允许任何参与者在请求的路由里使用缓存，这是一个让web正常发挥它本身特性的关键元素。
HTTP包括了很多措施去支持缓存，可以用于任何交互者的沟通里。
遵循HTTP的规则，让我们能够去利用这种能力的优点。  


为了预约，我们需要一个HTTP动词去改变状态，一个Post或PUT。
我会使用和之前一样的POST。

``` xml
POST /slots/1234 HTTP/1.1
[various other headers]

<appointmentRequest>
  <patient id = "jsmith"/>
</appointmentRequest>
```

在这里权衡使用POST和PUT超过了我在这要说的范围，也许某天我会为了他们另起一篇文章。
但我想指出,一些人错误地把POST/PUT等同于create/update。它们之间的选择是相当不同的。  

就算我在level 1用于同样的post，那里有另外一个重要的不同之处，在于远程的服务怎样去回应。
如果一切顺利，服务应答了一个响应代码201，来表明这个世界上多了一个新的资源。  

``` xml
HTTP/1.1 201 Created
Location: slots/1234/appointment
[various headers]

<appointment>
  <slot id = "1234" doctor = "mjones" start = "1400" end = "1450"/>
  <patient id = "jsmith"/>
</appointment>
```

201的响应包括一个位置属性的URI，所以客户端在未来可以去用GET那个资源的当前状态。
这里的响应还包括该资源的展示，去保存当前客户端一个额外的调用。  

另外一个不同的区别，如果那里出现错误，如某人有预定的那个时间。  

``` xml
HTTP/1.1 409 Conflict
[various headers]

<openSlotList>
  <slot id = "5678" doctor = "mjones" start = "1600" end = "1650"/>
</openSlotList>
```
这个应答中重要的部分，用一个HTTP的响应代码去识别那里出现了错误。
在这种情况下,409似乎是一个不错的选择,表明其他人已经在一个不兼容的方式下去更新资源。
而不是使用响应代码200但又包含了错误的响应，在level 2 我们显然使用某种像这样的错误响应。
那是由协议设计者来决定使用什么代码，但是一个错误出现时，应该使用一个非2xx的响应代码。
Level 2 介绍了使用HTTP动词和HTTP响应代码。  

在这里有一个矛盾。
REST提倡使用所有的HTTP动词。
他们也在证明他们的方法：REST是试图学习web的实际成功的一面。
但是万维网在实际应用很少使用PUT或DELETE。
合理使用PUT和DELETE的情况越来越多，但是web的存在证明并不是其中一个。  

支持web存在的关键元素，是严格地分离来安全（例如GET）和非安全的操作，一起用状态码来帮助沟通遇到的各种错误。  

# [Level 3 - 超媒体控制]

最后的level介绍了一个你经常听到的一个丑陋的缩写：HATEOAS (Hypertext As The Engine Of Application State)。
它解决的问题是：如何从一个开放的时间段里，去知道预约应该做些什么？  

![img](/img/2015/rmm-level3.png)  
Figure 5: Level 3 adds hypermedia controls  

我们开始同样初始化的GET，跟我们在level 2 发送的一样。  



``` xml
GET /doctors/mjones/slots?date=20100104&status=open HTTP/1.1
Host: royalhope.nhs.uk

``` 

但是应答里多了一个新元素  


``` xml
HTTP/1.1 200 OK
[various headers]

<openSlotList>
  <slot id = "1234" doctor = "mjones" start = "1400" end = "1450">
     <link rel = "/linkrels/slot/book" 
           uri = "/slots/1234"/>
  </slot>
  <slot id = "5678" doctor = "mjones" start = "1600" end = "1650">
     <link rel = "/linkrels/slot/book" 
           uri = "/slots/5678"/>
  </slot>
</openSlotList>
```

现在每一个时间段包含了一个URI，告诉我们如何去预约。  

超媒体控制的关键在于告诉我们，接下来我们能做什么，和我们需要操作的资源的URI。
而不是我们必须要知道那里可以post我们的预约请求，超媒体控制的应答里告诉了我们如何去做。  

POST 会再次复制level 2的

``` xml
POST /slots/1234 HTTP/1.1
[various other headers]

<appointmentRequest>
  <patient id = "jsmith"/>
</appointmentRequest>
```
然后应答里包括了一系列为了不同事情的下一步的超媒体控制。  

``` xml
HTTP/1.1 201 Created
Location: http://royalhope.nhs.uk/slots/1234/appointment
[various headers]

<appointment>
  <slot id = "1234" doctor = "mjones" start = "1400" end = "1450"/>
  <patient id = "jsmith"/>
  <link rel = "/linkrels/appointment/cancel"
        uri = "/slots/1234/appointment"/>
  <link rel = "/linkrels/appointment/addTest"
        uri = "/slots/1234/appointment/tests"/>
  <link rel = "self"
        uri = "/slots/1234/appointment"/>
  <link rel = "/linkrels/appointment/changeTime"
        uri = "/doctors/mjones/slots?date=20100104@status=open"/>
  <link rel = "/linkrels/appointment/updateContactInfo"
        uri = "/patients/jsmith/contactInfo"/>
  <link rel = "/linkrels/help"
        uri = "/help/appointment"/>
</appointment>
```

超媒体控制一个明显的好处在于：允许服务端在不破坏客户端的情况下，去修改它自己的URI scheme。
除了最初的入口点，只要客户端寻找“addTest” 链接URI，服务端团队可以处理所有的URI。   

一个长远的好处就是它帮助客户端的开发者去探索协议。
那个链接给客户端开发者一个接下来可能是什么的提示。
它不会给予所有的信息：指向同一个URI，“最近的”和“取消”的控制－－他们需要找出一个是GET和另外一个是DELETE。
但至少它给了他们一个起点,去考虑的更多信息，和在协议文档里寻找一个类似的URI。  

同样地它允许服务端团队通过响应里的新链接去宣传新的功能。
如果客户端开发者密切留意那些未知的链接，这些链接可以触发进一步的探索。  

那里没有绝对的标准关于如何去表示超媒体控制。
我在这里所做的是，在一个实践的团队里去使用当前建议的REST，这是遵循ATOM （[RFC 4287](http://atompub.org/rfc4287.html) ）
我为了一个目标的URI和一个rel属性，用一个带一个uri属性的 <link> 元素去描述这种关系。
一个众所周知的关系(如引用自己本身的元素)是赤裸的,任何特定的服务器是一个完全限定的URI。
ATOM说明知名linkrels的定义是：[链接关系的注册表](http://www.iana.org/assignments/link-relations/link-relations.xhtml)
我所写的这些界限于ATOM所做的，通常被看作是安静的level 3里一个领导者。  

---
Levels的定义

我应该强调RMM,是一个好的方式去思考什么是REST的元素,而不是一个REST本身级别的的定义。
Roy Fielding已经清晰地指出 [level 3 是REST的一个前置条件](http://roy.gbiv.com/untangled/2008/rest-apis-must-be-hypertext-driven)
就像软件里的很多缩写，REST拥有许多的定义，但从Roy Fielding 杜撰了这个缩写开始，他的定义应该比大多数人更有分量。  


我觉得这个RMM有用的是,它提供了一个很好的方式，一步步去理解restfull思维背后的基本想法。
因此我认为这是来帮助我们了解概念的工具，而不是某种评价机制。
我不认为我们有足够多的例子，去真正确保restful方式是集成系统的正确方法。
在我建议的大多数情况下，我认为这是一个非常有吸引力的方法。  

和Ian Robinson讨论这个时，他强调当Leonard Richardson首次提出它时，
这个模型具有吸引力的地方是，这是常见的设计技术的关系。  

	+ Level 1 处理复杂性的问题通过使用分而治之,把一个大型的服务端点分解成多个资源。

	+ Level 2 引入一组标准的动词,这样我们可以以同样的方式处理类似的问题,消除了不必要的不确定性。

	+ Level 3 引入可查找性,提供一种方式让协议更具可读性。

结果是，一个模型帮助我们去思考我们想要一个怎样的HTTP服务，去提供和设计人们希望与之交互的期望。
