#!/bin/bash

set -eu

DIR=`dirname $0`
generate () {

  export IMAGE_NAME=jbs-ubi$UBI-builder
  mkdir -p $DIR/$IMAGE_NAME
  export TOOL_STRING=""

  ant=`yq .spec.builders.ubi$UBI.tag $DIR/image-config.yaml | grep -o -E  "ant:.*,?" | cut -d , -f 1 | cut -d : -f 2`
  echo ant $ant
  for i in ${ant//;/ }
  do
      export ANT_VERSION=$i
      export ANT_DOWNLOAD_SHA512=$(name=ANT_${ANT_VERSION//./_} && echo ${!name})
      res=`envsubst '$ANT_DOWNLOAD_SHA512,$ANT_VERSION' < $DIR/ant.template`
      export TOOL_STRING="${TOOL_STRING:+$TOOL_STRING }$res"$'\n'
  done

  gradle=`yq .spec.builders.ubi$UBI.tag $DIR/image-config.yaml | grep -o -E  "gradle:.*,?" | cut -d , -f 1 | cut -d : -f 2`
  echo gradle $gradle
  for i in ${gradle//;/ }
  do
      export GRADLE_VERSION=$i
      export GRADLE_DOWNLOAD_SHA256=$(name=GRADLE_${GRADLE_VERSION//./_} && echo ${!name})
      res=`envsubst '$GRADLE_DOWNLOAD_SHA256,$GRADLE_VERSION' < $DIR/gradle.template`
      export TOOL_STRING="${TOOL_STRING:+$TOOL_STRING }$res"$'\n'
  done

  maven=`yq .spec.builders.ubi$UBI.tag $DIR/image-config.yaml | grep -o -E  "maven:.*,?" | cut -d , -f 1 | cut -d : -f 2`
  echo maven $maven
  for i in ${maven//;/ }
  do
      export MAVEN_VERSION=$i
      export MAVEN_DOWNLOAD_SHA512=$(name=MAVEN_${MAVEN_VERSION//./_} && echo ${!name})
      res=`envsubst '$ALT_DEPLOY_1_8,$MAVEN_DOWNLOAD_SHA512,$MAVEN_VERSION' < $DIR/maven.template`
      export TOOL_STRING="${TOOL_STRING:+$TOOL_STRING }$res"$'\n'
  done

  sbt=`yq .spec.builders.ubi$UBI.tag $DIR/image-config.yaml | grep -o -E  "sbt:.*,?" | cut -d , -f 1 | cut -d : -f 2`
  echo sbt $sbt
  for i in ${sbt//;/ }
  do
      export SBT_VERSION=$i
      export SBT_DOWNLOAD_SHA256=$(name=SBT_${SBT_VERSION//./_} && echo ${!name})
      res=`envsubst '$SBT_DOWNLOAD_SHA256,$SBT_VERSION' < $DIR/sbt.template`
      export TOOL_STRING="${TOOL_STRING:+$TOOL_STRING }$res"$'\n'
  done
  export TOOL_STRING="$TOOL_STRING    && echo \"Completed tool installation\""

  if [ "$UBI" == "7" ]; then
      export UBI_PKGS=$UBI7_PKGS
  else
      export UBI_PKGS=$UBI8_PKGS
  fi

  envsubst '$IMAGE_NAME,$MAVEN_VERSION,$MAVEN_SHA,$GRADLE_VERSION,$GRADLE_SHA,$GRADLE_MANIPULATOR_VERSION,$GRADLE_MANIPULATOR_HOME,$CLI_JAR_SHA,$ANALYZER_INIT_SHA,$TOOL_STRING,$JAVA_PACKAGE,$UBI,$UBI_PKGS,$UBI_IMAGE' < $DIR/Dockerfile.template > $DIR/$IMAGE_NAME/Dockerfile
  if [ "$UBI" == "7" ]; then
      # Earlier microdnf doesn't support install_weak_deps.
      sed -i "s/--setopt=install_weak_deps=0 //" $DIR/$IMAGE_NAME/Dockerfile
  fi
}

export MAVEN_3_8_8=aa7d431c07714c410e53502b630f91fc22d2664d5974a413471a2bd4fca9c31f98fbc397d613b7c3e31d3615a9f18487867975b1332462baf7d6ca58ef3628f9
export MAVEN_3_9_5=ca59380b839c6bea8f464a08bb7873a1cab91007b95876ba9ed8a9a2b03ceac893e661d218ba3d4af3ccf46d26600fc4c59fccabba9d7b2cc4adcd8aecc1df2a
export ALT_DEPLOY_1_8=6818489c1a44a3f119d4a825aa3b084a148f0fab1b9d6601c1430a5dc7a86a06cc56462fcc581206bdf0b6680587ae159a91369a4eba1bfbc5e9f6f9d37cd5a9


export GRADLE_8_9=d725d707bfabd4dfdc958c624003b3c80accc03f7037b5122c4b1d0ef15cecab
export GRADLE_8_7=544c35d6bd849ae8a5ed0bcea39ba677dc40f49df7d1835561582da2009b961d
export GRADLE_8_6=9631d53cf3e74bfa726893aee1f8994fee4e060c401335946dba2156f440f24c
export GRADLE_8_4=3e1af3ae886920c3ac87f7a91f816c0c7c436f276a6eefdb3da152100fef72ae
export GRADLE_8_3=591855b517fc635b9e04de1d05d5e76ada3f89f5fc76f87978d1b245b4f69225
export GRADLE_8_0_2=ff7bf6a86f09b9b2c40bb8f48b25fc19cf2b2664fd1d220cd7ab833ec758d0d7
export GRADLE_7_6_3=740c2e472ee4326c33bf75a5c9f5cd1e69ecf3f9b580f6e236c86d1f3d98cfac
export GRADLE_7_5_1=f6b8596b10cce501591e92f229816aa4046424f3b24d771751b06779d58c8ec4
export GRADLE_7_4_2=29e49b10984e585d8118b7d0bc452f944e386458df27371b49b4ac1dec4b7fda
export GRADLE_7_3_3=b586e04868a22fd817c8971330fec37e298f3242eb85c374181b12d637f80302
export GRADLE_7_1_1=bf8b869948901d422e9bb7d1fa61da6a6e19411baa7ad6ee929073df85d6365d
export GRADLE_6_9_4=3e240228538de9f18772a574e99a0ba959e83d6ef351014381acd9631781389a
export GRADLE_6_4_1=e58cdff0cee6d9b422dcd08ebeb3177bc44eaa09bd9a2e838ff74c408fe1cbcd
export GRADLE_6_2_2=0f6ba231b986276d8221d7a870b4d98e0df76e6daf1f42e7c0baec5032fb7d17
export GRADLE_6_0_1=d364b7098b9f2e58579a3603dc0a12a1991353ac58ed339316e6762b21efba44
export GRADLE_5_6_4=1f3067073041bc44554d0efe5d402a33bc3d3c93cc39ab684f308586d732a80d
export GRADLE_5_3_1=1c59a17a054e9c82f0dd881871c9646e943ec4c71dd52ebc6137d17f82337436
export GRADLE_5_0=6157ac9f3410bc63644625b3b3e9e96c963afd7910ae0697792db57813ee79a6
export GRADLE_4_10_3=8626cbf206b4e201ade7b87779090690447054bc93f052954c78480fa6ed186e

export SBT_1_8_0=fb52ea0bc0761176f3e38923ae5df556fba372895efb98a587f706d1ae805897

export ANT_1_9_16=b9324cffeb5b113fa289126db1408b9a0125757b598d763f076fc5deec97fb43f27979974cadcac79b6573d84dcb2d1d5bf59b7972fb2abe5ed3d9fed445b04e
export ANT_1_10_15=1de7facbc9874fa4e5a2f045d5c659f64e0b89318c1dbc8acc6aae4595c4ffaf90a7b1ffb57f958dd08d6e086d3fff07aa90e50c77342a0aa5c9b4c36bff03a9

export UBI8_PKGS="apr-devel autoconf automake bc buildah bzip2-devel cmake curl diffutils emacs-filesystem file findutils gcc gcc-c++ git glibc-devel glibc-devel.i686 glibc-langpack-en glibc-static golang gzip hostname iproute java-1.8.0-openjdk-devel java-11-openjdk-devel java-17-openjdk-devel java-21-openjdk-devel jq libcurl-devel libgcc.i686 libstdc++-static libtool lsof make openssl-devel perl-Digest-SHA podman shadow-utils tar tzdata-java unzip vim-minimal wget which zip zlib-devel"
export UBI7_PKGS="apr-devel autoconf automake bc curl diffutils file findutils gcc gcc-c++ git glibc-devel glibc-devel.i686 gzip iproute java-1.7.0-openjdk-devel java-1.8.0-openjdk-devel java-11-openjdk-devel libcurl-devel libgcc.i686 libtool lsof make openssl-devel perl-Digest-SHA shadow-utils tar unzip vim-minimal wget which zip zlib-devel"

echo "Generating for UBI8 / J17"
export JAVA=17
export JAVA_PACKAGE=$JAVA
export UBI=8
export UBI_IMAGE=$(cat Dockerfile.ubi8 | grep FROM)
generate

echo
echo "Generating for UBI7 / J7"
export JAVA=7
export JAVA_PACKAGE=1.7.0
export UBI=7
export UBI_IMAGE=$(cat Dockerfile.ubi7 | grep FROM)
generate
