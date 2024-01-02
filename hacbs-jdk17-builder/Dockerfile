FROM registry.access.redhat.com/ubi8/ubi-minimal@sha256:288239021a429a311233d73a7d91b0a1dd889ab7bbc247d913e1b5726e25354a
USER root
ENV \
    LANG="en_US.UTF-8" \
    LANGUAGE="en_US:en" \
    LC_ALL="en_US.UTF-8" \
    APP_HOME="/root" \
    MAVEN_OPTS="-XX:+TieredCompilation -XX:TieredStopAtLevel=1" \
    GRADLE_OPTS="-Dorg.gradle.daemon=false" \
    HOME="/root" \
    NSS_WRAPPER_PASSWD="/etc/passwd" \
    JAVA_HOME="/usr/lib/jvm/java-17" \
    JAVA_VENDOR="openjdk" \
    UBI=8
ENV PATH="$JAVA_HOME/bin:$PATH"

RUN microdnf --setopt=install_weak_deps=0 --setopt=tsflags=nodocs install -y apr-devel autoconf automake bc buildah bzip2-devel cmake diffutils emacs-filesystem file findutils gcc gcc-c++ git glibc-devel glibc-devel.i686 glibc-langpack-en glibc-static golang gzip hostname iproute java-1.8.0-openjdk-devel java-11-openjdk-devel java-17-openjdk-devel java-21-openjdk-devel libcurl-devel libgcc.i686 libstdc++-static libtool lsof make openssl-devel podman shadow-utils tar tzdata-java unzip vim-filesystem wget which zlib-devel \
    && microdnf clean all \
    && rpm -q apr-devel autoconf automake bc buildah bzip2-devel cmake diffutils emacs-filesystem file findutils gcc gcc-c++ git glibc-devel glibc-devel.i686 glibc-langpack-en glibc-static golang gzip hostname iproute java-1.8.0-openjdk-devel java-11-openjdk-devel java-17-openjdk-devel java-21-openjdk-devel libcurl-devel libgcc.i686 libstdc++-static libtool lsof make openssl-devel podman shadow-utils tar tzdata-java unzip vim-filesystem wget which zlib-devel

RUN if [ "8" = "8" ] ; then rpm --import https://www.centos.org/keys/RPM-GPG-KEY-CentOS-Official \
    && rpm -q gpg-pubkey-8483c65d-5ccc5b19 \
    # XXX: RHEL 8 does not have ninja-build, so grabbing from CentOS 8
    && wget --no-verbose https://vault.centos.org/centos/8/PowerTools/x86_64/os/Packages/ninja-build-1.8.2-1.el8.x86_64.rpm \
    && rpm -K ninja-build-1.8.2-1.el8.x86_64.rpm \
    && rpm -ivh ninja-build-1.8.2-1.el8.x86_64.rpm \
    && rm ninja-build-1.8.2-1.el8.x86_64.rpm \
    && rpm -q ninja-build \
    && wget --no-verbose https://vault.centos.org/centos/8/AppStream/x86_64/os/Packages/git-lfs-2.11.0-2.el8.x86_64.rpm \
    && rpm -K git-lfs-2.11.0-2.el8.x86_64.rpm \
    && rpm -ivh git-lfs-2.11.0-2.el8.x86_64.rpm \
    && rm git-lfs-2.11.0-2.el8.x86_64.rpm \
    && rpm -q git-lfs ; \
    fi

