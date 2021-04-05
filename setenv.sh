#!/bin/sh

export EUREKA_SERVER_NAME="eureka.ke.com"

if [ "x$ENVTYPE" = "xtest" ]; then
    export SPRING_PROFILES_ACTIVE='test'
    export EUREKA_SERVER_NAME="test.${EUREKA_SERVER_NAME}"
    export EUREKA_SERVER_PORT="10140"
    export EUREKA_ZONE="${IDC}"
    if [ "x${MODULE:0:4}" = "xtest" ]; then
        export EUREKA_ROLE="${MODULE%-*}"
    fi
else
    if [ "$ENVTYPE" = "docker" ]; then
        export SPRING_PROFILES_ACTIVE='docker'
        export EUREKA_SERVER_NAME="dev.${EUREKA_SERVER_NAME}"
        export EUREKA_SERVER_PORT="10153"
    else
        export SPRING_PROFILES_ACTIVE='prod'
        export EUREKA_SERVER_NAME="prod.${EUREKA_SERVER_NAME}"
        export EUREKA_SERVER_PORT="10122"
        export EUREKA_ZONE="${IDC}"
    fi
fi

export LOG_PATH="${MATRIX_APPLOGS_DIR}"
export JARFILE="${MATRIX_CODE_DIR}/lib/guard-service.jar"

USER_OPTS=""
USER_OPTS="$USER_OPTS -javaagent:${MATRIX_CODE_DIR}/lib/aspectjweaver.jar"
USER_OPTS="$USER_OPTS -javaagent:${MATRIX_CODE_DIR}/lib/spring-instrument.jar"
USER_OPTS="$USER_OPTS -XX:+PrintPromotionFailure -XX:+PrintGCApplicationStoppedTime -XX:+PrintGCCause"
USER_OPTS="$USER_OPTS -XX:-UseBiasedLocking -XX:AutoBoxCacheMax=20000 -Djava.security.egd=file:/dev/./urandom"
USER_OPTS="$USER_OPTS -XX:+PrintCommandLineFlags -XX:-OmitStackTraceInFastThrow"
USER_OPTS="$USER_OPTS -Djava.net.preferIPv4Stack=true -Djava.awt.headless=true -Dfile.encoding=UTF-8"
USER_OPTS="$USER_OPTS -Droot.path=${MATRIX_CODE_DIR}"
USER_OPTS="$USER_OPTS -Dspring.discovery.client.server-name=${EUREKA_SERVER_NAME}"
USER_OPTS="$USER_OPTS -Dspring.discovery.client.server-port=${EUREKA_SERVER_PORT}"
USER_OPTS="$USER_OPTS -Dspring.discovery.client.module-name=${MODULE}"
USER_OPTS="$USER_OPTS -Dspring.discovery.client.zone=${EUREKA_ZONE}"
USER_OPTS="$USER_OPTS -Dspring.discovery.client.role=${EUREKA_ROLE}"

USER_ARGS=""
USER_ARGS="$USER_ARGS --spring.profiles.active=${SPRING_PROFILES_ACTIVE}"
