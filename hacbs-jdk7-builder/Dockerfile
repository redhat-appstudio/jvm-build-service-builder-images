FROM registry.access.redhat.com/ubi7/ubi-minimal
USER root
ENV \
    LANG="en_US.UTF-8" \
    LANGUAGE="en_US:en" \
    LC_ALL="en_US.UTF-8" \
    APP_HOME="/home/hacbs" \
    MAVEN_HOME="/usr/share/maven" \
    MAVEN_OPTS="-XX:+TieredCompilation -XX:TieredStopAtLevel=1" \
    MAVEN_VERSION="3.8.6" \
    HOME="/home/hacbs" \
    NSS_WRAPPER_PASSWD="/etc/passwd" \
    PATH="$PATH:$JAVA_HOME/bin" \
    BASE_URL=https://apache.osuosl.org/maven/maven-3/3.8.6/binaries \
    MAVEN_SHA=f790857f3b1f90ae8d16281f902c689e4f136ebe584aba45e4b1fa66c80cba826d3e0e52fdd04ed44b4c66f6d3fe3584a057c26dfcac544a60b301e6d0f91c26

RUN microdnf --setopt=tsflags=nodocs install -y shadow-utils

RUN groupadd -r hacbs -g 1001 && useradd -u 1001 -r -g 1001 -m -d ${APP_HOME} -s /sbin/nologin -c "HACBS user" hacbs && cp /etc/passwd /home/hacbs/passwd && chown 1001:1001 /home/hacbs/passwd && mkdir /project && chown 1001:1001 /project

RUN microdnf --setopt=tsflags=nodocs install -y apr-devel autoconf automake bc diffutils file findutils gcc gcc-c++ git glibc-devel glibc-devel.i686 gzip libcurl-devel libgcc.i686 libtool lsof make openssl-devel shadow-utils tar unzip wget which zlib-devel \
    && microdnf clean all \
    && rpm -q apr-devel autoconf automake bc diffutils file findutils gcc gcc-c++ git glibc-devel glibc-devel.i686 gzip libcurl-devel libgcc.i686 libtool lsof make openssl-devel shadow-utils tar unzip wget which zlib-devel

RUN microdnf --setopt=tsflags=nodocs install -y java-1.7.0-openjdk-devel

RUN microdnf --setopt=tsflags=nodocs install -y vim-filesystem

RUN mkdir -p /usr/share/maven/ref && curl -fsSL -o /tmp/apache-maven.tar.gz ${BASE_URL}/apache-maven-3.8.6-bin.tar.gz   && echo "f790857f3b1f90ae8d16281f902c689e4f136ebe584aba45e4b1fa66c80cba826d3e0e52fdd04ed44b4c66f6d3fe3584a057c26dfcac544a60b301e6d0f91c26  /tmp/apache-maven.tar.gz" | sha512sum -c -   && tar -xzf /tmp/apache-maven.tar.gz -C /usr/share/maven --strip-components=1   && rm -f /tmp/apache-maven.tar.gz   && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

LABEL \
    io.cekit.version="4.1.0" \
    io.k8s.description="HACBS builder image for building Java components." \
    io.k8s.display-name="HACBS BuilderImage" \
    io.openshift.tags="builder,java,hacbs" \
    maintainer="Stuart Douglas <sdouglas@redhat.com>"

# Clear package manager metadata
RUN microdnf clean all && [ ! -d /var/cache/yum ] || rm -rf /var/cache/yum
# Define the user
USER hacbs
# Define the working directory
WORKDIR /project
