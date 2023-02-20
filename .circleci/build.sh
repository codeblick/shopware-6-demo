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

LATEST=5
TAGS=$(curl -s https://api.github.com/repos/shopware/production/branches?per_page=100 | jq -r '.[] | select(.name | test("^\\d{1,2}\\.\\d{1,2}\\.\\d{1,2}\\.\\d{1,2}")) | .name' | sort -Vr | sed -n 1,${LATEST}p)

for TAG in $TAGS
do
    build $TAG
done

LATEST_TAG=$(echo $TAGS | awk '{print $1;}')

docker tag codeblick/shopware-6-demo:${LATEST_TAG} codeblick/shopware-6-demo
docker push codeblick/shopware-6-demo
