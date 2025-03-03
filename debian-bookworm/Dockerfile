FROM debian:bookworm-slim as common
LABEL maintainer="carlo.mancini-terracciano@uniroma1.it"

ARG G4_VERSION

#labels
LABEL org.label-schema.geant4-version=$G4_VERSION
LABEL org.label-schema.build-date=$BUILD_DATE
LABEL org.label-schema.name="carlomt/geant4"
LABEL org.label-schema.description="Geant4 Docker image"
LABEL org.label-schema.url="https://github.com/carlomt/docker-geant4"
LABEL org.label-schema.docker.cmd="docker build -t carlomt/geant4:latest --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') --no-cache=true ."

ENV CC=/usr/bin/gcc
ENV CXX=/usr/bin/g++

ENV LANG=C.UTF-8
RUN ln -sf /usr/share/zoneinfo/UTC /etc/localtime

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get -yq --no-install-recommends install \
    ca-certificates \
    curl \
    cmake \
    cmake-data \
    dirmngr \
    gpg \
    g++ \
    libexpat1-dev \
    libxerces-c-dev \
    make \
    ninja-build \
    pkg-config \
    && \
    apt-get -y autoremove && \
    apt-get -y clean && \
    rm -rf /var/cache/apt/archives/* && \
    rm -rf /var/lib/apt/lists/*

#######################################################################

FROM common AS builder

RUN echo "Geant4 version: " ${G4_VERSION} && \
    mkdir -p /tmp/geant4/build && \
    mkdir -p /opt/geant4/ && \
    curl https://geant4-data.web.cern.ch/geant4-data/releases/source/geant4-v${G4_VERSION}.tar.gz \
    --output /tmp/geant4.tar.gz && \
    tar xf /tmp/geant4.tar.gz -C /tmp/geant4/ && \
    mv /tmp/geant4/geant4-v${G4_VERSION}/ /tmp/geant4/src/ && \
    cd /tmp/geant4/build && \
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

# Set the entrypoint script to set Geant4 environment variables
COPY bashrc.sh /opt/bashrc.sh
RUN chmod +x /opt/bashrc.sh
ENTRYPOINT ["/opt/bashrc.sh"]

WORKDIR /workspace

# Default command to execute if none is provided to docker run
CMD ["bash"]
