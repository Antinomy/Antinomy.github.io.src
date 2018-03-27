---
layout: mobile
title: Issues On Upgrade Jekyll-2.2.0
category: Tech
---

Jekyll-2.2.0 的坑
=====================


手痒把Jekyll升级到2.2.0的时候,发现服务已经启动不起来了. @_@ |||

折腾了一阵子,搞定了中间出现的几个问题, 终于正常了. ^_^
	
![img](/img/2014/jekyll2.2.0.png)

---
## 问题1 : JavaScript runtime Issue
*Could not find a JavaScript runtime.*

Jekyll 2.2.0比起旧版本需要多一个Js runtime, 装个node.js fixed.

```bash
sudo apt-get install nodejs
```

---
## 问题2: pygments Issue

*Deprecation: The 'pygments' configuration option has been renamed to 'highlighter'. Please update your config file accordingly. The allowed values are 'rouge', 'pygments' or null.*

pygments (代码高亮插件)在 _config.yml的配置格式改变了.

```ruby
pygments: true  -->  highlighter: pygments
```

---
最后重新启动下服务,搞定!

	jekyll serve --watch

![img](/img/2014/jekyll2.2.0-Done.png)

