FROM debian:12.9-slim as tini_base
ARG TARGETARCH

FROM tini_base AS tini_base-amd64
ENV TINI_ARCH=amd64

FROM tini_base AS tini_base-386
ENV TINI_ARCH=i386

FROM tini_base AS tini_base-arm64
ENV TINI_ARCH=arm64

FROM tini_base AS tini_base-armv7
ENV TINI_ARCH=armhf

FROM tini_base AS tini_base-armv6
ENV TINI_ARCH=armel

FROM tini_base AS tini_base-ppc64le
ENV TINI_ARCH=ppc64le

FROM tini_base AS tini_base-s390x
ENV TINI_ARCH=s390x


FROM tini_base-${TARGETARCH}${TARGETVARIANT} as tini_build

ARG TINI_VERSION=0.19.0

ADD "https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini-${TINI_ARCH}" \
    /tmp/tini


FROM debian:12.9-slim as su-exec_build

ARG SU_EXEC_COMMIT_SHA=4c3bb42b093f14da70d8ab924b487ccfbb1397af

ADD "https://raw.githubusercontent.com/ncopa/su-exec/${SU_EXEC_COMMIT_SHA}/su-exec.c" \
    /tmp/su-exec.c

RUN apt update \
 && apt install -yq gcc \
 && cd /tmp \
 && gcc -Wall su-exec.c -o su-exec


FROM debian:12.9-slim

LABEL maintainer="Saswat Padhi saswat.sourav@gmail.com"

COPY --from=su-exec_build \
     /tmp/su-exec \
     /usr/bin/su-exec

COPY --from=tini_build \
     /tmp/tini \
     /usr/bin/tini

COPY docker-entrypoint.sh \
     /usr/local/bin/docker-entrypoint

RUN chmod +x /usr/bin/su-exec \
             /usr/bin/tini \
             /usr/local/bin/docker-entrypoint

ENTRYPOINT [ "tini" , "/usr/local/bin/docker-entrypoint" ]

CMD [ "sh" ]
