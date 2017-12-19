FROM alpine:edge AS build-env
ENV BERKELEYDB_VERSION=db-4.8.30.NC
ENV BERKELEYDB_PREFIX=/opt/${BERKELEYDB_VERSION}
ENV YTENTEN_VERSION=1.2.1
ENV YTENTE_FOLDER_VERSION=1.2.1
ENV YENTEN_PREFIX=/opt/yenten-${YTENTEN_VERSION}
ENV YENTEN_DATA=/home/yenten/.yenten
ENV PATH=${YENTEN_PREFIX}/bin:$PATH
ENV gpp_version 6.4.0-r5
ENV dependencies "git autoconf automake libtool g++=${gpp_version} make boost-dev libressl-dev miniupnpc-dev protobuf-dev libqrencode-dev libevent-dev"

RUN apk --no-cache --update add ${dependencies} && \
  mkdir -p /tmp/build && \
  mkdir -p /tmp/build/${YENTEN_VERSION} && \
  mkdir -p ${YENTEN_PREFIX} && \
  wget -O /tmp/build/${BERKELEYDB_VERSION}.tar.gz http://download.oracle.com/berkeley-db/${BERKELEYDB_VERSION}.tar.gz && \
  tar -xzf /tmp/build/${BERKELEYDB_VERSION}.tar.gz -C /tmp/build/ && \
  sed s/__atomic_compare_exchange/__atomic_compare_exchange_db/g -i /tmp/build/${BERKELEYDB_VERSION}/dbinc/atomic.h && \
  mkdir -p ${BERKELEYDB_PREFIX} && \
  cd /tmp/build/${BERKELEYDB_VERSION}/build_unix && \
  ../dist/configure --enable-cxx --disable-shared --with-pic --prefix=${BERKELEYDB_PREFIX} && \
  make install && \
  cd /tmp/build/${YENTEN_VERSION} && \
  git clone https://github.com/conan-equal-newone/yenten.git && \
  cd yenten && \
  ./autogen.sh && \
  ./configure LDFLAGS=-L${BERKELEYDB_PREFIX}/lib/ CPPFLAGS=-I${BERKELEYDB_PREFIX}/include/ \
    --prefix=${YENTEN_PREFIX} \
    --enable-upnp-default --without-gui --disable-tests && \
  make -j2 && \
  make install

FROM alpine:edge as runtime
ENV YTENTEN_VERSION=1.2.1
ENV SRC_YENTEN_PREFIX=/opt/yenten-${YTENTEN_VERSION}
ENV TARGET_YENTEN_PREFIX=/opt/yenten
RUN mkdir /lib64 && ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2 && \
  apk add --no-cache ca-certificates boost libressl miniupnpc protobuf libqrencode libevent boost-program_options && \
  mkdir -p ${YENTEN_PREFIX}/bin/
COPY --from=build-env ${SRC_YENTEN_PREFIX}/bin/yentend ${TARGET_YENTEN_PREFIX}/bin/yentend
COPY --from=build-env ${SRC_YENTEN_PREFIX}/bin/yentend ${TARGET_YENTEN_PREFIX}/bin/yenten-cli
VOLUME /home/yenten/.yenten
EXPOSE 9982 9982
ENTRYPOINT [ "/bin/sh" ]
#ENTRYPOINT [ ${TARGET_YENTEN_PREFIX}/bin/yentend ]
