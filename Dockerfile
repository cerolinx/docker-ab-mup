ARG ALPINE_VERSION=3.13
# Fetch stage #################################################################
FROM alpine:${ALPINE_VERSION} as buildstage

# Setup build env for PROJ
RUN set -ex && \
    apk add --no-cache --virtual .fetch-deps git g++

# Setup fetch deps
RUN set -x && \
    apk add --no-cache --virtual .build-deps \
    apr-dev \
    apache2-dev

# Fetch and build stage
RUN set -x && \
  mkdir -p abtemp && cd abtemp && \
  git clone https://github.com/cerolinx/apachebench-for-multi-url-with-prefix.git && \
  cd apachebench-for-multi-url-with-prefix && \
  gcc -I /usr/include/apr-1/ -I /usr/include/apache2 ab.c -o ab  -lm -lapr-1 -laprutil-1 -lssl -lcrypto

# Cleanup
RUN  set -x && \
  apk del .fetch-deps && \
  apk del .build-deps && \
  rm -rf /tmp/*

# Runtime stage #########################################################################
FROM alpine:${ALPINE_VERSION} AS runtimestage

RUN set -ex && \
    apk add apr apr-util

COPY --from=buildstage /abtemp/apachebench-for-multi-url-with-prefix/ab /usr/local/bin/

# Labels ######################################################################
LABEL docker.image="mcerolini/ab-mup"
LABEL docker.image.tag "alpine"
