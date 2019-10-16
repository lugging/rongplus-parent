SpringBoot SpringCloud 工程

目录：src/main/resources

> bootstrap.properties 

配置文件配置应用名称，端口号等信息，为启动脚本提供对应参数

配置参数如下:

```
server.port=[应用端口号]
spring.application.name=${project.artifactId}
```

> version.txt

应用版本信息，为启动脚本提供对应参数

配置参数如下:
```
version=${project.version}
```












bootstrap与application
bootstrap.yml（bootstrap.properties）先加载
application.yml（application.properties）后加载
bootstrap.yml 用于应用程序上下文的引导阶段。
bootstrap.yml 由父Spring ApplicationContext加载。
父ApplicationContext 被加载到使用 application.yml 的之前。