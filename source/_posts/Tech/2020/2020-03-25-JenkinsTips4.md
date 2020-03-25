---
layout: mobile
title:  Jenkins Tips , About Artifact
category: Tech
---

Jenkins插件小贴士 (四)  About Artifact
=====================


前3篇介绍了如何用Jenkins来实现日常的CI和测试,本篇来介绍一下制品相关的.

项目构建的时候会产生各种制品,像JAR包,WAR包等. 简单的项目直接部署上去服务器就行了.
复杂一点的项目,如采用微服务架构的项目,通常后有许多的子项目,有些项目会成为公用的包.
这里会涉及到公用包的管理.如果人肉拷贝到各个下游项目,会引发很多同步的问题,通过maven私服来管理会是比较方便的做法.

# 公用包上传Maven私库
NEXUS是比较常见的maven私服,本文假设你的私服是现成的,并有了可以上传文件的账号.
下面会介绍如何通过Jenkins的插件来实现自动构建并上传到NEXUS私服.

## 安装插件Nexus Artifact Uploader
首先确保Jenkins已经安装了插件  [Nexus Artifact Uploader](https://plugins.jenkins.io/nexus-artifact-uploader/)

![img](/img/2020/Jenkins-4-1.png)

## 编写Pipeline DSL

本文以一个Java ip分析工具的maven项目为例,介绍如何通过编写pipeline,一步步实现JAR上传到私库.

![img](/img/2020/Jenkins-4-2.png)

项目构建完之后,需要把JAR文件和POM文件上传到私服上去.

### 在Pipeline定义好环境变量

配置好nexus的地址,仓库,以及项目的group id,文件名等.

``` groovy
    environment {
         NEXUS_URL="nexus.xxx.com"
         NEXUS_REPOSITOR="maven-xxx"
         GROUP_ID="org.life-easier"
         VERSION="1.0.0"

         FILE_PATH = "target"
         FILE_NAME = "iptools-${VERSION}.jar"

     }
```

### 拉取代码(Get Code)

拉取Git上master分支代码,credentialsId是预先配置好在Jenkins上的凭据Id.

``` groovy

      stage('Get Code') {
             steps {
                 git branch: "master", credentialsId: 'xxx', url: "https://gitlab.xxx.com/life-easier/iptools.git"
             }
         }


```

### 构建JAR(Build JAR)
通过maven命令构建JAR

``` groovy

      stage('Build JAR') {
             steps {
                 sh 'mvn clean package'
                 sh 'ls -l ${FILE_PATH}/${FILE_NAME}'
             }
         }


```

### 发布JAR到NEXUS (Publish JAR)

构建完成之后上传JAR到NEXUS上. 这里需注意的是:

* credentialsId需要预先配置在Jenkins的凭证上,方式和增加Git账号凭证一样.
* artifacts 可以配置多个上传文件,例如jar和pom文件, 在file里定义了本地路径 .


``` groovy

stage('Publish JAR') {

             steps {
                 nexusArtifactUploader(
                         nexusVersion: 'nexus3',
                         protocol: 'https',
                         nexusUrl: NEXUS_URL,
                         groupId: GROUP_ID,
                         version: VERSION,
                         repository: NEXUS_REPOSITOR,
                         credentialsId: 'nexus-cre-id',
                         artifacts: [
                                 [artifactId: 'iptools',
                                  classifier: '',
                                  file      : 'target/iptools-' + version + '.jar',
                                  type      : 'jar'],
                                 [artifactId: 'iptools',
                                  classifier: '',
                                  file      : 'target/classes/iptools-' + version + '.pom',
                                  type      : 'pom']
                         ]
                 )
             }
         }


```


完整DSL如下

``` groovy

 pipeline {
     agent any

     environment {
         NEXUS_URL="nexus.xxx.com"
         NEXUS_REPOSITOR="maven-xxx"
         GROUP_ID="org.life-easier"
         VERSION="1.0.0"

         FILE_PATH = "target"
         FILE_NAME = "iptools-${VERSION}.jar"

     }

     stages {

         stage('Get Code') {
             steps {
                 git branch: "master", credentialsId: 'xxx', url: "https://gitlab.xxx.com/life-easier/iptools.git"
             }
         }

         stage('Build JAR') {
             steps {
                 sh 'mvn clean package'
                 sh 'ls -l ${FILE_PATH}/${FILE_NAME}'
             }
         }

         stage('Publish JAR') {

             steps {
                 nexusArtifactUploader(
                         nexusVersion: 'nexus3',
                         protocol: 'https',
                         nexusUrl: NEXUS_URL,
                         groupId: GROUP_ID,
                         version: VERSION,
                         repository: NEXUS_REPOSITOR,
                         credentialsId: 'nexus-cre-id',
                         artifacts: [
                                 [artifactId: 'iptools',
                                  classifier: '',
                                  file      : 'target/iptools-' + version + '.jar',
                                  type      : 'jar'],
                                 [artifactId: 'iptools',
                                  classifier: '',
                                  file      : 'target/classes/iptools-' + version + '.pom',
                                  type      : 'pom']
                         ]
                 )
             }
         }

     }
 }

```

# 通过Jenkins的构建调试Job

刚开始编写pipeline可能遇到很多小问题,通常是语法问题和配置问题居多.


 ![img](/img/2020/Jenkins-4-3.png)

 调试成功之后,检查NEXUS私服仓库 ,done.

 ![img](/img/2020/Jenkins-4-4.png)



# End

很多项目是通过Maven deploy的方式来实现制品上传, 这样需要把nexus的配置(服务器地址,账号,密码等)写在POM文件里.

本文提供了另外一种方式,通过pipeline的方式解耦了构建和发布,也更容易推广到别的项目里.




