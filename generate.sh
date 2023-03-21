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


  export TOOL_STRING="$TOOL_STRING"

  envsubst '$IMAGE_NAME,$BASE_IMAGE,$MAVEN_VERSION,$MAVEN_SHA,$GRADLE_VERSION,$GRADLE_SHA,$GRADLE_MANIPULATOR_VERSION,$CLI_JAR_SHA,$ANALYZER_INIT_SHA,$TOOL_STRING,$JAVA_PACKAGE' < $DIR/Dockerfile.template > $DIR/$IMAGE_NAME/Dockerfile
  envsubst '$IMAGE_NAME,$BASE_IMAGE' < $DIR/push.yaml > $DIR/.tekton/$IMAGE_NAME-push.yaml
  envsubst '$IMAGE_NAME,$BASE_IMAGE' < $DIR/pull-request.yaml > $DIR/.tekton/$IMAGE_NAME-pull-request.yaml
}

export MAVEN_VERSION=3.8.8
export MAVEN_SHA=332088670d14fa9ff346e6858ca0acca304666596fec86eea89253bd496d3c90deae2be5091be199f48e09d46cec817c6419d5161fb4ee37871503f472765d00
export GRADLE_MANIPULATOR_VERSION=3.11
export CLI_JAR_SHA=cbd2cf43ea34953f9a98f85639a4a25d2fd8827dcb9f1039dc7c48233698ada5
export ANALYZER_INIT_SHA=7d1be22c516e24a67d8c6f3a1e7f949a5d5d8245e918458cae1e20c4226a1acf

export GRADLE_8_0_2=ff7bf6a86f09b9b2c40bb8f48b25fc19cf2b2664fd1d220cd7ab833ec758d0d7
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
