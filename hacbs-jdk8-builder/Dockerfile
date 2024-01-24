FROM registry.access.redhat.com/ubi8/ubi-minimal@sha256:288239021a429a311233d73a7d91b0a1dd889ab7bbc247d913e1b5726e25354a
USER root
ENV \
    LANG="en_US.UTF-8" \
    LANGUAGE="en_US:en" \
    LC_ALL="en_US.UTF-8" \
    APP_HOME="/root" \
    MAVEN_OPTS="-XX:+TieredCompilation -XX:TieredStopAtLevel=1" \
    GRADLE_OPTS="-Dorg.gradle.daemon=false" \
    GRADLE_MANIPULATOR_HOME="/usr/share/gradle-manipulator" \
    GRADLE_MANIPULATOR_VERSION="3.14" \
    HOME="/root" \
    NSS_WRAPPER_PASSWD="/etc/passwd" \
    CLI_JAR_DOWNLOAD_SHA256=4111205a0ba07d7234ac314b4fcb94b2aa1a1e74f737cfb15331eaddfe3a1578 \
    ANALYZER_INIT_DOWNLOAD_SHA256=be859af4d9abade9eb36c607f9b02c0995f2d3da82ee8d74bb8a7ef1dde930f4 \
    PATH="$JAVA_HOME/bin:$PATH" \
    JAVA_HOME="/usr/lib/jvm/java-1.8.0" \
    JAVA_VENDOR="openjdk" \
    JAVA_VERSION="1.8.0"

RUN microdnf --setopt=install_weak_deps=0 --setopt=tsflags=nodocs install -y apr-devel autoconf automake bc buildah bzip2-devel cmake diffutils emacs-filesystem file findutils gcc gcc-c++ git glibc-devel glibc-devel.i686 glibc-langpack-en glibc-static golang gzip hostname iproute java-1.8.0-openjdk-devel java-11-openjdk-devel java-17-openjdk-devel java-21-openjdk-devel libcurl-devel libgcc.i686 libstdc++-static libtool lsof make openssl-devel podman shadow-utils tar tzdata-java unzip vim-filesystem wget which zlib-devel \
    && microdnf clean all \
    && rpm -q apr-devel autoconf automake bc buildah bzip2-devel cmake diffutils emacs-filesystem file findutils gcc gcc-c++ git glibc-devel glibc-devel.i686 glibc-langpack-en glibc-static golang gzip hostname iproute java-1.8.0-openjdk-devel libcurl-devel libgcc.i686 libstdc++-static libtool lsof make openssl-devel podman shadow-utils tar tzdata-java unzip vim-filesystem wget which zlib-devel

# XXX: RHEL 8 does not have ninja-build, so grabbing from CentOS 8
RUN rpm --import https://www.centos.org/keys/RPM-GPG-KEY-CentOS-Official \
    && rpm -q gpg-pubkey-8483c65d-5ccc5b19
RUN wget --no-verbose https://vault.centos.org/centos/8/PowerTools/x86_64/os/Packages/ninja-build-1.8.2-1.el8.x86_64.rpm \
    && rpm -K ninja-build-1.8.2-1.el8.x86_64.rpm \
    && rpm -ivh ninja-build-1.8.2-1.el8.x86_64.rpm \
    && rm ninja-build-1.8.2-1.el8.x86_64.rpm \
    && rpm -q ninja-build
RUN wget --no-verbose https://vault.centos.org/centos/8/AppStream/x86_64/os/Packages/git-lfs-2.11.0-2.el8.x86_64.rpm \
    && rpm -K git-lfs-2.11.0-2.el8.x86_64.rpm \
    && rpm -ivh git-lfs-2.11.0-2.el8.x86_64.rpm \
    && rm git-lfs-2.11.0-2.el8.x86_64.rpm \
    && rpm -q git-lfs

RUN set -o errexit -o nounset \
    && echo "Downloading Gradle Manipulator" \
    && wget --no-verbose --output-document=cli.jar "https://repo1.maven.org/maven2/org/jboss/gm/cli/3.14/cli-3.14.jar" \
    && wget --no-verbose --output-document=analyzer-init.gradle "https://repo1.maven.org/maven2/org/jboss/gm/analyzer/3.14/analyzer-3.14-init.gradle" \
    \
    && echo "Checking cli.jar download hash" \
    && echo "${CLI_JAR_DOWNLOAD_SHA256} *cli.jar" | sha256sum --check - \
    \
    && echo "Checking analyzer-init.gradle download hash" \
    && echo "${ANALYZER_INIT_DOWNLOAD_SHA256} *analyzer-init.gradle" | sha256sum --check - \
    \
    && echo "Installing Gradle Manipulator" \
    && mkdir "${GRADLE_MANIPULATOR_HOME}" \
    && mv cli.jar analyzer-init.gradle "${GRADLE_MANIPULATOR_HOME}/" \
    && mkdir "${GRADLE_MANIPULATOR_HOME}/bin" \
    && echo -e "#!/bin/sh\n\nset -eu\nARGS=\"-l \${GRADLE_HOME}\"\njava -jar ${GRADLE_MANIPULATOR_HOME}/cli.jar \"\${ARGS}\" --init-script=${GRADLE_MANIPULATOR_HOME}/analyzer-init.gradle \$@" > ${GRADLE_MANIPULATOR_HOME}/bin/gradle-manipulator \
    && chmod 755 ${GRADLE_MANIPULATOR_HOME}/bin/gradle-manipulator \
    && ln --symbolic "${GRADLE_MANIPULATOR_HOME}/bin/gradle-manipulator" /usr/bin/gradle-manipulator
    #we test out gradle manipulator as part of the gradle installation


RUN set -o errexit -o nounset \
    && mkdir /opt/gradle \
    && mkdir /opt/sbt \
    && mkdir /opt/ant \
    && mkdir /opt/maven \
    

LABEL \
    io.cekit.version="4.1.0" \
    io.k8s.description="HACBS builder image for building Java components." \
    io.k8s.display-name="HACBS BuilderImage" \
    io.openshift.tags="builder,java,hacbs" \
    maintainer="Stuart Douglas <sdouglas@redhat.com>"

# Clear package manager metadata
RUN microdnf clean all && [ ! -d /var/cache/yum ] || rm -rf /var/cache/yum && mkdir /project && chown 185:185 /project
# Define the user
USER 185
# Define the working directory
WORKDIR /project
