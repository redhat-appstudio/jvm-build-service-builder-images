FROM registry.access.redhat.com/ubi8/ubi-minimal:8.10-1052.1724178568@sha256:a47c89f02b39a98290f88204ed3d162845db0a0c464b319c2596cfd1e94b444e
USER root
ENV \
    LANG="en_US.UTF-8" \
    LANGUAGE="en_US:en" \
    LC_ALL="en_US.UTF-8" \
    APP_HOME="/root" \
    HOME="/root" \
    NSS_WRAPPER_PASSWD="/etc/passwd" \
    UBI=8
ENV PATH="$JAVA_HOME/bin:$PATH"

RUN microdnf --setopt=install_weak_deps=0 --setopt=tsflags=nodocs install -y apr-devel autoconf automake bc buildah bzip2-devel cmake curl diffutils emacs-filesystem file findutils gcc gcc-c++ git glibc-devel glibc-devel.i686 glibc-langpack-en glibc-static golang gzip hostname iproute java-1.8.0-openjdk-devel java-11-openjdk-devel java-17-openjdk-devel java-21-openjdk-devel jq libcurl-devel libgcc.i686 libstdc++-static libtool lsof make openssl-devel perl-Digest-SHA podman shadow-utils tar tzdata-java unzip vim-minimal wget which zip zlib-devel \
    && rpm -q apr-devel autoconf automake bc buildah bzip2-devel cmake curl diffutils emacs-filesystem file findutils gcc gcc-c++ git glibc-devel glibc-devel.i686 glibc-langpack-en glibc-static golang gzip hostname iproute java-1.8.0-openjdk-devel java-11-openjdk-devel java-17-openjdk-devel java-21-openjdk-devel jq libcurl-devel libgcc.i686 libstdc++-static libtool lsof make openssl-devel perl-Digest-SHA podman shadow-utils tar tzdata-java unzip vim-minimal wget which zip zlib-devel

RUN if [ "8" = "8" ] ; then rpm --import https://www.centos.org/keys/RPM-GPG-KEY-CentOS-Official https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-8 \
    && rpm -q gpg-pubkey-8483c65d-5ccc5b19 \
    # XXX: RHEL 8 does not have ninja-build, so grabbing from CentOS 8
    && wget --no-verbose https://vault.centos.org/centos/8/PowerTools/x86_64/os/Packages/ninja-build-1.8.2-1.el8.x86_64.rpm \
    && rpm -K ninja-build-1.8.2-1.el8.x86_64.rpm \
    && rpm -ivh ninja-build-1.8.2-1.el8.x86_64.rpm \
    && rm ninja-build-1.8.2-1.el8.x86_64.rpm \
    && rpm -q ninja-build \
    # XXX: RHEL 8 does not have OpenJDK 23, so grabbing from Fedora
    && wget --no-verbose https://dl.fedoraproject.org/pub/epel/8/Everything/x86_64/Packages/j/java-latest-openjdk-devel-23.0.0.0.37-1.rolling.el8.x86_64.rpm https://dl.fedoraproject.org/pub/epel/8/Everything/x86_64/Packages/j/java-latest-openjdk-23.0.0.0.37-1.rolling.el8.x86_64.rpm https://dl.fedoraproject.org/pub/epel/8/Everything/x86_64/Packages/j/java-latest-openjdk-headless-23.0.0.0.37-1.rolling.el8.x86_64.rpm \
    && rpm -K java-latest-openjdk-devel-23.0.0.0.37-1.rolling.el8.x86_64.rpm java-latest-openjdk-23.0.0.0.37-1.rolling.el8.x86_64.rpm java-latest-openjdk-headless-23.0.0.0.37-1.rolling.el8.x86_64.rpm \
    && rpm -ivh java-latest-openjdk-devel-23.0.0.0.37-1.rolling.el8.x86_64.rpm java-latest-openjdk-23.0.0.0.37-1.rolling.el8.x86_64.rpm java-latest-openjdk-headless-23.0.0.0.37-1.rolling.el8.x86_64.rpm \
    && rm java-latest-openjdk-devel-23.0.0.0.37-1.rolling.el8.x86_64.rpm java-latest-openjdk-23.0.0.0.37-1.rolling.el8.x86_64.rpm java-latest-openjdk-headless-23.0.0.0.37-1.rolling.el8.x86_64.rpm \
    && rpm -q java-latest-openjdk-devel ; \
    fi

