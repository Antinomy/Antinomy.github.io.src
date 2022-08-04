---
layout: mobile
title:  minikube start issue
category: Tech
---

minikube start issue
=====================

把macos升级到 *Monterey*之后， 发现minkube start 失败了。
报一个*bsdthread_register error*的错误，具体日志如下：

``` shell
minikube start
fatal error: runtime: bsdthread_register error

runtime stack:
runtime.throw(0x20b9368, 0x21)
	/usr/local/go/src/runtime/panic.go:605 +0x95 fp=0x7ff7bfeff560 sp=0x7ff7bfeff540 pc=0x102b565
runtime.goenvs()
	/usr/local/go/src/runtime/os_darwin.go:108 +0x83 fp=0x7ff7bfeff590 sp=0x7ff7bfeff560 pc=0x1028e03
runtime.schedinit()
	/usr/local/go/src/runtime/proc.go:482 +0xa1 fp=0x7ff7bfeff5d0 sp=0x7ff7bfeff590 pc=0x102df11
runtime.rt0_go(0x7ff7bfeff608, 0x2, 0x7ff7bfeff608, 0x0, 0x1000000, 0x2, 0x7ff7bfeff810, 0x7ff7bfeff819, 0x0, 0x7ff7bfeff81f, ...)
	/usr/local/go/src/runtime/asm_amd64.s:175 +0x1eb fp=0x7ff7bfeff5d8 sp=0x7ff7bfeff5d0 pc=0x1058d2b
```

google了一轮解决方案，试了不少方式：
升级brew、minikube、go、docker等，还是不行。

查了一下官网文档，发现有一段描述了：

> If which minikube fails after installation via brew, you may have to remove the old minikube links and link the newly installed binary:
brew unlink minikube
brew link minikube

最后overwrite brew link解决了问题。

    brew link --overwrite minikube

运行minikube status， 正常启动。
``` shell
minikube
type: Control Plane
host: Running
kubelet: Running
apiserver: Running
kubeconfig: Configured
``` 

# Ref
*  https://github.com/kubernetes/minikube/issues/12832
* https://minikube.sigs.k8s.io/docs/start/
