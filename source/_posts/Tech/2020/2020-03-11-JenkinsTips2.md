---
layout: mobile
title:  Jenkins Tips , CI with Pipeline
category: Tech
---

Jenkins插件小贴士 (二) CI with Pipeline
=====================

![img](/img/2020/Jenkins-6.png)

上篇简单介绍了如果通过jenkins ui来构建一个java web的过程来实现CI,

Jenkins后面提供了一个新的方式来实现同样的功能: Pipeline

Pipeline 是通过DSL的方式是编写Job的, 某种意义来说,是通过写代码的方式来实现Job,而不是UI操作.
这样的方式比UI更复杂,有一点的学习曲线去学习DSL的语法, 引入复杂性之后的好处就是,可以通过代码管理的方式来管理Job,
通过参数化,逻辑结构等应用,可以写成更加强大和多功能的Job,也带来多人协作的可能性.

# 无论通过UI还是Pipeline,CI的流程都是一样.
持续集成的常见的流程如下:
1. 代码拉取
2. 代码自动化构建
3. 发布构建后的包到目标服务器
4. 在目标服务器执行发布流程

# 创建Pipeline工程

![img](/img/2020/Jenkins-7.png)

Pipeline工程不同UI工程,只能新创建的时候选择.
让一个脚本更加通用的方式就是把所有需要变化的地方都有参数去控制,例如控制拉取代码的分支.

![img](/img/2020/Jenkins-8.png)


# 编写Pipeline DSL
然后就是Pipeline的编写了,方式有2种:
1. 直接在UI上写脚本
2. 拉取代码库的文件

方式1不推荐,因为这样和直接通过UI的方式差别不大.
推荐用方式2, 这样的方式需要单独创建一个代码库来放Pipeline的脚本,这样就可以进行版本控制了.

![img](/img/2020/Jenkins-9.png)

在代码库创建一个文件叫 Jenkinsfile,编写DSL如下:

```groovy

 pipeline {
    agent any

        environment {
         FILE_NAME = "yourProject.war"
         FILE_PATH = "target"
     }

    stages {

         stage('Get Code'){
          steps {
             git branch: "${BRANCH}",credentialsId: 'yourGitCid', url: "https://yourgitlab.com/yourProject.git"
          }
         }

         stage('Maven Build') {
             steps {
             sh 'mvn clean package -DskipTests'
         }
     }

         stage('Deploy WAR'){
             steps {
                 sshPublisher(
                     continueOnError: false,
                     failOnError: true,
                     publishers: [
                         sshPublisherDesc(
                         configName: "yourServerConfig",
                         verbose: true,
                         transfers: [
                             sshTransfer(
                                 sourceFiles: "${FILE_PATH}/${FILE_NAME}",
                                 removePrefix: "${FILE_PATH}/",
                                 remoteDirectory: "tomcat/deployment",
                                 execCommand: """
                                     cd /app/tomcat &&
                                     chmod 757 deployment/${FILE_NAME} &&
                                     sh ./stopTomcat.sh &&
                                     sleep 10 &&
                                     sh deployWAR.sh yourProject dev &&
                                     sh bin/startup.sh &&
                                     sh bin/catalina.sh version
                                 """
                             )
                         ])
                     ]
                 )
             }
         }

    }
 }

```

具体实现步骤和方式与上一篇UI实现的是一样的, 唯一的区别就是需要学习Pipeline的语法.
例如通过:

    environment来实现环境变量
    stage来实现步骤
    sh 执行命令,maven构建,文件操作等
    sshPublisher 上传二进制包和执行部署脚本
    ${xxx} 实现参数化

等等 ,更多的功能随之学习内容的增加而解锁.

这样的方式更复杂,也更灵活.
编写不方便,调试不方便,移植方便,回溯也方便.

选择的时候需根据个人情况去权衡,个人而言更倾向Pipeline的方式,
通过Pipeline的UI也很直观的可以看出各个步骤所需要时间和变化.



