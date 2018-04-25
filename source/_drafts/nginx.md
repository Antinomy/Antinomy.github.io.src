---
layout: mobile
title:  nginx exp
category: Tech
---

nginx exp
=====================

# img
![img](/img/2017/nginx.png)


# 配置Tips

## 访问目录

```
  location /aDir{
            autoindex on;
			}
			
```

## 代理指向

```
   location /aPath {
           proxy_pass http://127.0.0.1:8081;
         }
```




# 日志切割
linux , logrotate， anacrontab

## logrotate
/etc/logrotate.d

```shell
/aPath/nginx/logs/*.log {
    daily
    dateext
    rotate 90
    sharedscripts
    su root hk002
    postrotate
        kill -USR1 `cat /aPath/nginx/logs/nginx.pid`
    endscript
}
```
## anacrontab
/etc/anacrontab
