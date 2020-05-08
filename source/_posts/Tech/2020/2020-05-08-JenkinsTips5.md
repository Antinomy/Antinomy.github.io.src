---
layout: mobile
title:  Jenkins Tips , About Artifact 2
category: Tech
---

Jenkins插件小贴士 (五)  About Artifact 2
=====================

# 历史问题
上一篇<<[Jenkins插件小贴士 (四)  About Artifact](http://antinomy.top/2020/03/25/Tech-2020-2020-03-25-JenkinsTips4/)>>
介绍了如何将构建完的二进制物(JAR/WAR)上传到Maven私库,但还是有可以改进的地方.


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

比如:
* GROUP ID和ARTIFACT ID这些都是硬编码的

    每次发布新版本都需要修改Jenkinsfile

* 上传到Maven私服的JAR需要多一个POM文件来描述才能顺利被客户端的Maven识别和下载.

    如果不是通过mvn deploy的方式是不会自动产生pom文件的,但采用mvn deploy的方式又需要在maven setting暴露私库账号和密码.

# 新思路

  参考了 github上的[Jenkins集成Nexus demo项目](https://github.com/zeyangli/springboot-helloworld.git ), 有了新的想法:

  * 利用Jenkins ci 读取项目里的POM.xml文件
  * 代码生成对应的xx.pom文件
  * 上传到私库

# 前置条件
  * 安装插件 ：Pipeline Utility Steps
    通过插件[Pipeline Utility Steps](https://www.jenkins.io/doc/pipeline/steps/pipeline-utility-steps/)
    可以很方便地使用readMavenPom命令读取pom文件

  * 设置Jenkins权限 scriptApproval : 允许Approval
    Jenkins执行groovy脚本的时候会出错,是因为权限问题,需要设置对应的权限才能让脚本顺利写文件到硬盘里.

 # 具体实现

 * 定义POM文件所需变量

 ``` groovy
environment {
       NEXUS_URL="nexus.xxx.com"
       NEXUS_REPOSITOR="maven-xxx"

       GROUP_ID = ""
       VERSION = ""
       ARTIFACT_ID = ""
   }
 ```

 * 使用readMavenPom命令读取POM.xml文件

  ``` groovy
 script {
      def pom = readMavenPom file: 'pom.xml'
      echo pom.toString()

      GROUP_ID = pom.groupId
      VERSION = pom.version
      ARTIFACT_ID = pom.artifactId
  }
  ```

  * 定义xx.pom文件模板和替换变量,生成xx.pom文件

 ``` groovy
 script {

    def pomContent = """
  <?xml version="1.0" encoding="UTF-8"?>
  <project xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd" xmlns="http://maven.apache.org/POM/4.0.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
      <modelVersion>4.0.0</modelVersion>
      <groupId>${GROUP_ID}</groupId>
      <artifactId>${ARTIFACT_ID}</artifactId>
      <version>${VERSION}</version>
      <description>POM was created from jenkins-ci</description>
  </project>
    """

    writeFile file: "target/${ARTIFACT_ID}-${VERSION}.pom", text: pomContent
  }

 ```

 # 完整DSL

 ``` groovy

  pipeline {
      agent any

      environment {
          NEXUS_URL="nexus.xxx.com"
          NEXUS_REPOSITOR="maven-xxx"

          GROUP_ID = ""
          VERSION = ""
          ARTIFACT_ID = ""

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
                  sh 'ls -l target/'
              }
          }

          stage('Publish JAR') {

                      steps {
                          script {
                              def pom = readMavenPom file: 'pom.xml'
                              echo pom.toString()

                              GROUP_ID = pom.groupId
                              VERSION = pom.version
                              ARTIFACT_ID = pom.artifactId
                          }

                          script {

                              def pomContent = """
          <?xml version="1.0" encoding="UTF-8"?>
          <project xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd" xmlns="http://maven.apache.org/POM/4.0.0"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
              <modelVersion>4.0.0</modelVersion>
              <groupId>${GROUP_ID}</groupId>
              <artifactId>${ARTIFACT_ID}</artifactId>
              <version>${VERSION}</version>
              <description>POM was created from jenkins-ci</description>
          </project>

                              """

                              writeFile file: "target/${ARTIFACT_ID}-${VERSION}.pom", text: pomContent
                          }


                          nexusArtifactUploader(
                                  nexusVersion: 'nexus3',
                                  protocol: 'https',
                                  nexusUrl: NEXUS_URL,
                                  groupId: "${GROUP_ID}",
                                  version: "${VERSION}",
                                  repository: NEXUS_REPOSITOR,
                                  credentialsId: 'nexus-cre-id',
                                  artifacts: [
                                          [artifactId: "${ARTIFACT_ID}",
                                           classifier: '',
                                           file      : "target/${ARTIFACT_ID}-${VERSION}.jar",
                                           type      : 'jar'],
                                          [artifactId: "${ARTIFACT_ID}",
                                           classifier: '',
                                           file      : "target/${ARTIFACT_ID}-${VERSION}.pom",
                                           type      : 'pom']
                                  ]
                          )
                      }
                  }

      }
  }

 ```

# 权限问题
执行job的时候会遇到错误: Scripts not permitted to use method xxx
![img](/img/2020/Jenkins-5-1.png)

这个时候需要管理员去  Jenkins >> ScriptApproval 去approval对应的脚本.


# End
* 此过程需要不断调试直至Job顺利完成
* 自此就可以把项目把maven构建和上传私库2个动作分开,降低开发人员的入手难度.
