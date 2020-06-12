---
layout: mobile
title:  First Learn on Go Language 4 config 
category: Tech
---

Go语言初学记 （四）:  配置篇
=====================

# 原文再续

上一篇 [Go语言初学记 (三）: 踩坑篇](http://antinomy.top/2020/05/19/Tech-2020-2020-05-29-FirstLearnOnGo3/) 介绍实际项目中踩到的一些坑. 经过一些的功能实现,初步功能已经可用了.


# 前言

一个成熟的工程都需要配置文件,为了 kanban 项目更加灵活,我开始引入配置文件 *conf.json*. 
(采用json格式是因为它比较轻和通用)

# 配置文件
内容如下:

conf/conf.json

```json
{
    "BanSize": 4,
    "BanConfigs": [
        {
            "Name": "Todo",
            "Folder": "01-Todo",
            "SupportShortMode": false
        },
        {
            "Name": "Doing",
            "Folder": "02-Doing",
            "SupportShortMode": false
        },
        {
            "Name": "Hold",
            "Folder": "03-Hold",
            "SupportShortMode": false
        },
        {
            "Name": "Done",
            "Folder": "04-Done",
            "SupportShortMode": true
        }
    ]
}

```
BanSize 为看板列数,BanConfig对应每一个列的相关属性

# 配置结构
编写与其对应的结构体

``` go
package conf

type BanConfig struct {
	Name             string
	Folder           string
	SupportShortMode bool
}

type Jconf struct {
	BanSize    int
	BanConfigs []BanConfig
}


```

# 编写测试用例

``` go
unc TestReadConfig(t *testing.T) {
	var config kc.Jconf = loadConfig()

	var banconfigs []kc.BanConfig = config.BanConfigs

	if len(banconfigs) != config.BanSize {
		t.Log(banconfigs)
		t.Errorf("Failed")
	}

	if banconfigs[0].Name != "Todo" {
		t.Log(banconfigs[0].Name)
		t.Errorf("Failed")
	}

	if banconfigs[0].Folder != "01-Todo" {
		t.Log(banconfigs[0].Folder)
		t.Errorf("Failed")
	}

	if banconfigs[3].SupportShortMode != true {
		t.Log(banconfigs[3].SupportShortMode)
		t.Errorf("Failed")
	}
}
```

# 编写实现代码

```go
package ban

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	kc "kanban/conf"
	"log"
)


func loadConfig() kc.Jconf {
	var configPath = ".././conf/conf.json"

	_, err := os.Stat(configPath)
	if os.IsNotExist(err) {
		configPath = "./conf/conf.json"
	}

	var config kc.Jconf = readJsonConfig(configPath)

	return config
}

func readJsonConfig(filePath string) kc.Jconf {

	data, err := ioutil.ReadFile(filePath)
	if err != nil {
		log.Fatal(err)
	}

	// json data
	var result kc.Jconf

	// unmarshall it
	err = json.Unmarshal(data, &result)
	if err != nil {
		log.Fatal("error:", err)
	}

	return result
}

```

* Tips:

* loadConfig()里面兼容了从包内调用和应用目录下调用 2 种方式, 方便单元测试和实际使用.
* 采用"io/ioutil"来读取文件
* 采用"encoding/json"来读取 json并转化 banconfig 结构.


# 运行单元测试

经过一系列的编写和测试,最终通过测试

```bash
Running tool: /usr/local/go/bin/go test -timeout 30s kanban/ban -run ^(TestReadConfig)$

ok  	kanban/ban	0.011s

```

# To be continue

到此为止,我学到了:

1. 如何从 io 读取文件
2. 如何读取 json 结构的数据
3. 配置文件的相对路径因为调用方不一样,而需要做适配
