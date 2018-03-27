---
layout: mobile
title:  Beck Design Rules
category: Art
---

Beck Design Rules （Beck设计规则 A生译）
=====================
![img](/img/2015/kent.jpg)

Kent Beck developed Extreme Programming, Test Driven Development, and can always be relied on for good Victorian facial hair for his local ballet.

作者 : Martin Fowler  
译者 : A生
[原文地址](http://martinfowler.com/bliki/BeckDesignRules.html)


Kent Beck 归纳出他关于简单设计的四条规则，当他在1990年代发明[极限编程](http://martinfowler.com/bliki/ExtremeProgramming.html)的时候。

我将它们概括如下：  
* 通过测试  
* 展现意图  
* 没有重复  
* 极少的元素  

规则是按优先级排序的，所以 “通过测试” 比 “展现意图” 有着更高的优先级。  
  
最重要的规则就是 “通过测试”。
XP（极限编程）是关于测试如何在软件开发中上升为一等活动的革命，
所以自然地，它应该在那些规则之中扮演着尤其显要的角色。
关键点是无论你在软件中干了什么，主要目的是让它如心中所想那样的工作，测试在哪里就是确保它是那样的发生。  


“展现意图” 是Kent的方式去说明代码应该容易被理解。
沟通是极限编程的核心价值，很多程序员喜欢这样的认为：程序在哪里就是为了被别人去阅读的。
Kent解释这个规则的关键是，能够在代码里去表达你的意图，所以你的读者能够理解你当时写下那段代码的目的。  


"没有重复"可能是那些规则中最有力和微妙的。
它在别的地方也叫做 “DRY” or “SPOT” [备注]  的概念,Kent表达它是关于当说起所有的事情时，应该是“一次 只有一次”。
许多程序员已经注意到，去除重复是演进好的设计的一种的强力方式。  

最后一条规则告诉我们，任何不服务前面三条规则的，都应该被移走。
当这些规则制定的同时，许多设计上的建议是：为了能够增加对未来需求的灵活性，在一个架构上不断地增加元素。
具有讽刺意义的是，所有这些元素带来的额外的复杂性，让系统难于修改，因此在实践中的灵活性就更少了。  

人们常常会发现 “没有重复”和“展现意图” 之间有一些争议，导致争论的是这2个规则的优先次序。
我经常觉得他们之间的顺序并不重要，因为他们彼此在精炼代码的过程中相互依存。
诸如通过增加重复的内容来让代码更加清晰，往往是正在准备去掩盖一个问题，当这个问题将被更好的解决的时候。  

![img](/img/2015/kent-sketch.png)

我喜欢这些规则的是记住它们很简单，遵循这些规则可以改进任何一种我用过的语言或编程的范式。
它们是Kent寻找普遍适用的原则的能力的其中一个例子，但足以改变我的行为。  

> At the time there was a lot of “design is subjective”, “design is a matter of taste” bullshit going around. I disagreed. There are better and worse designs. These criteria aren’t perfect, but they serve to sort out some of the obvious crap and (importantly) you can evaluate them right now. The real criteria for quality of design, “minimizes cost (including the cost of delay) and maximizes benefit over the lifetime of the software,” can only be evaluated post hoc, and even then any evaluation will be subject to a large bag full of cognitive biases. The four rules are generally predictive.


>当有很多 “ 设计是主观的 ”,“ 设计是一种品味 ” 废话的时候。
我不同意，设计有更好的和更糟糕的。
这些标准并不完美,但是它们解决了一些明显的废话，(重要的是)现在你可以评估他们。
这四个规则通用地评估：质量设计的真正标准， “ 最小化成本(包括延迟的成本)和最大化效益在软件的生命周期 ” 。
而不是那些只能事后评估,甚至任何评估了就将受到一大堆认知偏见的评估。

> -- Kent Beck

## Further Reading

[原文地址](http://martinfowler.com/bliki/BeckDesignRules.html)

## 备注
＊DRY stands for Don't Repeat Yourself, and comes from The Pragmatic Programmer.
SPOT stands for Single Point Of Truth.
