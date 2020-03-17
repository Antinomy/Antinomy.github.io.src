---
layout: mobile
title:  Jenkins Tips , About Test
category: Tech
---

Jenkins插件小贴士 (三)  About Test
=====================



前2篇介绍了如何用Jenkins来实现日常的CI,本篇来介绍一下测试相关的实现.

# 测试的类型

测试的类型有很多种,大致分为4个象限:

![img](/img/2020/Jenkins-10.jpeg)

下面就常见的单元测试和压力测试,介绍一下如何在jenkins的构建里实现.


# 单元测试
Java项目常用的单元测试工具就是JUnit.


按照Maven的项目结构去创建测试:
![img](/img/2020/Jenkins-10.png)

Maven构建的时候会去跑单元测试.
![img](/img/2020/Jenkins-12.png)


单元测试的结果趋势会显示Job构建界面上.
![img](/img/2020/Jenkins-11.png)

也可以去看明细的单元测试结果:
![img](/img/2020/Jenkins-13.png)

*单元测试最重要的是什么?*
当然是 快 !!!

要做到快必须做到3点:
1. no DB
2. no IO
3. no Network

[相关demo代码](https://github.com/Antinomy/aboutTest)

# 压力测试

压力测试也叫性能测试,是指系统功能正常的情况,能够承载的容量测试.

Java的项目最常见的压力测试就是关于接口的测试,常见的工具有Jmeter,gatling 等.

个人推荐使用gatling来进行接口的压测,具体可以参考我以前的一遍文章:

[Gatling初体验](http://antinomy.top/2015/09/28/Tech-2015-2015-09-28-FirstTryOfGatling/)

也可以从官方的Maven Demo开始学习如何使用gatling.

[官方Demo](https://github.com/gatling/gatling-maven-plugin-demo)

Demo代码是用Scala的语法编写的,模拟了一个用户通过http get 和 http post的方式去调用接口.

```scala
package computerdatabase

import io.gatling.core.Predef._
import io.gatling.http.Predef._
import scala.concurrent.duration._

class BasicSimulation extends Simulation {

  val httpProtocol = http
    .baseUrl("http://computer-database.gatling.io") // Here is the root for all relative URLs
    .acceptHeader("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8") // Here are the common headers
    .acceptEncodingHeader("gzip, deflate")
    .acceptLanguageHeader("en-US,en;q=0.5")
    .userAgentHeader("Mozilla/5.0 (Macintosh; Intel Mac OS X 10.8; rv:16.0) Gecko/20100101 Firefox/16.0")

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
      .formParam("""name""", """Beautiful Computer""") // Note the triple double quotes: used in Scala for protecting a whole chain of characters (no need for backslash)
      .formParam("""introduced""", """2012-05-30""")
      .formParam("""discontinued""", """""")
      .formParam("""company""", """37"""))

  setUp(scn.inject(atOnceUsers(1)).protocols(httpProtocol))
}
```

确保Jenkins已经安装了gatling的插件:
![img](/img/2020/Jenkins-14.png)

Job配置上Track a Gatling load simulation
![img](/img/2020/Jenkins-15.png)

构建完成之后就能看到详细的测试报告
![img](/img/2020/Jenkins-16.png)

# End
通过Jenkins本身和安装的插件, 可以很方便实现单元测试与压力测试,
更多的难点是在测试用例的设计与编写上,集成进来反倒简单.




