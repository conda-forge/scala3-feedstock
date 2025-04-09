#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Build JAR files with sbt
sbt dist/Universal/packageBin

# Create pom.xml files so maven can be used to download licenses
sbt makePom

mkdir -p ${SRC_DIR}/target/generated-resources/licenses
pom_file=$(find -name scala3_3-${PKG_VERSION}-bin-SNAPSHOT-nonbootstrapped.pom)
pushd $(dirname ${pom_file})
    mv scala3_3-${PKG_VERSION}-bin-SNAPSHOT-nonbootstrapped.pom pom.xml
    sed -i 's/-bin-SNAPSHOT-nonbootstrapped//' pom.xml
    mvn license:download-licenses -Dgoal=download-licenses
    cp ./target/generated-resources/licenses/* ${SRC_DIR}/target/generated-resources/licenses
popd

# Install JAR files
mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/${PKG_NAME}

mv dist/target/universal/scala3-${PKG_VERSION}-bin-SNAPSHOT.zip .
unzip scala3-${PKG_VERSION}-bin-SNAPSHOT.zip
cp -r scala3-${PKG_VERSION}-bin-SNAPSHOT/* ${PREFIX}/libexec/${PKG_NAME}
rm -rf ${PREFIX}/libexec/${PKG_NAME}/maven2
ln -sf ${PREFIX}/libexec/${PKG_NAME}/bin/* ${PREFIX}/bin
