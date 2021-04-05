#!/usr/bin/env bash

set -e

# 以下可以自定义JVM启动参数
USER_OPTS="$USER_OPTS -XX:+PrintPromotionFailure -XX:+PrintGCApplicationStoppedTime -XX:+PrintGCCause"
USER_OPTS="$USER_OPTS -XX:-UseBiasedLocking -XX:AutoBoxCacheMax=20000 -Djava.security.egd=file:/dev/./urandom"
USER_OPTS="$USER_OPTS -XX:+PrintCommandLineFlags -XX:-OmitStackTraceInFastThrow"
USER_OPTS="$USER_OPTS -Djava.net.preferIPv4Stack=true -Djava.awt.headless=true -Dfile.encoding=UTF-8"
USER_OPTS="$USER_OPTS -Dlogging.path=${LOG_PATH}"
# 以下可以自定义Java启动参数，active写docker
USER_ARGS="$USER_ARGS --spring.profiles.active=docker"

command_desc="$(command -v $1)"
if [[ -n "$command_desc" ]]; then
    exec $@
else
    # 视情况而定是否需要agent
    exec java ${USER_OPTS} -javaagent:spring-instrument.jar -javaagent:aspectjweaver.jar -jar guard-service.jar ${USER_ARGS}
fi
