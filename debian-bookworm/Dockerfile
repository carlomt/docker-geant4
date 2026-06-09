FROM debian:bookworm-slim AS common

LABEL maintainer="carlo.mancini-terracciano@uniroma1.it"

ARG G4_VERSION
ARG CMAKE_VERSION
ARG BUILD_DATE
ARG TARGETARCH

LABEL org.label-schema.geant4-version=$G4_VERSION
LABEL org.label-schema.build-date=$BUILD_DATE
LABEL org.label-schema.name="carlomt/geant4"
LABEL org.label-schema.description="Geant4 Docker image"
LABEL org.label-schema.url="https://github.com/carlomt/docker-geant4"
LABEL org.label-schema.docker.cmd="docker build -t carlomt/geant4:latest --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') --no-cache=true ."

ENV CC=/usr/bin/gcc
ENV CXX=/usr/bin/g++

ENV LANG=C.UTF-8
ENV PATH="/opt/cmake/bin:${PATH}"

RUN ln -sf /usr/share/zoneinfo/UTC /etc/localtime

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get -yq --no-install-recommends install \
      ca-certificates \
      curl \
      dirmngr \
      gpg \
      g++ \      
      make \
      ninja-build \
      pkg-config \
      libxerces-c-dev \
      libexpat1-dev \
      libssl-dev \
    && \
    apt-get -y autoremove && \
    apt-get -y clean && \
    rm -rf /var/cache/apt/archives/* && \
    rm -rf /var/lib/apt/lists/*

RUN test -n "${CMAKE_VERSION}" || (echo "ERROR: CMAKE_VERSION is not set" >&2; exit 1) && \
    case "${TARGETARCH}" in \
      amd64) CMAKE_ARCH="x86_64" ;; \
      arm64) CMAKE_ARCH="aarch64" ;; \
      *) echo "Unsupported TARGETARCH: ${TARGETARCH}" >&2; exit 1 ;; \
    esac && \
    CMAKE_URL="https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-linux-${CMAKE_ARCH}.tar.gz" && \
    echo "Downloading CMake from: ${CMAKE_URL}" && \
    mkdir -p /opt/cmake /tmp/cmake && \
    curl -fsSL --retry 5 --retry-delay 10 \
      "${CMAKE_URL}" \
      --output /tmp/cmake.tar.gz && \
    tar -xzf /tmp/cmake.tar.gz -C /tmp/cmake --strip-components=1 && \
    cp -a /tmp/cmake/. /opt/cmake/ && \
    cmake --version && \
    rm -rf /tmp/cmake /tmp/cmake.tar.gz

#######################################################################

FROM common AS builder

RUN mkdir -p /tmp/geant4/build /opt/geant4 && \
    curl -fsSL \
      "https://geant4-data.web.cern.ch/geant4-data/releases/source/geant4-v${G4_VERSION}.tar.gz" \
      --output /tmp/geant4.tar.gz && \
    tar xf /tmp/geant4.tar.gz -C /tmp/geant4/ && \
    mv "/tmp/geant4/geant4-v${G4_VERSION}" /tmp/geant4/src && \
    cmake -S /tmp/geant4/src -B /tmp/geant4/build -G Ninja \
      -DCMAKE_INSTALL_PREFIX=/opt/geant4 \
      -DGEANT4_INSTALL_DATA=OFF \
      -DGEANT4_INSTALL_DATADIR=/opt/geant4/data \
      -DGEANT4_BUILD_MULTITHREADED=ON \
      -DGEANT4_USE_GDML=ON \
      -DGEANT4_USE_QT=OFF \
      -DGEANT4_USE_OPENGL_X11=OFF \
      -DGEANT4_INSTALL_EXAMPLES=OFF && \
    cmake --build /tmp/geant4/build --parallel "$(nproc)" && \
    cmake --install /tmp/geant4/build

#######################################################################

FROM common

COPY --from=builder /opt/geant4/ /opt/geant4/

RUN mkdir -p /opt/geant4/data && chmod 777 /opt/geant4/data

COPY bashrc.sh /opt/bashrc.sh
RUN chmod +x /opt/bashrc.sh

ENTRYPOINT ["/opt/bashrc.sh"]

WORKDIR /workspace

CMD ["bash"]