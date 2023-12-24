FROM debian:bookworm as common
LABEL maintainer="carlo.mancini-terracciano@uniroma1.it"

ARG G4_VERSION=11.2.0

#labels
LABEL org.label-schema.geant4-version=$G4_VERSION
LABEL org.label-schema.build-date=$BUILD_DATE
LABEL org.label-schema.name="carlomt/geant4"
LABEL org.label-schema.description="Geant4 Docker image"
LABEL org.label-schema.url="https://github.com/carlomt/docker-geant4"
LABEL org.label-schema.docker.cmd="docker build -t carlomt/geant4:latest --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') --no-cache=true ."

WORKDIR /workspace

ENV LANG=C.UTF-8
RUN ln -sf /usr/share/zoneinfo/UTC /etc/localtime

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get -yq --no-install-recommends install \ 
     ca-certificates \
     dirmngr \
     gpg \
     curl
     
RUN apt-get update && \
    apt-get -yq --no-install-recommends install \
    make \
    ninja-build \
    pkg-config \
    libxerces-c-dev \
    libexpat1-dev \
    g++ \
    cmake \
    cmake-data \
    && \
    apt-get -y autoremove && \
    apt-get -y clean && \
    rm -rf /var/cache/apt/archives/* && \
    rm -rf /var/lib/apt/lists/*

#######################################################################

FROM common AS builder

RUN mkdir -p /workspace/geant4/build && \
    mkdir -p /opt/geant4/ && \
    curl https://geant4-data.web.cern.ch/geant4-data/releases/source/geant4-v${G4_VERSION}.tar.gz \
    --output /workspace/geant4.tar.gz &&\    
    tar xf /workspace/geant4.tar.gz -C /workspace/geant4/ && \
    mv /workspace/geant4/geant4-v${G4_VERSION}/ /workspace/geant4/src/ && \
    cd /workspace/geant4/build && \
    cmake -G Ninja -DCMAKE_INSTALL_PREFIX=/opt/geant4 \
    -DGEANT4_INSTALL_DATA=OFF \
    -DGEANT4_INSTALL_DATADIR=/opt/geant4/data \
    -DGEANT4_BUILD_MULTITHREADED=ON \
    -DGEANT4_USE_GDML=ON \
    -DGEANT4_USE_QT=OFF \
    -DGEANT4_USE_OPENGL_X11=OFF \
    -DGEANT4_INSTALL_EXAMPLES=OFF \
    ../src/ && \
     ninja install
    
#######################################################################

FROM common

COPY --from=builder /opt/geant4/ /opt/geant4/

RUN mkdir -p /opt/geant4/data && chmod 777 /opt/geant4/data

COPY gcc.sh /etc/profile.d/02-gcc.sh
COPY bashrc.sh /etc/profile.d/03-custom.sh

#ENTRYPOINT  ["/usr/bin/bash", "-l", "-c"]
