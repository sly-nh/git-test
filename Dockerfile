FROM java:8
ENV USER_OPTS="" \
    USER_ARGS="" \
    LOG_PATH="/var/log/guard-service"
COPY build/libs/*.jar /opt/app/
COPY entrypoint.sh /opt/app/
RUN mv /opt/app/guard-service-*.jar /opt/app/guard-service.jar
RUN mkdir -p "$LOG_PATH"

WORKDIR /opt/app
VOLUME ["/tmp", "$LOG_PATH"]

EXPOSE 8085

ENTRYPOINT ["./entrypoint.sh"]
