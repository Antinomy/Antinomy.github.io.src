---
layout: mobile
title:  First Learn on Go Language 2  implement
category: Tech
---

Go语言初学记 （二）: 实现篇
=====================

# 原文再续

上一篇 [Go语言初学记 （一）: 启动篇](http://antinomy.top/2020/05/15/Tech-2020-2020-05-15-FirstLearnOnGo/) 介绍了准备开发环境的步骤, 可以开始实行我的 kanban 项目了 !

# 初步设计
kanban 项目要通过命令行来实现经典的看板管理, 初步的设计如下:

![ddd]](/img/2020/go-2-1.png)

# 测试驱动开发
    Test Not GOOD X , TDD GOOD √

有了设计就可以开始编码了, 作为一个 TDD 理念的实践者,我第一个要实现是实体 task 的测试.

go 的测试文件需以_test 结尾, new file : *task/Task_test.go*

## 具体步骤

1. 声明包 task
2. 引入测试包 testing
3. 测试方法 Test 开头,固定参数(t *testing.T)
4. 运行测试,失败
5. 实现代码
6. 循环 4~5,直至测试完成


## 测试代码

```go
package task

import (
	"testing"
)

func TestTask(t *testing.T) {
	var task1 Task

	task1.owner = "AY"
	task1.priority = "M"
	task1.project = "ProjectA"
	task1.deadline = "20200512"
	task1.tittle = "WriteKanbanCode.md"

	if task1.owner != "AY" {
		t.Log(task1)
		t.Errorf("Failed")
	}

}
```

## 实现代码

```go
package task

// Task entiy
type Task struct {
	fullName string
	owner    string
	priority string
	project  string
	deadline string
	tittle   string
}
```

## 方法测试
通过 IDE 可以很方便测试单个方法
![img]](/img/2020/go-2-2.png)

```bash
Running tool: /usr/local/go/bin/go test -timeout 30s kanban/task -run ^(TestTask)$

ok  	kanban/task	(cached)
```

## 包测试

完成一堆测试用例的时候,可以运行包测试,从结果上可以看到测试的覆盖率

![img]](/img/2020/go-2-3.png)

```bash
Running tool: /usr/local/go/bin/go test -timeout 30s -coverprofile=/var/folders/yn/h224dtzx2bq3pdhhgv4jt93r0000gn/T/vscode-gocVUxCQ/go-code-cover kanban/task

ok  	kanban/task	0.007s	coverage: 100.0% of statements
```

# 接口 : interface
go没有类*class*的设定,函数*func*是一等公民,想要实现类似封装的功能需要靠接口*interface*来实现.
我把操作task 相关的操作封装在 TaskService 里,定义如下:
## 定义接口
```go
//TaskService interface 
type TaskService interface {
	createTask(taskName string) Task
	isATask(taskName string) bool
	changeTask(changingTask ToChangeTask) Task
}
```

## 定义实现方式
定义了接口,就会有有多种实现方式.
为了实现其中一种实现方式,先定义实现方式,本项目以文件的形式来存储任务,所以定义:
```go
//FileWay desc
type FileWay struct {
}
```

## 具体实现
具体实现里在 func里加入(t *FileWay)来声明具体实现那种方式.

```go
func (t *FileWay) createTask(taskName string) Task {
	var arrs = strings.Split(taskName, "-")
	var result Task
	result.owner = arrs[0]
	result.priority = arrs[1]
	result.project = arrs[2]
	result.deadline = arrs[3]
	result.tittle = arrs[4]
	result.fullName = taskName

	return result
}

func (t *FileWay) isATask(taskName string) bool {
	var result bool = false

	var arrs = strings.Split(taskName, "-")

	if len(arrs) == 5 {
		result = true
	}

	return result
}

func (t *FileWay) changeTask(changingTask ToChangeTask) Task {
	var origin = changingTask.origin

	var result Task = origin

	if changingTask.changeItem == OWNER {
		result.owner = changingTask.changeContent
	}

	if changingTask.changeItem == PRIORITY {
		result.priority = changingTask.changeContent
	}

	if changingTask.changeItem == DEADLINE {
		result.deadline = changingTask.changeContent
	}

	return result
}

```

## 具体调用
测试用例已经包含了具体的调用代码,测试即文档还是有点道理的.

```go
func TestCreateTask(t *testing.T) {
	var taskService TaskService = new(FileWay)
	var task1 Task = taskService.createTask("AY-M-ProjectA-20200512-WriteKanbanCode.md")

	if task1.project != "ProjectA" {
		t.Log(task1)
		t.Errorf("Failed")
	}

	if task1.fullName != "AY-M-ProjectA-20200512-WriteKanbanCode.md" {
		t.Log(task1)
		t.Errorf("Failed")
	}
}

func TestIsATask(t *testing.T) {
	var taskService TaskService = new(FileWay)
	var task1 bool = taskService.isATask("AY-M-ProjectA-20200512-WriteKanbanCode.md")

	if task1 == false {
		t.Log(task1)
		t.Errorf("Failed")
	}

	var task2 = taskService.isATask("whatever")
	if task2 == true {
		t.Log(task2)
		t.Errorf("Failed")
	}

}

func TestChangeTaskOwner(t *testing.T) {
	var taskService TaskService = new(FileWay)
	var originTask Task = taskService.createTask("AY-M-ProjectA-20200512-WriteKanbanCode.md")

	// change owner
	changingTask := ToChangeTask{
		origin:        originTask,
		changeItem:    OWNER,
		changeContent: "WGL",
	}
	var changedTask Task = taskService.changeTask(changingTask)

	if changedTask.owner != "WGL" {
		t.Log(changedTask)
		t.Errorf("Failed")
	}

}
```


# To be continue

在学习接口的时候,我经历了种种不适应, 比起java的接口,go的接口要复杂一点.

在完成 task 包里的种种测试之后,我开始有点小得意了,殊不知已经给自己后面的工作埋了个大坑.....