RUN set -o errexit -o nounset \
    # Using rm rather than microdnf clean to clear package manager metadata
    && rm -rf "/var/cache/yum" "/var/lib/rpm" "/var/lib/dnf" \
    && mkdir /project \
    && mkdir /opt/gradle \
    && mkdir /opt/sbt \
    && mkdir /opt/ant \
    && mkdir /opt/maven \
    && chown 185:185 /project \
    \
    \
    && echo "Downloading Ant 1.10.15" \
    && wget --no-verbose --output-document=ant.zip "https://dlcdn.apache.org/ant/binaries/apache-ant-1.10.15-bin.zip" \
    && echo "Checking download hash 1.10.15" \
    && echo "1de7facbc9874fa4e5a2f045d5c659f64e0b89318c1dbc8acc6aae4595c4ffaf90a7b1ffb57f958dd08d6e086d3fff07aa90e50c77342a0aa5c9b4c36bff03a9 *ant.zip" | sha512sum --check - \
    && echo "Installing Ant 1.10.15" \
    && unzip -q ant.zip \
    && rm ant.zip \
    && mv "apache-ant-1.10.15" "/opt/ant/1.10.15/" \
    && export ANT_HOME=/opt/ant/1.10.15 \
    && cd $ANT_HOME \
    && for i in antunit ivy logging junit xml networking regexp antlr bcel jdepend bsf debugging script javamail jspc; do echo "Processing $i" ; $ANT_HOME/bin/ant -S -f fetch.xml -Ddest=system $i; done \
    \
    \
    && echo "Downloading SBT 1.8.0" \
    && wget --no-verbose --output-document=sbt.zip "https://github.com/sbt/sbt/releases/download/v1.8.0/sbt-1.8.0.zip" \
    && echo "Checking download hash 1.8.0" \
    && echo "fb52ea0bc0761176f3e38923ae5df556fba372895efb98a587f706d1ae805897 *sbt.zip" | sha256sum --check - \
    && echo "Installing SBT 1.8.0" \
    && unzip -q sbt.zip \
    && rm sbt.zip \
    && mv "sbt" "/opt/sbt/1.8.0/" \
    && export SBT_HOME=/opt/sbt/1.8.0 \
    \
    \
    && echo "Downloading Gradle 8.9" \
    && wget --no-verbose --output-document=gradle.zip "https://services.gradle.org/distributions/gradle-8.9-bin.zip" \
    && echo "Checking download hash 8.9" \
    && echo "d725d707bfabd4dfdc958c624003b3c80accc03f7037b5122c4b1d0ef15cecab *gradle.zip" | sha256sum --check - \
    && echo "Installing Gradle 8.9" \
    && unzip -q gradle.zip \
    && rm gradle.zip \
    && mv "gradle-8.9" "/opt/gradle/8.9/" \
    \
    \
    && echo "Downloading Gradle 8.7" \
    && wget --no-verbose --output-document=gradle.zip "https://services.gradle.org/distributions/gradle-8.7-bin.zip" \
    && echo "Checking download hash 8.7" \
    && echo "544c35d6bd849ae8a5ed0bcea39ba677dc40f49df7d1835561582da2009b961d *gradle.zip" | sha256sum --check - \
    && echo "Installing Gradle 8.7" \
    && unzip -q gradle.zip \
    && rm gradle.zip \
    && mv "gradle-8.7" "/opt/gradle/8.7/" \
    \
    \
    && echo "Downloading Gradle 8.6" \
    && wget --no-verbose --output-document=gradle.zip "https://services.gradle.org/distributions/gradle-8.6-bin.zip" \
    && echo "Checking download hash 8.6" \
    && echo "9631d53cf3e74bfa726893aee1f8994fee4e060c401335946dba2156f440f24c *gradle.zip" | sha256sum --check - \
    && echo "Installing Gradle 8.6" \
    && unzip -q gradle.zip \
    && rm gradle.zip \
    && mv "gradle-8.6" "/opt/gradle/8.6/" \
    \
    \
    && echo "Downloading Gradle 8.4" \
    && wget --no-verbose --output-document=gradle.zip "https://services.gradle.org/distributions/gradle-8.4-bin.zip" \
    && echo "Checking download hash 8.4" \
    && echo "3e1af3ae886920c3ac87f7a91f816c0c7c436f276a6eefdb3da152100fef72ae *gradle.zip" | sha256sum --check - \
    && echo "Installing Gradle 8.4" \
    && unzip -q gradle.zip \
    && rm gradle.zip \
    && mv "gradle-8.4" "/opt/gradle/8.4/" \
    \
    \
    && echo "Downloading Gradle 8.3" \
    && wget --no-verbose --output-document=gradle.zip "https://services.gradle.org/distributions/gradle-8.3-bin.zip" \
    && echo "Checking download hash 8.3" \
    && echo "591855b517fc635b9e04de1d05d5e76ada3f89f5fc76f87978d1b245b4f69225 *gradle.zip" | sha256sum --check - \
    && echo "Installing Gradle 8.3" \
    && unzip -q gradle.zip \
    && rm gradle.zip \
    && mv "gradle-8.3" "/opt/gradle/8.3/" \
    \
    \
    && echo "Downloading Gradle 8.0.2" \
    && wget --no-verbose --output-document=gradle.zip "https://services.gradle.org/distributions/gradle-8.0.2-bin.zip" \
    && echo "Checking download hash 8.0.2" \
    && echo "ff7bf6a86f09b9b2c40bb8f48b25fc19cf2b2664fd1d220cd7ab833ec758d0d7 *gradle.zip" | sha256sum --check - \
    && echo "Installing Gradle 8.0.2" \
    && unzip -q gradle.zip \
    && rm gradle.zip \
    && mv "gradle-8.0.2" "/opt/gradle/8.0.2/" \
    \
    \
    && echo "Downloading Gradle 7.6.3" \
    && wget --no-verbose --output-document=gradle.zip "https://services.gradle.org/distributions/gradle-7.6.3-bin.zip" \
    && echo "Checking download hash 7.6.3" \
    && echo "740c2e472ee4326c33bf75a5c9f5cd1e69ecf3f9b580f6e236c86d1f3d98cfac *gradle.zip" | sha256sum --check - \
    && echo "Installing Gradle 7.6.3" \
    && unzip -q gradle.zip \
    && rm gradle.zip \
    && mv "gradle-7.6.3" "/opt/gradle/7.6.3/" \
    \
    \
    && echo "Downloading Gradle 7.5.1" \
    && wget --no-verbose --output-document=gradle.zip "https://services.gradle.org/distributions/gradle-7.5.1-bin.zip" \
    && echo "Checking download hash 7.5.1" \
    && echo "f6b8596b10cce501591e92f229816aa4046424f3b24d771751b06779d58c8ec4 *gradle.zip" | sha256sum --check - \
    && echo "Installing Gradle 7.5.1" \
    && unzip -q gradle.zip \
    && rm gradle.zip \
    && mv "gradle-7.5.1" "/opt/gradle/7.5.1/" \
    \
    \
    && echo "Downloading Gradle 7.4.2" \
    && wget --no-verbose --output-document=gradle.zip "https://services.gradle.org/distributions/gradle-7.4.2-bin.zip" \
    && echo "Checking download hash 7.4.2" \
    && echo "29e49b10984e585d8118b7d0bc452f944e386458df27371b49b4ac1dec4b7fda *gradle.zip" | sha256sum --check - \
    && echo "Installing Gradle 7.4.2" \
    && unzip -q gradle.zip \
    && rm gradle.zip \
    && mv "gradle-7.4.2" "/opt/gradle/7.4.2/" \
    \
    \
    && echo "Downloading Gradle 7.3.3" \
    && wget --no-verbose --output-document=gradle.zip "https://services.gradle.org/distributions/gradle-7.3.3-bin.zip" \
    && echo "Checking download hash 7.3.3" \
    && echo "b586e04868a22fd817c8971330fec37e298f3242eb85c374181b12d637f80302 *gradle.zip" | sha256sum --check - \
    && echo "Installing Gradle 7.3.3" \
    && unzip -q gradle.zip \
    && rm gradle.zip \
    && mv "gradle-7.3.3" "/opt/gradle/7.3.3/" \
    \
    \
    && echo "Downloading Gradle 6.9.4" \
    && wget --no-verbose --output-document=gradle.zip "https://services.gradle.org/distributions/gradle-6.9.4-bin.zip" \
    && echo "Checking download hash 6.9.4" \
    && echo "3e240228538de9f18772a574e99a0ba959e83d6ef351014381acd9631781389a *gradle.zip" | sha256sum --check - \
    && echo "Installing Gradle 6.9.4" \
    && unzip -q gradle.zip \
    && rm gradle.zip \
    && mv "gradle-6.9.4" "/opt/gradle/6.9.4/" \
    \
    \
    && echo "Downloading Gradle 6.4.1" \
    && wget --no-verbose --output-document=gradle.zip "https://services.gradle.org/distributions/gradle-6.4.1-bin.zip" \
    && echo "Checking download hash 6.4.1" \
    && echo "e58cdff0cee6d9b422dcd08ebeb3177bc44eaa09bd9a2e838ff74c408fe1cbcd *gradle.zip" | sha256sum --check - \
    && echo "Installing Gradle 6.4.1" \
    && unzip -q gradle.zip \
    && rm gradle.zip \
    && mv "gradle-6.4.1" "/opt/gradle/6.4.1/" \
    \
    \
    && echo "Downloading Gradle 6.2.2" \
    && wget --no-verbose --output-document=gradle.zip "https://services.gradle.org/distributions/gradle-6.2.2-bin.zip" \
    && echo "Checking download hash 6.2.2" \
    && echo "0f6ba231b986276d8221d7a870b4d98e0df76e6daf1f42e7c0baec5032fb7d17 *gradle.zip" | sha256sum --check - \
    && echo "Installing Gradle 6.2.2" \
    && unzip -q gradle.zip \
    && rm gradle.zip \
    && mv "gradle-6.2.2" "/opt/gradle/6.2.2/" \
    \
    \
    && echo "Downloading Gradle 6.0.1" \
    && wget --no-verbose --output-document=gradle.zip "https://services.gradle.org/distributions/gradle-6.0.1-bin.zip" \
    && echo "Checking download hash 6.0.1" \
    && echo "d364b7098b9f2e58579a3603dc0a12a1991353ac58ed339316e6762b21efba44 *gradle.zip" | sha256sum --check - \
    && echo "Installing Gradle 6.0.1" \
    && unzip -q gradle.zip \
    && rm gradle.zip \
    && mv "gradle-6.0.1" "/opt/gradle/6.0.1/" \
    \
    \
    && echo "Downloading Gradle 5.6.4" \
    && wget --no-verbose --output-document=gradle.zip "https://services.gradle.org/distributions/gradle-5.6.4-bin.zip" \
    && echo "Checking download hash 5.6.4" \
    && echo "1f3067073041bc44554d0efe5d402a33bc3d3c93cc39ab684f308586d732a80d *gradle.zip" | sha256sum --check - \
    && echo "Installing Gradle 5.6.4" \
    && unzip -q gradle.zip \
    && rm gradle.zip \
    && mv "gradle-5.6.4" "/opt/gradle/5.6.4/" \
    \
    \
    && echo "Downloading Gradle 5.3.1" \
    && wget --no-verbose --output-document=gradle.zip "https://services.gradle.org/distributions/gradle-5.3.1-bin.zip" \
    && echo "Checking download hash 5.3.1" \
    && echo "1c59a17a054e9c82f0dd881871c9646e943ec4c71dd52ebc6137d17f82337436 *gradle.zip" | sha256sum --check - \
    && echo "Installing Gradle 5.3.1" \
    && unzip -q gradle.zip \
    && rm gradle.zip \
    && mv "gradle-5.3.1" "/opt/gradle/5.3.1/" \
    \
    \
    && echo "Downloading Gradle 5.0" \
    && wget --no-verbose --output-document=gradle.zip "https://services.gradle.org/distributions/gradle-5.0-bin.zip" \
    && echo "Checking download hash 5.0" \
    && echo "6157ac9f3410bc63644625b3b3e9e96c963afd7910ae0697792db57813ee79a6 *gradle.zip" | sha256sum --check - \
    && echo "Installing Gradle 5.0" \
    && unzip -q gradle.zip \
    && rm gradle.zip \
    && mv "gradle-5.0" "/opt/gradle/5.0/" \
    \
    \
    && echo "Downloading Gradle 4.10.3" \
    && wget --no-verbose --output-document=gradle.zip "https://services.gradle.org/distributions/gradle-4.10.3-bin.zip" \
    && echo "Checking download hash 4.10.3" \
    && echo "8626cbf206b4e201ade7b87779090690447054bc93f052954c78480fa6ed186e *gradle.zip" | sha256sum --check - \
    && echo "Installing Gradle 4.10.3" \
    && unzip -q gradle.zip \
    && rm gradle.zip \
    && mv "gradle-4.10.3" "/opt/gradle/4.10.3/" \
    \
    \
    && echo "Downloading Maven 3.8.8" \
    && wget --no-verbose --output-document=maven.zip "https://dlcdn.apache.org/maven/maven-3/3.8.8/binaries/apache-maven-3.8.8-bin.zip" \
    && echo "Checking download hash 3.8.8" \
    && echo "aa7d431c07714c410e53502b630f91fc22d2664d5974a413471a2bd4fca9c31f98fbc397d613b7c3e31d3615a9f18487867975b1332462baf7d6ca58ef3628f9 *maven.zip" | sha512sum --check - \
    && echo "Installing Maven 3.8.8" \
    && unzip -q maven.zip \
    && rm maven.zip \
    && mv "apache-maven-3.8.8" "/opt/maven/3.8.8/" \
    \
    \
    && echo "Downloading Maven 3.9.5" \
    && wget --no-verbose --output-document=maven.zip "https://dlcdn.apache.org/maven/maven-3/3.9.5/binaries/apache-maven-3.9.5-bin.zip" \
    && echo "Checking download hash 3.9.5" \
    && echo "ca59380b839c6bea8f464a08bb7873a1cab91007b95876ba9ed8a9a2b03ceac893e661d218ba3d4af3ccf46d26600fc4c59fccabba9d7b2cc4adcd8aecc1df2a *maven.zip" | sha512sum --check - \
    && echo "Installing Maven 3.9.5" \
    && unzip -q maven.zip \
    && rm maven.zip \
    && mv "apache-maven-3.9.5" "/opt/maven/3.9.5/" \
    && echo "Completed tool installation"

LABEL \
    io.k8s.description="HACBS builder image for building Java components." \
    io.k8s.display-name="HACBS BuilderImage" \
    io.openshift.tags="builder,java,jbs" \
    maintainer="Stuart Douglas <sdouglas@redhat.com>"

# Define the user
USER 185
# Define the working directory
WORKDIR /project
