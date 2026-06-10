FROM debian:bookworm-slim AS builder
RUN apt-get update \
 && apt-get install -y --no-install-recommends ant default-jre-headless \
 && rm -rf /var/lib/apt/lists/*
WORKDIR /src
COPY build.xml build.properties ./
COPY exporters ./exporters
RUN ant base_service

FROM eclipse-temurin:8-jre-jammy AS loader
RUN apt-get update \
 && apt-get install -y --no-install-recommends perl libwww-perl curl ca-certificates \
 && rm -rf /var/lib/apt/lists/*

COPY --from=existdb/existdb:4.8.0 /exist /exist
WORKDIR /opt/snippet-server
COPY --from=builder /src/build ./build
COPY utilities/load_exist.pl ./utilities/load_exist.pl

RUN set -eu; \
    cd /exist; \
    java -jar start.jar jetty & \
    EXIST_PID=$!; \
    cd /opt/snippet-server; \
    echo "Waiting for eXist to come up..."; \
    ready=""; \
    for i in $(seq 1 90); do \
        if curl -s -o /dev/null http://localhost:8080/exist/; then ready=1; break; fi; \
        sleep 2; \
    done; \
    [ -n "$ready" ] || { echo "ERROR: eXist did not start"; exit 1; }; \
    echo "Uploading snippet-server software..."; \
    perl utilities/load_exist.pl \
        --suffix xconf,xml,xq,xqm,xsl,page \
        --load build --target / \
        --host-port localhost:8080 --user admin --password ''; \
    echo "Verifying load..."; \
    curl -sf -o /dev/null -u 'admin:' \
        http://localhost:8080/exist/rest/db/text-retriever/adl/render.xsl \
        || { echo "ERROR: snippet-server files not found after load"; exit 1; }; \
    echo "Shutting eXist down cleanly (SIGTERM, as docker stop would)..."; \
    kill -TERM "$EXIST_PID"; \
    wait "$EXIST_PID" || true

FROM existdb/existdb:4.8.0
COPY --from=loader /exist/webapp/WEB-INF/data /exist/webapp/WEB-INF/data
