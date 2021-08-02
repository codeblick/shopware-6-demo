#!/usr/bin/env bash
set -e

build() {
    echo "Building Shopware ${1}"
    docker build . \
        -t codeblick/shopware-6-demo:${1} \
        --build-arg COB_SW_VERSION=${1} \
        -q

    echo "Pushing Shopware ${1}"
    docker push codeblick/shopware-6-demo:${1}
}

LATEST=1
TAGS=$(git ls-remote --tags --refs https://github.com/shopware/production.git | sed -n 's_^.*/\([^/}]*\)$_\1_p' | sort -Vr | sed -n 1,${LATEST}p)

for TAG in $TAGS
do
    build $TAG
done

docker tag codeblick/shopware-6-demo:$(echo $TAGS | head -n 1) codeblick/shopware-6-demo
docker push codeblick/shopware-6-demo
