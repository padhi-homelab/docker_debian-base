FROM padhihomelab/alpine-base:312.019.0201 as tini-base
ARG TARGETARCH

FROM tini-base AS tini-base-amd64
ENV TINI_ARCH=amd64

FROM tini-base AS tini-base-386
ENV TINI_ARCH=x86

FROM tini-base AS tini-base-arm64
ENV TINI_ARCH=arm64

FROM tini-base AS tini-base-armv7
ENV TINI_ARCH=armhf

FROM tini-base AS tini-base-armv6
ENV TINI_ARCH=armel

FROM tini-base AS tini-base-ppc64le
ENV TINI_ARCH=ppc64le

FROM tini-base AS tini-base-s390x
ENV TINI_ARCH=s390x


FROM tini-base-${TARGETARCH}${TARGETVARIANT} as tini_build

ARG TINI_VERSION=0.19.0

ADD "https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini-${TINI_ARCH}" \
    /tmp/tini


FROM debian:buster-slim as su-exec_build

ARG SU_EXEC_COMMIT_SHA=212b75144bbc06722fbd7661f651390dc47a43d1

ADD "https://raw.githubusercontent.com/ncopa/su-exec/${SU_EXEC_COMMIT_SHA}/su-exec.c" \
    /tmp/su-exec.c

RUN apt update \
 && apt install -yq gcc \
 && cd /tmp \
 && gcc -Wall su-exec.c -o su-exec


FROM debian:buster-slim

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
