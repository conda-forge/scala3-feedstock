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
mkdir -p ${PREFIX}/libexec/scala3

mv dist/target/universal/scala3-${PKG_VERSION}-bin-SNAPSHOT.zip .
unzip scala3-${PKG_VERSION}-bin-SNAPSHOT.zip
cp -r scala3-${PKG_VERSION}-bin-SNAPSHOT/* ${PREFIX}/libexec/scala3
rm -rf ${PREFIX}/libexec/scala3/maven2

tee ${PREFIX}/bin/scala << EOF
#!/bin/sh
exec \${CONDA_PREFIX}/libexec/scala3/bin/scala "\$@"
EOF
chmod +x ${PREFIX}/bin/scala

tee ${PREFIX}/bin/scalac << EOF
#!/bin/sh
exec \${CONDA_PREFIX}/libexec/scala3/bin/scalac "\$@"
EOF
chmod +x ${PREFIX}/bin/scalac

tee ${PREFIX}/bin/scaladoc << EOF
#!/bin/sh
exec \${CONDA_PREFIX}/libexec/scala3/bin/scaladoc "\$@"
EOF
chmod +x ${PREFIX}/bin/scaladoc

tee ${PREFIX}/bin/scala_legacy << EOF
#!/bin/sh
exec \${CONDA_PREFIX}/libexec/scala3/bin/scala_legacy "\$@"
EOF
chmod +x ${PREFIX}/bin/scala_legacy

tee ${PREFIX}/bin/scala.cmd << EOF
call %CONDA_PREFIX%\libexec\scala3\bin\scala.bat %*
EOF

tee ${PREFIX}/bin/scalac.cmd << EOF
call %CONDA_PREFIX%\libexec\scala3\bin\scalac.bat %*
EOF

tee ${PREFIX}/bin/scaladoc.cmd << EOF
call %CONDA_PREFIX%\libexec\scala3\bin\scaladoc.bat %*
EOF
