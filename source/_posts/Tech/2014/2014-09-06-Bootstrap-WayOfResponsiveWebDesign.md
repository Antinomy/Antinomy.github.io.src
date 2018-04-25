---
layout: mobile
title: Bootstrap - Way Of Responsive Web Design
category: Tech
date: 2014-09-06
---

Bootstrap - 响应式Web设计之道
=====================

建立自己的个人blog也有一段时间的，跟用其他著名的blog不一样。所有事情都可以享受DIY的乐趣，当然，也有付出不少的时间。基本功能也搞的7788， 就是用手机端查看博客的时候，排版差劲的很。基于后PC时代，移动设备的时代也开始了。稍微百谷歌度之后，还是有简单的解决方案的——Bootstrap。

>## 什么是 [Bootstrap](http://getbootstrap.com/)？
应用[w3cschool](http://www.w3cschool.cc/bootstrap/bootstrap-intro.html)的定义:
Bootstrap 是一个用于快速开发 Web 应用程序和网站的前端框架。Bootstrap 是基于 HTML、CSS、JAVASCRIPT 的。


## Bootstrap 的网格系统（Grid System）
Grid System是基于移动设备优先策略,简单实现多设备自适应layout的关键。
通过不同的class设定就能实现不同的布局：
<a href="/img/2014/0824-IDDD.png" target="_blank">
![img](/img/2014/Bootstarp-1.png)
</a>

e.g. 以下HTML Code，就能简单地实现响应式布局

```html
<div class="container-fluid">
<div class="row">
    <div class="col-xs-12 col-md-offset-1">
        <br>
        content 
        <br>
    </div>
</div>
</div>
```


## Bootstrap 的必要文件
除了Bootstrap自己的CSS和字体,Jquery的库也是要的,官方下载后放入自己的路径下即可

![img](/img/2014/Bootstarp-5.png)

最终效果如下,不同设备下不同的自适应布局:
---

	大屏幕
![img](/img/2014/Bootstarp-2.png)

	
	中屏幕
![img](/img/2014/Bootstarp-3.png)

	
	小屏幕
![img](/img/2014/Bootstarp-4.png)

---
