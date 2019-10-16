#!/bin/sh

prop ()
{
    grep "${1}" ${2} | cut -d'=' -f2 | sed 's/\r//'
}

cd `dirname $0`
BIN_DIR=`pwd`

# 返回到上�?级项目根目录路径
cd ..

# 打印项目根目录绝对路径
# `pwd` 执行系统命令并获得结果
BASE_PATH=`pwd`

# 外部配置文件绝对目录,如果是目录需�?/结尾，也可以直接指定文件
# 如果指定的是目录,spring则会读取目录中的有配置文件
CONF_DIR=${BASE_PATH}/conf/

# 项目名称
SERVER_NAME=$(prop "spring.application.name" "${CONF_DIR}/application.properties")

# 项目版本�?
SERVER_VERSION=$(prop "version" "${CONF_DIR}/version.txt")

#获取应用的端口号
SERVER_PORT=$(prop "server.port" "${CONF_DIR}/application.properties")

# 项目启动jar包名
JAR_NAME="${SERVER_NAME}-${SERVER_VERSION}.jar"

PID=$(ps -ef | grep "${JAR_NAME}" | grep -v grep | awk '{ print $2 }')
if [ -z "$PID" ] ; then
        echo ${SERVER_NAME} is already stopped
        exit -1;
fi

echo "The ${SERVER_NAME} (${PID}) is running..."

kill ${PID}

echo -e "Shutdown the $SERVER_NAME ..."
COUNT=1
while [ $COUNT -gt 0 ]; do
  echo -e ".\c"
  sleep 1
  if [ -n "$SERVER_PORT" ]; then
    COUNT=`netstat -an | grep "$SERVER_PORT" | wc -l`
  else
    COUNT=`ps -f | grep java | grep "$CONF_DIR" | awk '{print $2}' | wc -l`
  fi
  if [ $COUNT -lt 1 ]; then
    break
  fi
done

echo ${SERVER_NAME} stopped successfully