RUN if [ "8" = "8" ] ; then set -o errexit -o nounset \
    && echo "Downloading Gradle Manipulator" \
    && wget --no-verbose --output-document=cli.jar "https://repo1.maven.org/maven2/org/jboss/gm/cli/3.16/cli-3.16.jar" \
    && wget --no-verbose --output-document=analyzer-init.gradle "https://repo1.maven.org/maven2/org/jboss/gm/analyzer/3.16/analyzer-3.16-init.gradle" \
    \
    && echo "Checking cli.jar download hash" \
    && echo "555d10b7a94fbb5cee488a79276693a4b29ba61ec8144ef56fd8189fe7e5a83e *cli.jar" | sha256sum --check - \
    \
    && echo "Checking analyzer-init.gradle download hash" \
    && echo "6d2ef2f1eb9d75bd8e070a819e633f5e59ae1d63147e9e7fadc69902790634a1 *analyzer-init.gradle" | sha256sum --check - \
    \
    && echo "Installing Gradle Manipulator" \
    && mkdir "/usr/share/gradle-manipulator" \
    && mv cli.jar analyzer-init.gradle "/usr/share/gradle-manipulator/" \
    && mkdir "/usr/share/gradle-manipulator/bin" \
    && echo -e "#!/bin/sh\n\nset -eu\nARGS=\"-l \${GRADLE_HOME}\"\njava -jar /usr/share/gradle-manipulator/cli.jar \"\${ARGS}\" --init-script=/usr/share/gradle-manipulator/analyzer-init.gradle \$@" > /usr/share/gradle-manipulator/bin/gradle-manipulator \
    && chmod 755 /usr/share/gradle-manipulator/bin/gradle-manipulator \
    && ln --symbolic "/usr/share/gradle-manipulator/bin/gradle-manipulator" /usr/bin/gradle-manipulator ; \
    #we test out gradle manipulator as part of the gradle installation
    fi

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
    && echo "Downloading Gradle 7.6.3" \
    && wget --no-verbose --output-document=gradle.zip "https://services.gradle.org/distributions/gradle-7.6.3-bin.zip" \
    && echo "Checking download hash 7.6.3" \
    && echo "740c2e472ee4326c33bf75a5c9f5cd1e69ecf3f9b580f6e236c86d1f3d98cfac *gradle.zip" | sha256sum --check - \
    && echo "Installing Gradle 7.6.3" \
    && unzip gradle.zip \
    && rm gradle.zip \
    && mv "gradle-7.6.3" "/opt/gradle/7.6.3/"     \
    \
    && echo "Downloading Gradle 7.5.1" \
    && wget --no-verbose --output-document=gradle.zip "https://services.gradle.org/distributions/gradle-7.5.1-bin.zip" \
    && echo "Checking download hash 7.5.1" \
    && echo "f6b8596b10cce501591e92f229816aa4046424f3b24d771751b06779d58c8ec4 *gradle.zip" | sha256sum --check - \
    && echo "Installing Gradle 7.5.1" \
    && unzip gradle.zip \
    && rm gradle.zip \
    && mv "gradle-7.5.1" "/opt/gradle/7.5.1/"     \
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
    && echo "Downloading Gradle 5.6.4" \
    && wget --no-verbose --output-document=gradle.zip "https://services.gradle.org/distributions/gradle-5.6.4-bin.zip" \
    && echo "Checking download hash 5.6.4" \
    && echo "1f3067073041bc44554d0efe5d402a33bc3d3c93cc39ab684f308586d732a80d *gradle.zip" | sha256sum --check - \
    && echo "Installing Gradle 5.6.4" \
    && unzip gradle.zip \
    && rm gradle.zip \
    && mv "gradle-5.6.4" "/opt/gradle/5.6.4/"     \
    \
    && echo "Downloading Gradle 4.10.3" \
    && wget --no-verbose --output-document=gradle.zip "https://services.gradle.org/distributions/gradle-4.10.3-bin.zip" \
    && echo "Checking download hash 4.10.3" \
    && echo "8626cbf206b4e201ade7b87779090690447054bc93f052954c78480fa6ed186e *gradle.zip" | sha256sum --check - \
    && echo "Installing Gradle 4.10.3" \
    && unzip gradle.zip \
    && rm gradle.zip \
    && mv "gradle-4.10.3" "/opt/gradle/4.10.3/"     \
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
