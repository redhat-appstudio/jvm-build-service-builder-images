FROM registry.access.redhat.com/ubi7/ubi-minimal
USER root
ENV \
    LANG="en_US.UTF-8" \
    LANGUAGE="en_US:en" \
    LC_ALL="en_US.UTF-8" \
    APP_HOME="/home/jboss" \
    MAVEN_HOME="/usr/share/maven" \
    MAVEN_OPTS="-XX:+TieredCompilation -XX:TieredStopAtLevel=1" \
    MAVEN_VERSION="3.8.8" \
    HOME="/home/jboss" \
    NSS_WRAPPER_PASSWD="/etc/passwd" \
    JAVA_HOME="/lib/jvm/java-1.7.0" \
    PATH="$PATH:$JAVA_HOME/bin" \
    BASE_URL=https://dlcdn.apache.org/maven/maven-3/3.8.8/binaries \
    MAVEN_SHA=332088670d14fa9ff346e6858ca0acca304666596fec86eea89253bd496d3c90deae2be5091be199f48e09d46cec817c6419d5161fb4ee37871503f472765d00

RUN microdnf --setopt=tsflags=nodocs install -y shadow-utils

RUN mkdir /project && chown 185:185 /project

RUN microdnf --setopt=tsflags=nodocs install -y apr-devel autoconf automake bc diffutils file findutils gcc gcc-c++ git glibc-devel glibc-devel.i686 gzip libcurl-devel libgcc.i686 libtool lsof make openssl-devel shadow-utils tar unzip wget which zlib-devel \
    && microdnf clean all \
    && rpm -q apr-devel autoconf automake bc diffutils file findutils gcc gcc-c++ git glibc-devel glibc-devel.i686 gzip libcurl-devel libgcc.i686 libtool lsof make openssl-devel shadow-utils tar unzip wget which zlib-devel

RUN microdnf --setopt=tsflags=nodocs install -y java-1.7.0-openjdk-devel

RUN microdnf --setopt=tsflags=nodocs install -y vim-filesystem

RUN mkdir -p /usr/share/maven/ref && curl -fsSL -o /tmp/apache-maven.tar.gz ${BASE_URL}/apache-maven-3.8.8-bin.tar.gz   && echo "${MAVEN_SHA}  /tmp/apache-maven.tar.gz" | sha512sum -c -   && tar -xzf /tmp/apache-maven.tar.gz -C /usr/share/maven --strip-components=1   && rm -f /tmp/apache-maven.tar.gz   && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

RUN set -o errexit -o nounset \
    && mkdir /opt/ant \
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
    && for i in antunit ivy logging junit xml networking regexp antlr bcel jdepend bsf debugging script javamail jspc; do $ANT_HOME/bin/ant -f fetch.xml -Ddest=system $i; done

LABEL \
    io.cekit.version="4.1.0" \
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
