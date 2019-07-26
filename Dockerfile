FROM gradle:5.5.1-jdk11 as build
WORKDIR /app
COPY . .
RUN gradle shadowJar

FROM oracle/graalvm-ce:19.1.1 as optimize
RUN gu install native-image
WORKDIR /app
COPY --from=build /app/build/libs/http4k-openfaas-all.jar .
RUN native-image \
    --no-fallback \
    --static \
    -cp /app/http4k-openfaas-all.jar \
    -H:Name=server \
    com.github.nlochschmidt.http4k_openfaas.example.AppKt

FROM openfaas/of-watchdog:0.5.4 as watchdog

FROM alpine:3.10.1

COPY --from=watchdog /fwatchdog /usr/bin/fwatchdog
COPY --from=optimize /app/server /usr/bin/server

ENV cgi_headers="true"
ENV fprocess="/usr/bin/server"
ENV mode="http"
ENV upstream_url="http://127.0.0.1:3000"

ENV exec_timeout="10s"
ENV write_timeout="15s"
ENV read_timeout="15s"

HEALTHCHECK --interval=3s CMD [ -e /tmp/.lock ] || exit 1

CMD ["fwatchdog"]