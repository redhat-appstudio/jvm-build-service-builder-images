FROM registry.access.redhat.com/ubi8/ubi-minimal
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
    JAVA_HOME="/usr/lib/jvm/java-17" \
    JAVA_VENDOR="openjdk" \
    JAVA_VERSION="17"

RUN microdnf --setopt=install_weak_deps=0 --setopt=tsflags=nodocs install -y apr-devel autoconf automake bc buildah bzip2-devel cmake diffutils emacs-filesystem file findutils gcc gcc-c++ git glibc-devel glibc-devel.i686 glibc-langpack-en glibc-static golang gzip hostname iproute java-1.8.0-openjdk-devel java-11-openjdk-devel java-17-openjdk-devel libcurl-devel libgcc.i686 libstdc++-static libtool lsof make openssl-devel podman shadow-utils tar tzdata-java unzip vim-filesystem wget which zlib-devel \
    && microdnf clean all \
    && rpm -q apr-devel autoconf automake bc buildah bzip2-devel cmake diffutils emacs-filesystem file findutils gcc gcc-c++ git glibc-devel glibc-devel.i686 glibc-langpack-en glibc-static golang gzip hostname iproute java-17-openjdk-devel libcurl-devel libgcc.i686 libstdc++-static libtool lsof make openssl-devel podman shadow-utils tar tzdata-java unzip vim-filesystem wget which zlib-devel

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
         \
    \
    && echo "Downloading Ant 1.10.13" \
    && wget --no-verbose --output-document=ant.zip "https://dlcdn.apache.org/ant/binaries/apache-ant-1.10.13-bin.zip" \
    && echo "Checking download hash 1.10.13" \
    && echo "800238184231f8002210fd0c75681bc20ce12f527c9b1dcb95fc8a33803bfce1 *ant.zip" | sha256sum --check - \
    && echo "Installing Ant 1.10.13" \
    && unzip ant.zip \
    && rm ant.zip \
    && mv "apache-ant-1.10.13" "/opt/ant/1.10.13/" \
    && export ANT_HOME=/opt/ant/1.10.13 \
    && cd $ANT_HOME \
    && for i in antunit ivy logging junit xml networking regexp antlr bcel jdepend bsf debugging script javamail jspc; do $ANT_HOME/bin/ant -f fetch.xml -Ddest=system $i; done     \
    \
    && echo "Downloading SBT 1.8.0" \
    && wget --no-verbose --output-document=sbt.zip "https://github.com/sbt/sbt/releases/download/v1.8.0/sbt-1.8.0.zip" \
    && echo "Checking download hash 1.8.0" \
    && echo "fb52ea0bc0761176f3e38923ae5df556fba372895efb98a587f706d1ae805897 *sbt.zip" | sha256sum --check - \
    && echo "Installing SBT 1.8.0" \
    && unzip sbt.zip \
    && rm sbt.zip \
    && mv "sbt" "/opt/sbt/1.8.0/" \
    && export SBT_HOME=/opt/sbt/1.8.0     \
    \
    && echo "Downloading Gradle 8.4" \
    && wget --no-verbose --output-document=gradle.zip "https://services.gradle.org/distributions/gradle-8.4-bin.zip" \
    && echo "Checking download hash 8.4" \
    && echo "3e1af3ae886920c3ac87f7a91f816c0c7c436f276a6eefdb3da152100fef72ae *gradle.zip" | sha256sum --check - \
    && echo "Installing Gradle 8.4" \
    && unzip gradle.zip \
    && rm gradle.zip \
    && mv "gradle-8.4" "/opt/gradle/8.4/"     \
    \
    && echo "Downloading Gradle 8.3" \
    && wget --no-verbose --output-document=gradle.zip "https://services.gradle.org/distributions/gradle-8.3-bin.zip" \
    && echo "Checking download hash 8.3" \
    && echo "591855b517fc635b9e04de1d05d5e76ada3f89f5fc76f87978d1b245b4f69225 *gradle.zip" | sha256sum --check - \
    && echo "Installing Gradle 8.3" \
    && unzip gradle.zip \
    && rm gradle.zip \
    && mv "gradle-8.3" "/opt/gradle/8.3/"     \
    \
    && echo "Downloading Gradle 8.0.2" \
    && wget --no-verbose --output-document=gradle.zip "https://services.gradle.org/distributions/gradle-8.0.2-bin.zip" \
    && echo "Checking download hash 8.0.2" \
    && echo "ff7bf6a86f09b9b2c40bb8f48b25fc19cf2b2664fd1d220cd7ab833ec758d0d7 *gradle.zip" | sha256sum --check - \
    && echo "Installing Gradle 8.0.2" \
    && unzip gradle.zip \
    && rm gradle.zip \
    && mv "gradle-8.0.2" "/opt/gradle/8.0.2/"     \
    \
    && echo "Downloading Gradle 7.4.2" \
    && wget --no-verbose --output-document=gradle.zip "https://services.gradle.org/distributions/gradle-7.4.2-bin.zip" \
    && echo "Checking download hash 7.4.2" \
    && echo "29e49b10984e585d8118b7d0bc452f944e386458df27371b49b4ac1dec4b7fda *gradle.zip" | sha256sum --check - \
    && echo "Installing Gradle 7.4.2" \
    && unzip gradle.zip \
    && rm gradle.zip \
    && mv "gradle-7.4.2" "/opt/gradle/7.4.2/"     \
    \
    && echo "Downloading Gradle 6.9.2" \
    && wget --no-verbose --output-document=gradle.zip "https://services.gradle.org/distributions/gradle-6.9.2-bin.zip" \
    && echo "Checking download hash 6.9.2" \
    && echo "8b356fd8702d5ffa2e066ed0be45a023a779bba4dd1a68fd11bc2a6bdc981e8f *gradle.zip" | sha256sum --check - \
    && echo "Installing Gradle 6.9.2" \
    && unzip gradle.zip \
    && rm gradle.zip \
    && mv "gradle-6.9.2" "/opt/gradle/6.9.2/"     \
    \
    && echo "Downloading Maven 3.8.8" \
    && wget --no-verbose --output-document=maven.zip "https://dlcdn.apache.org/maven/maven-3/3.8.8/binaries/apache-maven-3.8.8-bin.zip" \
    && echo "Checking download hash 3.8.8" \
    && echo "aa7d431c07714c410e53502b630f91fc22d2664d5974a413471a2bd4fca9c31f98fbc397d613b7c3e31d3615a9f18487867975b1332462baf7d6ca58ef3628f9 *maven.zip" | sha512sum --check - \
    && echo "Installing Maven 3.8.8" \
    && unzip maven.zip \
    && rm maven.zip \
    && mv "apache-maven-3.8.8" "/opt/maven/3.8.8/"     \
    \
    && echo "Downloading Maven 3.9.5" \
    && wget --no-verbose --output-document=maven.zip "https://dlcdn.apache.org/maven/maven-3/3.9.5/binaries/apache-maven-3.9.5-bin.zip" \
    && echo "Checking download hash 3.9.5" \
    && echo "ca59380b839c6bea8f464a08bb7873a1cab91007b95876ba9ed8a9a2b03ceac893e661d218ba3d4af3ccf46d26600fc4c59fccabba9d7b2cc4adcd8aecc1df2a *maven.zip" | sha512sum --check - \
    && echo "Installing Maven 3.9.5" \
    && unzip maven.zip \
    && rm maven.zip \
    && mv "apache-maven-3.9.5" "/opt/maven/3.9.5/"

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
