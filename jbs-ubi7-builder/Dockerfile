FROM registry.access.redhat.com/ubi7/ubi-minimal:7.9-1400@sha256:10dea3251dca3362ebacb4732dc26f550d92d56406a7f125977afbddaf7dec25
USER root
ENV \
    LANG="en_US.UTF-8" \
    LANGUAGE="en_US:en" \
    LC_ALL="en_US.UTF-8" \
    APP_HOME="/root" \
    MAVEN_OPTS="-XX:+TieredCompilation -XX:TieredStopAtLevel=1" \
    HOME="/root" \
    NSS_WRAPPER_PASSWD="/etc/passwd" \
    JAVA_HOME="/usr/lib/jvm/java-1.7.0" \
    JAVA_VENDOR="openjdk" \
    UBI=7
ENV PATH="$JAVA_HOME/bin:$PATH"

RUN microdnf --setopt=tsflags=nodocs install -y apr-devel autoconf automake bc diffutils file findutils gcc gcc-c++ git glibc-devel glibc-devel.i686 gzip iproute java-1.7.0-openjdk-devel java-1.8.0-openjdk-devel java-11-openjdk-devel libcurl-devel libgcc.i686 libtool lsof make openssl-devel shadow-utils tar unzip vim-filesystem wget which zlib-devel \
    && rpm -q apr-devel autoconf automake bc diffutils file findutils gcc gcc-c++ git glibc-devel glibc-devel.i686 gzip iproute java-1.7.0-openjdk-devel java-1.8.0-openjdk-devel java-11-openjdk-devel libcurl-devel libgcc.i686 libtool lsof make openssl-devel shadow-utils tar unzip vim-filesystem wget which zlib-devel

RUN if [ "7" = "8" ] ; then rpm --import https://www.centos.org/keys/RPM-GPG-KEY-CentOS-Official \
    && rpm -q gpg-pubkey-8483c65d-5ccc5b19 \
    # XXX: RHEL 8 does not have ninja-build, so grabbing from CentOS 8
    && wget --no-verbose https://vault.centos.org/centos/8/PowerTools/x86_64/os/Packages/ninja-build-1.8.2-1.el8.x86_64.rpm \
    && rpm -K ninja-build-1.8.2-1.el8.x86_64.rpm \
    && rpm -ivh ninja-build-1.8.2-1.el8.x86_64.rpm \
    && rm ninja-build-1.8.2-1.el8.x86_64.rpm \
    && rpm -q ninja-build ; \
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
    && echo "Downloading Ant 1.9.16" \
    && wget --no-verbose --output-document=ant.zip "https://dlcdn.apache.org/ant/binaries/apache-ant-1.9.16-bin.zip" \
    && echo "Checking download hash 1.9.16" \
    && echo "a815d3f323efa30db3451cc7c6d111ef343bbe2738e23161dbee1cbbeecf5b9a *ant.zip" | sha256sum --check - \
    && echo "Installing Ant 1.9.16" \
    && unzip -q ant.zip \
    && rm ant.zip \
    && mv "apache-ant-1.9.16" "/opt/ant/1.9.16/" \
    && export ANT_HOME=/opt/ant/1.9.16 \
    && cd $ANT_HOME \
    && for i in antunit ivy logging junit xml networking regexp antlr bcel jdepend bsf debugging script javamail jspc; do echo "Processing $i" ; $ANT_HOME/bin/ant -S -f fetch.xml -Ddest=system $i; done \
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
