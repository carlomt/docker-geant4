FROM centos:7 as common
LABEL maintainer="carlo.mancini-terracciano@uniroma1.it"

ARG G4_VERSION=11.2.0
ARG CMAKE_VERSION=3.28.1

#labels
LABEL org.label-schema.geant4-version=$G4_VERSION
LABEL org.label-schema.build-date=$BUILD_DATE
LABEL org.label-schema.name="carlomt/geant4"
LABEL org.label-schema.description="Geant4 Docker image"
LABEL org.label-schema.url="https://github.com/carlomt/docker-geant4"
LABEL org.label-schema.docker.cmd="docker build -t carlomt/geant4:latest --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') --no-cache=true ."

RUN yum install -y centos-release-scl
#centos-release-scl-rh
RUN yum install -y \
    devtoolset-9-gcc \
    devtoolset-9-gcc-c++ \
    devtoolset-9-make \
    expat expat-devel \
    openssl-devel \
    xerces-c xerces-c-devel \
    which \
    && \
    yum clean all

RUN source /opt/rh/devtoolset-9/enable && \
    mkdir -p /tmp/cmake/ && \
    mkdir -p /opt/cmake && \
    curl -L https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}.tar.gz \
    --output /tmp/cmake.tar.gz && \
    tar xf /tmp/cmake.tar.gz -C /tmp/cmake && \
    cd /tmp/cmake/cmake-${CMAKE_VERSION} && \
     ./bootstrap && make -j`nproc` && make install

#######################################################################

FROM common AS builder

RUN source /opt/rh/devtoolset-9/enable && \
    mkdir -p /tmp/geant4/build && \
    mkdir -p /opt/geant4/ && \
    curl https://geant4-data.web.cern.ch/geant4-data/releases/source/geant4-v${G4_VERSION}.tar.gz \
    --output /tmp/geant4.tar.gz &&\    
    tar xf /tmp/geant4.tar.gz -C /tmp/geant4/ && \
    mv /tmp/geant4/geant4-v${G4_VERSION}/ /tmp/geant4/src/ && \
    cd /tmp/geant4/build && \
    cmake \
    #-G Ninja
    -DCMAKE_INSTALL_PREFIX=/opt/geant4 \
    -DGEANT4_INSTALL_DATA=OFF \
    -DGEANT4_INSTALL_DATADIR=/opt/geant4/data \
    -DGEANT4_BUILD_MULTITHREADED=ON \
    -DGEANT4_USE_GDML=ON \
    -DGEANT4_USE_QT=OFF \
    -DGEANT4_USE_OPENGL_X11=OFF \
    -DGEANT4_INSTALL_EXAMPLES=OFF \
    -DGEANT4_INSTALL_PACKAGE_CACHE=OFF \
    ../src/ && \
    make -j`nproc` && \
    make install
    
#######################################################################

FROM common

COPY --from=builder /opt/geant4/ /opt/geant4/

RUN mkdir -p /opt/geant4/data && chmod 777 /opt/geant4/data

COPY gcc.sh /etc/profile.d/02-gcc.sh
COPY bashrc.sh /etc/profile.d/03-custom.sh

#ENTRYPOINT  ["/usr/bin/bash", "-l", "-c"]
