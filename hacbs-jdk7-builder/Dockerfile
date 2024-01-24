FROM registry.access.redhat.com/ubi7/ubi-minimal@sha256:2bb01f6a9e5ab028d53af3c830926e287e5b83ecc4f4c0ac03d17aa263f7f7fb
USER root
ENV \
    LANG="en_US.UTF-8" \
    LANGUAGE="en_US:en" \
    LC_ALL="en_US.UTF-8" \
    APP_HOME="/root" \
    HOME="/root" \
    NSS_WRAPPER_PASSWD="/etc/passwd" \
    JAVA_HOME="/lib/jvm/java-1.7.0" \
    PATH="$JAVA_HOME/bin:$PATH"

RUN microdnf --setopt=tsflags=nodocs install -y shadow-utils

RUN mkdir /project && chown 185:185 /project

RUN microdnf --setopt=tsflags=nodocs install -y apr-devel autoconf automake bc diffutils file findutils gcc gcc-c++ git glibc-devel glibc-devel.i686 gzip iproute libcurl-devel libgcc.i686 libtool lsof make openssl-devel shadow-utils tar unzip wget which zlib-devel \
    && microdnf clean all \
    && rpm -q apr-devel autoconf automake bc diffutils file findutils gcc gcc-c++ git glibc-devel glibc-devel.i686 gzip iproute libcurl-devel libgcc.i686 libtool lsof make openssl-devel shadow-utils tar unzip wget which zlib-devel

RUN microdnf --setopt=tsflags=nodocs install -y java-1.7.0-openjdk-devel java-1.8.0-openjdk-devel java-11-openjdk-devel

RUN microdnf --setopt=tsflags=nodocs install -y vim-filesystem

RUN set -o errexit -o nounset \
    && mkdir /opt/ant && mkdir /opt/maven \
         && echo "Downloading Ant 1.9.16" \
    && wget --no-verbose --output-document=ant.zip "https://dlcdn.apache.org/ant/binaries/apache-ant-1.9.16-bin.zip" \
    \
    && echo "Checking download hash 1.9.16" \
    && echo "a815d3f323efa30db3451cc7c6d111ef343bbe2738e23161dbee1cbbeecf5b9a *ant.zip" | sha256sum --check - \
    \
    && echo "Installing Ant 1.9.16" \
    && unzip ant.zip \
    && rm ant.zip \
    && mv "apache-ant-1.9.16" "/opt/ant/1.9.16/" \
    && export ANT_HOME=/opt/ant/1.9.16 \
    && cd $ANT_HOME \
    && for i in antunit ivy logging junit xml networking regexp antlr bcel jdepend bsf debugging script javamail jspc; do $ANT_HOME/bin/ant -f fetch.xml -Ddest=system $i; done \
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
RUN microdnf clean all && [ ! -d /var/cache/yum ] || rm -rf /var/cache/yum
# Define the user
USER 185
# Define the working directory
WORKDIR /project
