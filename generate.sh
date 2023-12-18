#!/bin/bash

set -eu

DIR=`dirname $0`
generate () {

  export IMAGE_NAME=hacbs-jdk$JAVA-builder
  mkdir -p $DIR/$IMAGE_NAME
  #deal with gradle and sbt and ant

  export TOOL_STRING=""

  ant=`yq .spec.builders.jdk$JAVA.tag $DIR/image-config.yaml | grep -o -E  "ant:.*,?" | cut -d , -f 1 | cut -d : -f 2`
  echo ant
  for i in ${ant//;/ }
  do
      export ANT_VERSION=$i
      export ANT_DOWNLOAD_SHA256=$(name=ANT_${ANT_VERSION//./_} && echo ${!name})
      res=`envsubst '$ANT_DOWNLOAD_SHA256,$ANT_VERSION' < $DIR/ant.template`
      export TOOL_STRING="$TOOL_STRING $res"
  done

  sbt=`yq .spec.builders.jdk$JAVA.tag $DIR/image-config.yaml | grep -o -E  "sbt:.*,?" | cut -d , -f 1 | cut -d : -f 2`
  echo sbt
  for i in ${sbt//;/ }
  do
      export SBT_VERSION=$i
      export SBT_DOWNLOAD_SHA256=$(name=SBT_${SBT_VERSION//./_} && echo ${!name})
      res=`envsubst '$SBT_DOWNLOAD_SHA256,$SBT_VERSION' < $DIR/sbt.template`
      export TOOL_STRING="$TOOL_STRING $res"
  done

  gradle=`yq .spec.builders.jdk$JAVA.tag $DIR/image-config.yaml | grep -o -E  "gradle:.*,?" | cut -d , -f 1 | cut -d : -f 2`
  echo $gradle
  for i in ${gradle//;/ }
  do
      export GRADLE_VERSION=$i
      export GRADLE_DOWNLOAD_SHA256=$(name=GRADLE_${GRADLE_VERSION//./_} && echo ${!name})
      res=`envsubst '$GRADLE_DOWNLOAD_SHA256,$GRADLE_VERSION' < $DIR/gradle.template`
      export TOOL_STRING="$TOOL_STRING $res"
  done

  maven=`yq .spec.builders.jdk$JAVA.tag $DIR/image-config.yaml | grep -o -E  "maven:.*,?" | cut -d , -f 1 | cut -d : -f 2`
  echo maven
  for i in ${maven//;/ }
  do
      export MAVEN_VERSION=$i
      export MAVEN_DOWNLOAD_SHA512=$(name=MAVEN_${MAVEN_VERSION//./_} && echo ${!name})
      res=`envsubst '$MAVEN_DOWNLOAD_SHA512,$MAVEN_VERSION' < $DIR/maven.template`
      export TOOL_STRING="$TOOL_STRING $res"
  done

  export TOOL_STRING="$TOOL_STRING"

  envsubst '$IMAGE_NAME,$BASE_IMAGE,$MAVEN_VERSION,$MAVEN_SHA,$GRADLE_VERSION,$GRADLE_SHA,$GRADLE_MANIPULATOR_VERSION,$CLI_JAR_SHA,$ANALYZER_INIT_SHA,$TOOL_STRING,$JAVA_PACKAGE' < $DIR/Dockerfile.template > $DIR/$IMAGE_NAME/Dockerfile
  envsubst '$IMAGE_NAME,$BASE_IMAGE' < $DIR/push.yaml > $DIR/.tekton/$IMAGE_NAME-push.yaml
  envsubst '$IMAGE_NAME,$BASE_IMAGE' < $DIR/pull-request.yaml > $DIR/.tekton/$IMAGE_NAME-pull-request.yaml
}

export GRADLE_MANIPULATOR_VERSION=3.14
export CLI_JAR_SHA=4111205a0ba07d7234ac314b4fcb94b2aa1a1e74f737cfb15331eaddfe3a1578
export ANALYZER_INIT_SHA=be859af4d9abade9eb36c607f9b02c0995f2d3da82ee8d74bb8a7ef1dde930f4

export MAVEN_3_8_8=aa7d431c07714c410e53502b630f91fc22d2664d5974a413471a2bd4fca9c31f98fbc397d613b7c3e31d3615a9f18487867975b1332462baf7d6ca58ef3628f9
export MAVEN_3_9_5=ca59380b839c6bea8f464a08bb7873a1cab91007b95876ba9ed8a9a2b03ceac893e661d218ba3d4af3ccf46d26600fc4c59fccabba9d7b2cc4adcd8aecc1df2a

export GRADLE_8_4=3e1af3ae886920c3ac87f7a91f816c0c7c436f276a6eefdb3da152100fef72ae
export GRADLE_8_3=591855b517fc635b9e04de1d05d5e76ada3f89f5fc76f87978d1b245b4f69225
export GRADLE_8_0_2=ff7bf6a86f09b9b2c40bb8f48b25fc19cf2b2664fd1d220cd7ab833ec758d0d7
export GRADLE_7_6_3=740c2e472ee4326c33bf75a5c9f5cd1e69ecf3f9b580f6e236c86d1f3d98cfac
export GRADLE_7_5_1=f6b8596b10cce501591e92f229816aa4046424f3b24d771751b06779d58c8ec4
export GRADLE_7_4_2=29e49b10984e585d8118b7d0bc452f944e386458df27371b49b4ac1dec4b7fda
export GRADLE_6_9_2=8b356fd8702d5ffa2e066ed0be45a023a779bba4dd1a68fd11bc2a6bdc981e8f
export GRADLE_5_6_4=1f3067073041bc44554d0efe5d402a33bc3d3c93cc39ab684f308586d732a80d
export GRADLE_4_10_3=8626cbf206b4e201ade7b87779090690447054bc93f052954c78480fa6ed186e

export SBT_1_8_0=fb52ea0bc0761176f3e38923ae5df556fba372895efb98a587f706d1ae805897

export ANT_1_10_13=800238184231f8002210fd0c75681bc20ce12f527c9b1dcb95fc8a33803bfce1

export JAVA=17
export JAVA_PACKAGE=$JAVA
generate

export JAVA=8
export JAVA_PACKAGE=1.8.0
generate

export JAVA=11
export JAVA_PACKAGE=$JAVA
generate
