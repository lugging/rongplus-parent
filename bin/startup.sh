#!/bin/bash

#======================================================================
# 项目启动shell脚本
# boot目录: spring boot jar
# conf目录: 配置文件目录
# logs目录: 项目运行日志目录
# logs/spring-boot-assembly_startup.log: 记录启动日志
# logs/back目录: 项目运行日志备份目录
# nohup后台运行
#
#======================================================================
cygwin=false
darwin=false
os400=false
case "`uname`" in
CYGWIN*) cygwin=true;;
Darwin*) darwin=true;;
OS400*) os400=true;;
esac
error_exit ()
{
    echo "ERROR: $1 !!"
    exit 1
}

prop ()
{
    grep "${1}" ${2} | cut -d'=' -f2 | sed 's/\r//'
}

export JAVA_HOME=/opt/jdk1.8.0_131/
export JAVA="${JAVA_HOME}bin/java"

if [ -z "$JAVA_HOME" ]; then
  if $darwin; then

    if [ -x '/usr/libexec/java_home' ] ; then
      export JAVA_HOME=`/usr/libexec/java_home`

    elif [ -d "/System/Library/Frameworks/JavaVM.framework/Versions/CurrentJDK/Home" ]; then
      export JAVA_HOME="/System/Library/Frameworks/JavaVM.framework/Versions/CurrentJDK/Home"
    fi
  else
    JAVA_PATH=`dirname $(readlink -f $(which javac))`
    if [ "x$JAVA_PATH" != "x" ]; then
      export JAVA_HOME=`dirname $JAVA_PATH 2>/dev/null`
    fi
  fi
  if [ -z "$JAVA_HOME" ]; then
        error_exit "Please set the JAVA_HOME variable in your environment, We need java(x64)! jdk8 or later is better!"
  fi
fi

echo $(${JAVA} -version)

