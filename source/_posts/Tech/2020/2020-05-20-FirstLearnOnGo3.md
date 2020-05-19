---
layout: mobile
title:  First Learn on Go Language 3 lesson
category: Tech
---

Go语言初学记 （三）: 踩坑篇
=====================

# 原文再续

上一篇 [Go语言初学记 （二）: 实现篇](http://antinomy.top/2020/05/19/Tech-2020-2020-05-19-FirstLearnOnGo2/) 实现了 task 包的基本功能和测试覆盖,是时候实现另外一个包 ban 了.

# 目标与准备
ban 包需要实现和文件系统的操作, 以读取 02-doing 列的数据为例,需要实现 2 个步骤:
1. 读取目标目录下所有文件的名字
2. 过滤符合格式的任务名字

我预先准备单元测试所需要的数据,2个符合格式的任务文件和一个不符合格式的.

![img]](/img/2020/go-3-1.png)


# 步骤 1:读取目标目录下所有文件的名字

期望的测试:

```go
package ban

import (
	"testing"
)

func TestReadDir(t *testing.T) {

	var folderPath = ".././unittest/myTasks/02-doing"
	var todoList []string = readFileList(folderPath)

	var taskNum = len(todoList)

	if taskNum != 3 {
		t.Log(todoList)
		t.Errorf("Failed")
	}
}
```

具体实现:

```go
package ban

import (
	"fmt"
	"io/ioutil"
	"log"
)

func readFileList(folderPath string) []string {

	files, err := ioutil.ReadDir(folderPath)
	if err != nil {
		log.Fatal(err)
	}

	var filesLen = len(files)
	fmt.Println(filesLen)
	var result []string = make([]string, filesLen)

	for index, f := range files {
		fmt.Println(f.Name())
		result[index] = f.Name()
	}

	return result
}

```

debug 模式运行,打印日志

```bash
API server listening at: 127.0.0.1:22211
3
AY-M-ProjectB-0520-doSth.md
GLW-H-ProjectB-0621-doSth.md
GLW-H-ProjectB0621notCorrectTask.md
PASS

```

运行结果与期待一致,步骤 1 done. 
只是没想到实现步骤 2 的时候,困扰了我很久.

# 步骤2. 过滤符合格式的任务名字

从步骤 2 开始,我需要引用 task 包里的接口与结构体了.

期望的测试:

```go
package ban

import (
    "testing"
    "kanban/task"
)

func TestReadCorrectTask(t *testing.T) {

	var folderPath = ".././unittest/myTasks/02-doing"
	var todoList []string = readFileList(folderPath)
	var todoTasks []Task = readCorrectTasks(todoList)

	var taskNum = len(todoTasks)

	if taskNum != 2 {
		t.Log(todoTasks)
		t.Errorf("Failed")
	}
}

```

具体实现:

```go
package ban

import (
    "fmt"
    "kanban/task"
)

func readCorrectTasks(filesList []string) []kt.Task {
	var result []Task

	var ts TaskService = new(FileWay)

	for _, fileName := range filesList {
		if ts.isATask(fileName) {
			fmt.Println(fileName)
			result = append(result, ts.createTask(fileName))
		}
	}

	fmt.Println(len(result))

	return result
}

```

运行结果却并不理想
```bash
Running tool: /usr/local/go/bin/go test -timeout 30s kanban/ban -run ^(TestReadCorrectTask)$

# kanban/ban [kanban/ban.test]
/Users/Antinomy/Github/kanban/ban/KanbanService.go:7:45: undefined: kt
/Users/Antinomy/Github/kanban/ban/KanbanService.go:8:15: undefined: Task
/Users/Antinomy/Github/kanban/ban/KanbanService.go:10:9: undefined: TaskService
/Users/Antinomy/Github/kanban/ban/KanbanService.go:10:27: undefined: FileWay
/Users/Antinomy/Github/kanban/ban/Kanban_test.go:24:18: undefined: Task
FAIL	kanban/ban [build failed]
FAIL

```

很明细 ban 包的代码无法识别的 task 包里的对象,导致无法运行. 

后来发现,编辑器会自动去掉 import 里的 "kanban/task",经过一番折腾,修改  "kanban/task" 为 kt "kanban/task",
task 包才被成功识别. 看来 go 的包引用并没有我想象中那么智能.

```go
import (
	kt "kanban/task"
	"testing"
)

....

```

修改完毕,运行结果:

```bash
/Users/Antinomy/Github/kanban/ban/KanbanService.go:14:8: ts.isATask undefined (cannot refer to unexported field or method isATask)
/Users/Antinomy/Github/kanban/ban/KanbanService.go:16:30: ts.createTask undefined (cannot refer to unexported field or method createTask)
```

原来go 接口里,方法名小写开头代表包内可见,方法名大写开头才能包外可见. (我在上一篇文章埋的坑,在这里就踩到了,囧 )

```go
//TaskService interface e
type TaskService interface {
	CreateTask(taskName string) Task
	IsATask(taskName string) bool
	ChangeTask(changingTask ToChangeTask) Task
}
```
修改完毕, 运行测试, 通过!

```bash
Running tool: /usr/local/go/bin/go test -timeout 30s -coverprofile=/var/folders/yn/h224dtzx2bq3pdhhgv4jt93r0000gn/T/vscode-gocVUxCQ/go-code-cover kanban/ban

ok  	kanban/ban	0.015s	coverage: 94.4% of statements

```

# To be continue

到此为止,我学到了:

1. 引用别的包的时候需要显式指定包内对象
2. 开发给包外使用的接口需要大写开头