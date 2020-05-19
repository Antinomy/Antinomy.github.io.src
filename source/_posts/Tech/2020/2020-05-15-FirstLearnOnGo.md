---
layout: mobile
title:  First Learn on Go Language 1  init
category: Tech
---

Go语言初学记 （一）: 启动篇
=====================

# 前言

如果你读过《程序员修炼之道》，就会知道每年投资学习一门新语言是有益的。（虽然我断更好久了。。。：）

近期而言，go是性价比最高的语言之一，也是我今年的目标。作为懒人来说，我不喜欢慢慢看砖头书，而喜欢直接用来做一些小工具，编学编做。

上一次学ruby的时候是帮小盆友做毕业设计，这次选择做一个基于命令行的kanban工具。

用习惯java转go会有很多不适应。我尝试把这些”坑“记下来。


这次选择的IDE是现在流行的vscode，作为一个免费而强大的工具，还是有很多需要地方需要配置的：


# go安装
mac版的安装可以直接去 [官网](https://golang.org/dl/])下载安装包，so easy。
安装后验证： 
```bash
$go version
go version go1.14.2 darwin/amd64
```
然后需要在环境变量设置$GOPATH等 ,具体参考 [go环境变量配置 (GOROOT和GOPATH)](https://www.jianshu.com/p/4e699ff478a5)

# vscode go插件安装
![img](/img/2020/go-1-1.png)

vscode插件库选择go插件，插件安装完毕之后，还需要设置插件的代理，详情参考 [goproxy.io](https://goproxy.io/zh/)
这里会折腾一段时间，没办法 囧
代理设置完成之后，重启vscode，ide会提醒你是否安装缺失的工具。

如果全部安装成功了，会在你设置的GOPATH/bin 下找到已经安装的go包： 

```bash
$ ll /Users/Antinomy/go/bin/
total 121424
drwxr-xr-x  9 Antinomy  staff       288  5 12 14:40 ./
drwxr-xr-x  5 Antinomy  staff       160  5 12 11:40 ../
-rwxr-xr-x  1 root      wheel  17914876  5 12 14:40 dlv*
-rwxr-xr-x  1 root      wheel   4588168  5 12 14:38 go-outline*
-rwxr-xr-x  1 root      wheel  12777788  5 12 14:39 gocode*
-rwxr-xr-x  1 root      wheel   9168808  5 12 14:39 godef*
-rwxr-xr-x  1 root      wheel   5846888  5 12 14:39 goimports*
-rwxr-xr-x  1 root      wheel   6232808  5 12 14:39 golint*
-rwxr-xr-x  1 root      wheel   5448568  5 12 14:38 gopkgs*
```

# 成功标志 ： hello world
新建文件 hello.go

```go
package main

import "fmt"

func main() {
	fmt.Printf("hello, world\n")
	
}
```

运行结果：

```bash
API server listening at: 127.0.0.1:5682
hello, world
Process exiting with code: 0
```
# Other tips
默认的代码检查golint十分啰嗦，个人推荐切换成GolangCI-Lint
![img](/img/2020/go-1-2.jpg)

# To be continue

千里之行始于足下，折腾完开发环境之后，终于可以敲代码了，然后我又遇到了头疼的问题。。。。



