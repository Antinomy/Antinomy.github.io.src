---
layout: mobile
title:  First Learn on Go Language 5 execution 
category: Tech
---

Go语言初学记 （四）:  运行篇
=====================

# 原文再续

上一篇 [Go语言初学记 (四）: 配置篇](http://antinomy.top/2020/05/29/Tech-2020-2020-06-12-FirstLearnOnGo4/) 介绍了如何在实际项目中使用配置文件,来实现灵活配置功能.
看板的基本功能都已实现,接下来是做一些扩展功能.


# 绘制看板
通过 [gotabulate](https://github.com/bndr/gotabulate) 可以很方便地在命令行的模式下打印表格,利用这个功能,就可以实现看板的看了.

![img](/img/2020/go-5-1.png)

为了给看板提供灵活的展示形态, 设计了用于展示数据的数据结构KanSpec.

``` go
// KanSpec vo
type KanSpec struct {
    hearders      []string
    maxCellSize   int
    owners        []string
    priorities    []string
    projects      []string
    deadlineTypes []string
    rows          [][]interface{}
    taskMap       map[string]kt.Task
    banMap        map[string]Ban
}

func Kan(kanban Kanban, taskItem kt.TaskItem) {

    var kanSpec KanSpec = getKanSpec(kanban, taskItem)

    var ts kt.TaskService = new(kt.FileWay)

    tskItem := string(taskItem)

    var viewType = ts.FillBlank("Kan View : "+tskItem, kanSpec.maxCellSize)

    var today = ts.FillBlank("Today    : "+time.Now().Format("0102"), kanSpec.maxCellSize)

    println(viewType)
    println(today)

    // Create an object from 2D interface array

    table := gotabulate.Create(kanSpec.rows)

    table.SetHeaders(kanSpec.hearders)

    // Set the Empty String (optional)
    // t.SetEmptyString("")

    // Set Align (Optional)
    table.SetAlign("left")

    // Set Max Cell Size
    table.SetMaxCellSize(kanSpec.maxCellSize)

    // Turn On String Wrapping
    table.SetWrapStrings(true)

    // Print the result: grid, or simple
    fmt.Println(table.Render("grid"))

}
```
gotabulate的用起来也很简单,设置好表头,宽度之类就能开箱即用了.

# 联动系统编辑器
通过命令管理任务的时候, 使用系统的命令,可以很方便的调用起系统设定的编辑器. 

比如我打开一个的任务的时候, 自动调用 vscode 来编辑任务文件. 
这个功能主要是通过"os/exec"来实现:


``` go

    // absPath 任务文件的路径

    cmd := exec.Command("open", "-n", "-b", "com.microsoft.VSCode", "--args", absPath)
    cmd.Env = os.Environ()

    err := cmd.Run()
    if err != nil {
        fmt.Println("EXECUTE COMMAND ERROR : " + err.Error())
    }
```

# 版本管理

看板G的设计理念是通过最简单的系统文件IO来管理任务的数据和状态, 为了保证数据不会丢失和历史可回溯, 我引进了 GIT 来进行版本管理.

GIT如何使用不在此处展开,毕竟这是每个程序员该有的基本素养. :)

为了让同步做得更方便一点, 我设计了主动同步和被动同步.

## 脚本实现

编辑一个简单的 shell 脚本, 可以实现代码的一键提交+推送

新建文件lazyGit.sh, 内容如下:

```bash
#!/bin/sh

current_path=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)

echo "Git working on path : $current_path"

cd $current_path

git add -A

git commit  -m "$1"

git push origin master
```
## 主动同步

通过看板命令输入指定命令来触发主动同步, 比如当我输入 g 的时候就触发同步.

```go

func lasyGit(execPath string) {
    var lasyGitShell = execPath + "/lazyGit.sh"
    var commitStr = "GitSyncOn:[" + time.Now().Format("2006-01-02 15:04:05"+"]")
    _, err := kb.Exec(lasyGitShell, commitStr)

    if err != nil {
        println(err)
    }
}
```

## 被动同步

一开始我设计被动同步的策略是统计指定命令的次数, 当次数达到指定值的时候就触发同步.

这里使用了关键字 go 来启用多线程,避免因为同步问题影响看板使用.

```go

const autoGitCounter int = 5 
var gitcouter int = 0

func autoGit(execPath string) {

    if gitcouter >= autoGitCounter {
        gitcouter = 0
        go lasyGit(execPath)
        return
    }

    gitcouter++
}

```

后面我改变的策略, 统计本地改动过的文件数量,超过指定值的时候才触发同步

编写一个脚本统计文件数量,新建文件countGit.sh 内容如下:

```bash
#!/bin/sh

current_path=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)

cd $current_path

git status -s | wc -l

```

修改autoGit代码,通过 exec 调用脚本, 处理非数字字符.

```go


func autoGit(execPath string) {

    var countResult = countGit(execPath)

    countResult = strings.Trim(countResult, "\n")
    countResult = strings.TrimSpace(countResult)

    changeFileNum, err := strconv.Atoi(countResult)

    if err != nil {
        fmt.Println(err)
    }

    gitcouter = changeFileNum

    if gitcouter >= autoGitCounter {
        gitcouter = 0
        go lasyGit(execPath)
        return
    }
}

func countGit(execPath string) string {
    var countGitShell = execPath + "/countGit.sh"

    out, err := kb.Exec(countGitShell)
    if err != nil {
        fmt.Println(err)
    }

    return out
}
```

至此看板数据就很方便的同步到指定的私有仓库了, 通过对应的 git 手机客户端,可以很方便查看任务数据.

![img](/img/2020/go-5-2.png)

# 命令行交互

一开始读取命令的输入是通过"bufio"来实现.

```go

input := bufio.NewScanner(os.Stdin)

CommandMode:
    for input.Scan() {
        // default
        kanban.IsShortMode = IsShortMode

        var cmds Cmds = buildCmd(input.Text())

        switch cmds.cmdType {
        case EXIT:
            break CommandMode
        case .......
        }
    }

```

但是这样用起来很不方便, 缺点很多:
* 无移动光标
* 不能输错
* 没有命令行历史,不能调用历史命令
* 没有提示

为此我引进了一个很好用的命令行交互插件 [go-prompt](https://github.com/c-bata/go-prompt)

通过 go-prompt可以很好解决以上缺点.


```go

import "github.com/c-bata/go-prompt"


    kanbanPrompt := prompt.New(
        dummyExecutor,
        completer,
        prompt.OptionPrefix("InputCmd $"),
        prompt.OptionHistory([]string{"exit", "help"}),
        prompt.OptionPrefixTextColor(prompt.Yellow),
    )
    
CommandMode:
    for {
        inputCmd := kanbanPrompt.Input()
        inputCmd = strings.TrimLeft(inputCmd, " ")
        var cmds Cmds = buildCmd(inputCmd)

        switch cmds.cmdType {
        case EXIT:
            break CommandMode
        case .......
        }
    }

func completer(d prompt.Document) []prompt.Suggest {
    suggest := []prompt.Suggest{
        {Text: "o [open]", Description: "o [open] $taskKey "},
        {Text: "s [short / shortmode]", Description: "short mode turn on/off"},
        {Text: "c [create]", Description: "c [create] taskname $banPrefix  "},
        {Text: "g [git]", Description: "commit & push to git "},
        {Text: "ct [changetask]", Description: "ct [changetask] $taskKey $TaskItem context"},
        {Text: "cb [changeban]", Description: "cb [changeban] $taskKey $banPrefix "},
        {Text: "k i", Description: "priority"},
        {Text: "k o", Description: "owner"},
        {Text: "k j", Description: "project"},
        {Text: "k d", Description: "deadline"},
        {Text: "h [help]", Description: "help doc"},
        {Text: "e [exit]", Description: "exit kanban"},
        {Text: "k [kan]", Description: "k [kan] <i / o / j / d>"},
        {Text: "r [rekan]", Description: "refresh kanban"},
    }
    return prompt.FilterHasPrefix(suggest, d.GetWordBeforeCursor(), true)
}

func dummyExecutor(in string) {}


```

引入go-prompt,编写提示命令,运行效果如下:

![img](/img/2020/go-5-3.png)

# End

从此,我的看板工具投入使用, 用于管理我个人的任务.

我的 go 语言初学记也告一段落, 看了一下Github上的项目, 71 commits还是成就感满满的. :)