# 默认当前环境是dev
PROFILES_ACTIVE="dev"
if [ $# -eq 1 ]; then
    if [[ "$1" != "jmx" ]] && [[ "$1" != "debug" ]] && [[ "$1" != "status" ]]; then
        PROFILES_ACTIVE=$1
    fi
fi
if [ $# -eq 2 ]; then
        PROFILES_ACTIVE=$2
fi

if [ "$1" != "status" ]; then
    echo "profiles.active : ${PROFILES_ACTIVE} "
fi

# bin目录绝对路径
cd `dirname $0`
BIN_DIR=`pwd`
# 返回到上级项目根目录路径
cd ..

# 打印项目根目录绝对路
# `pwd` 执行系统命令并获得
BASE_PATH=`pwd`

# 外部配置文件绝对目录,如果是目录需/结尾，也可以直接指定文件
# 如果指定的是目录,spring则会读取目录中的有配置文
CONF_DIR=${BASE_PATH}/conf/

# 项目名称
#SERVER_NAME=`sed -n '/spring.application.name/!d;s/.*=//p' ${CONF_DIR}/bootstrap.properties`
SERVER_NAME=$(prop "spring.application.name" "${CONF_DIR}/bootstrap.properties")

# 项目版本
SERVER_VERSION=$(prop "version" "${CONF_DIR}/version.txt")

#获取应用的端口号
SERVER_PORT=$(prop "server.port" "${CONF_DIR}/bootstrap.properties")

# 项目启动jar包名
JAR_NAME="${SERVER_NAME}-${SERVER_VERSION}.jar"

echo "${JAR_NAME}"
echo "${CONF_DIR}"

# 项目日志输出绝对路径
LOG_DIR=${BASE_PATH}"/logs"
LOG_FILE="${SERVER_NAME}_console.log"
LOG_PATH="${LOG_DIR}/${LOG_FILE}"
# 日志备份目录
LOG_BACK_DIR="${LOG_DIR}/back/"

# 项目启动日志输出绝对路径
LOG_STARTUP_PATH="${LOG_DIR}/${SERVER_NAME}_startup.log"

# 当前时间
NOW=`date +'%Y-%m-%m-%H-%M-%S'`
NOW_PRETTY=`date '+%Y-%m-%m %H:%M:%S'`

# 启动日志
STARTUP_LOG="================================================begin ${NOW_PRETTY} ================================================.\n"

# 如果logs文件夹不存在,则创建文件夹
if [[ ! -d "${LOG_DIR}" ]]; then
  mkdir "${LOG_DIR}"
fi

# 如果logs/back文件夹不存在,则创建文件夹
if [[ ! -d "${LOG_BACK_DIR}" ]]; then
  mkdir "${LOG_BACK_DIR}"
fi

# 如果项目运行日志存在,则重命名备份
if [[ -f "${LOG_PATH}" ]]; then
	mv ${LOG_PATH} "${LOG_BACK_DIR}/${SERVER_NAME}_back_${NOW}.log"
fi

#==========================================================================================
# JVM Configuration
# -Xmx2048m:设置JVM大可用内存为256m,根据项目实际情况而定，建议最小和
# -Xms2048m:设置JVM初始内存。此值可以设置与-Xmx相同,以避免每次垃圾回收完成后JVM重新分配内存
# -Xmn1024m:设置年轻代大小为512m。整个JVM内存大小=年轻代大�? + 年�?�代大小 + 持久代大小
#          持久代一般固定大小为64m,以增大年轻代,将会减小年�?�代大小。此值对系统性能影响较大,Sun官方推荐配置为整个堆�?3/8
# -XX:MetaspaceSize=512m:存储class的内存大�?,该�?�越大触发Metaspace GC的时机就越晚
# -XX:MaxMetaspaceSize=512m:限制Metaspace增长的上限，防止因为某些情况导致Metaspace无限的使用本地内存，影响到其他程
# -XX:-OmitStackTraceInFastThrow:解决重复异常不打印堆栈信息
#==========================================================================================

if [ "$1" = "debug" ]; then
  JAVA_OPTS=" ${JAVA_OPTS} -Xdebug -Xnoagent -Djava.compiler=NONE -Xrunjdwp:transport=dt_socket,address=8000,server=y,suspend=n "
fi
if [ "$1" = "jmx" ]; then
  JAVA_OPTS=" ${JAVA_OPTS} -Dcom.sun.management.jmxremote.port=1099 -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false "
fi
BITS=`java -version 2>&1 | grep -i 64-bit`
if [ -n "$BITS" ]; then
  JAVA_OPTS=" ${JAVA_OPTS} -server -Xms2g -Xmx2g -Xmn1g -Xss256k -XX:MetaspaceSize=128m -XX:MaxMetaspaceSize=320m"
  JAVA_OPTS=" ${JAVA_OPTS} -XX:-OmitStackTraceInFastThrow -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=${BASE_PATH}/logs/java_heapdump.hprof"
  JAVA_OPTS=" ${JAVA_OPTS} -XX:-UseLargePages"
else
  JAVA_OPTS=" ${JAVA_OPTS} -server -Xms512m -Xmx512m -XX:PermSize=128m -XX:SurvivorRatio=2 -XX:+UseParallelGC "
fi

JAVA_OPTS=" ${JAVA_OPTS} -Djava.awt.headless=true -Djava.net.preferIPv4Stack=true "
JAVA_OPTS=" ${JAVA_OPTS} -Djava.security.egd=file:/dev/urandom"
JAVA_OPTS=" ${JAVA_OPTS} -XX:-OmitStackTraceInFastThrow"
JAVA_OPTS=" ${JAVA_OPTS} -Xloggc:${LOG_DIR}/${SERVER_NAME}_gc.log -verbose:gc -XX:+PrintGCDetails -XX:+PrintGCDateStamps -XX:+PrintGCTimeStamps -XX:+UseGCLogFileRotation -XX:NumberOfGCLogFiles=10 -XX:GCLogFileSize=100M"
JAVA_OPTS=" ${JAVA_OPTS} -Drongplus.home=${BASE_PATH}"
JAVA_OPTS=" ${JAVA_OPTS} -Drongplus.service.name=${SERVER_NAME}"

BOOT_OPTS=" ${BOOT_OPTS} --spring.config.location=${CONF_DIR} "
BOOT_OPTS=" ${BOOT_OPTS} --spring.profiles.active=${PROFILES_ACTIVE}"
BOOT_OPTS=" ${BOOT_OPTS} --logging.config=${CONF_DIR}rongplus-logback.xml"


#CONFIG_FILES=" -Dlogging.path=$LOGS_DIR -Dlogging.config=$CONF_DIR/log4j2.xml -Dspring.config.location=$CONF_DIR/application.properties "

#=======================================================
# 将命令启动相关日志追加到日志文件
#=======================================================
# 输出项目名称
STARTUP_LOG="${STARTUP_LOG}application name: ${SERVER_NAME}\n"
# 打印端口号
STARTUP_LOG="${STARTUP_LOG}application port : ${SERVER_PORT}\n"
# 输出jar包名
STARTUP_LOG="${STARTUP_LOG}application jar name: ${JAR_NAME}\n"
# 输出项目bin路径
STARTUP_LOG="${STARTUP_LOG}application bin path: ${BIN_DIR}\n"
# 输出项目根目
STARTUP_LOG="${STARTUP_LOG}application root path: ${BASE_PATH}\n"
# 打印日志路径
STARTUP_LOG="${STARTUP_LOG}application log path: ${LOG_PATH}\n"
# 打印配置路径
STARTUP_LOG="${STARTUP_LOG}application conf path: ${CONF_DIR}\n"
# 打印JVM配置
STARTUP_LOG="${STARTUP_LOG}application JAVA_OPT : ${JAVA_OPTS}\n"
# 打印启动命令
STARTUP_LOG="${STARTUP_LOG}application background startup command: nohup ${JAVA} ${JAVA_OPTS} -jar ${BASE_PATH}/boot/${JAR_NAME} ${BOOT_OPTS} > ${LOG_PATH} 2>&1 &\n"

# 创建新的项目运行日志
echo "" > ${LOG_PATH}

# 如果项目启动日志不存�?,则创�?,否则追加
echo -e "${STARTUP_LOG}" >> ${LOG_STARTUP_PATH}

# 启动前检
PIDS=`ps -f | grep java | grep "$JAR_NAME" |awk '{print $2}'`
if [ "$1" = "status" ]; then
  if [ -n "$PIDS" ]; then
    echo "The $SERVER_NAME is running...!"
    echo "PID: $PIDS"
    exit 0
  else
    echo "The $SERVER_NAME is stopped"
    exit 0
  fi
fi
if [ -n "$PIDS" ]; then
  echo "ERROR: The $SERVER_NAME already started!"
  echo "PID: $PIDS"
  exit 1
fi
if [ -n "$SERVER_PORT" ]; then
  SERVER_PORT_COUNT=`netstat -tln | grep "$SERVER_PORT" | wc -l`
  if [ $SERVER_PORT_COUNT -gt 0 ]; then
    echo "ERROR: The $SERVER_NAME port $SERVER_PORT already used!"
    exit 1
  fi
fi

echo -e "Starting the $SERVER_NAME ..."
nohup ${JAVA} ${JAVA_OPTS} -jar ${BASE_PATH}/boot/${JAR_NAME} ${BOOT_OPTS} > ${LOG_PATH} 2>&1 &
COUNT=0
while [ $COUNT -lt 1 ]; do
  echo -e ".\c"
  sleep 1
  if [ -n "$SERVER_PORT" ]; then
    COUNT=`netstat -an | grep "$SERVER_PORT" | wc -l`
  else
    COUNT=`ps -f | grep java | grep "$CONF_DIR" | awk '{print $2}' | wc -l`
  fi
  if [ $COUNT -gt 0 ]; then
    break
  fi
done
echo "OK!"
PID=$(ps -ef | grep "${JAR_NAME}" | grep -v grep | awk '{ print $2 }')

STARTUP_LOG="${STARTUP_LOG}application pid: ${PIDS}\n"

# 当前时间
END_NOW=`date +'%Y-%m-%m-%H-%M-%S'`
END_NOW_PRETTY=`date '+%Y-%m-%m %H:%M:%S'`
STARTUP_LOG="${STARTUP_LOG} \n ================================================end ${END_NOW_PRETTY} ================================================\n"

# 启动日志追加到启动日志文件中
echo -e ${STARTUP_LOG} >> ${LOG_STARTUP_PATH}
# 打印启动日志
echo -e ${STARTUP_LOG}

# 打印项目日志
#tail -f ${LOG_PATH}

##############
# 脚本用例
# 启动应用
#./start.sh
# 以debug方式启动
#./start debug
# 启动任务并开启jmx监控
#./start jmx
# 获取当前的运行状
#./start status
#停止脚本：stop.sh

