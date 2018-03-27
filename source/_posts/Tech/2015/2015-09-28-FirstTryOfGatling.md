---
layout: mobile
title:  First Try of Gatling
category: Tech
---

次时代压力测试工具：Gatling初体验
=====================
<img src="/img/2015/gatling1.png" width="800">

# 为什么用Gatling？
因工作需要，要对HTTP接口进行专门的压力测试。  
经过一番考虑，我选择了 [Gatling](http://gatling.io/) 。

	Gatling 作为次时代的压力测试工具，具有高性能，结果报表友好，支持DSL等特点。


不同于它的前辈JMeter， Gatling 是基于Scala、Akka、Netty的。  
优点在于它对多并发测试有着强力的性能表现，缺点自然是学习曲线稍微高一点。  

*所以在性能上，Gatling的表现是优于JMeter的，这也是我为什么选择它的原因。*  
![img](/img/2015/gatling2.png)

# 怎么用Gatling？
既然它是基于Scala的，一门新语言对很多固守成规的人的来说，有着不小的心里成本。  
但还是可以有某些技巧可以减少学习成本，例如，可以直接从官方的例子来学习：

[gatling-maven-plugin-demo](https://github.com/gatling/gatling-maven-plugin-demo)

我选择了和maven相关的例子，这样是为了以后方便和CI服务器集成。  
![img](/img/2015/gatling3.png)

首页就介绍了如何用maven去运行gatling，从运行入口BasicSimulation.scala 就可以学习基本的用法。

```scala
package computerdatabase

import io.gatling.core.Predef._
import io.gatling.http.Predef._
import scala.concurrent.duration._

class BasicSimulation extends Simulation {

  val httpConf = http
    .baseURL("http://computer-database.gatling.io") // Here is the root for all relative URLs
    .acceptHeader("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8") // Here are the common headers
    .doNotTrackHeader("1")
    .acceptLanguageHeader("en-US,en;q=0.5")
    .acceptEncodingHeader("gzip, deflate")
    .userAgentHeader("Mozilla/5.0 (Macintosh; Intel Mac OS X 10.8; rv:16.0) Gecko/20100101 Firefox/16.0")

  val headers_10 = Map("Content-Type" -> """application/x-www-form-urlencoded""") // Note the headers specific to a given request

  val scn = scenario("Scenario Name") // A scenario is a chain of requests and pauses
    .exec(http("request_1")
      .get("/"))
    .pause(7) // Note that Gatling has recorder real time pauses
    .exec(http("request_2")
      .get("/computers?f=macbook"))
    .pause(2)
    .exec(http("request_3")
      .get("/computers/6"))
    .pause(3)
    .exec(http("request_4")
      .get("/"))
    .pause(2)
    .exec(http("request_5")
      .get("/computers?p=1"))
    .pause(670 milliseconds)
    .exec(http("request_6")
      .get("/computers?p=2"))
    .pause(629 milliseconds)
    .exec(http("request_7")
      .get("/computers?p=3"))
    .pause(734 milliseconds)
    .exec(http("request_8")
      .get("/computers?p=4"))
    .pause(5)
    .exec(http("request_9")
      .get("/computers/new"))
    .pause(1)
    .exec(http("request_10") // Here's an example of a POST request
      .post("/computers")
      .headers(headers_10)
      .formParam("""name""", """Beautiful Computer""") // Note the triple double quotes: used in Scala for protecting a whole chain of characters (no need for backslash)
      .formParam("""introduced""", """2012-05-30""")
      .formParam("""discontinued""", """""")
      .formParam("""company""", """37"""))

  setUp(scn.inject(atOnceUsers(1)).protocols(httpConf))
}
```

这个是一个很好的例子，从源码里我们可以轻易知道怎样去测试一个HTTP接口，无论是通过HTTP GET ，还是HTTP POST。  

# 进阶使用Gatling
从官方的文档中，得知Gatling支持读取csv格式的数据，这样进一步的方便我对测试数据的准备，为了测试简单，我采取了HTTP GET的方式。  


我通过一个csv文件配置测试所需要的的数据：

![img](/img/2015/gatling4.png)

然后改写测试代码来支持读取csv，这里采取了随即读取的方式：

```scala

val httpConf = http
    .baseURL("http://computer-database.gatling.io") // Here is the root for all relative URLs

 ......

 val records = csv("api_scenario.csv", rawSplit = true).random

  val scn = scenario("API Performance Test") // A scenario is a chain of requests and pauses
  // inject project
    .feed(records)

    .exec(http("${scenario}")
    .get("${api}")
    .check(status.is(200))
    )

  val runUsers = Integer.getInteger("users", 1)
  setUp(scn.inject(atOnceUsers(runUsers)).protocols(httpConf))
```
baseURL("http://xxx")方法决定的测试的URL， records定义测试的数据源。  
通过feed方法读取数据，exe方法执行，get方法采取HTTP GET方式，check方法检查返回结果（HTTP CODE）  

变量runUsers则是定义一个外部传入的参数，代表测试的并发数。  



# 运行Gatling
一切就绪之后就可以运行测试了，以Intellij为例：
![img](/img/2015/gatling5.png)

	gatling:execute -Dgatling.simulationClass=computerdatabase.API_Simulation -X -Dusers=10

gatling:execute 执行测试， 参数-Dgatling.simulationClass指定入口， －X 打开Maven的调试日志，-Dusers用户并发数。

运行之后日志如下：  
![img](/img/2015/gatling6.png)

打开结果报表 （../target/gatling/results/api-simulation-xxx/index.html）  
拉风的报表就出现了！   
![img](/img/2015/gatling7.png)


# CI集成
由于之前采取了Maven的命令行模式，所以把Gatling集成到Hudson／Jeskin也非常简单。

![img](/img/2015/gatling8.png)


# 结论
通过上面的步骤，一个简单而完整Gatling测试环境就搭建起来。  

我的结论是， Gatling， 你值得拥有。 ：）
