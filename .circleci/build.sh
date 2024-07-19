#!/usr/bin/env bash
set -e

build() {
    echo "Building Shopware $1"

    if  [[ $1 == v6.4.* ]]; then
        PHP_VERSION=8.1
    elif  [[ $1 == v6.5.* ]]; then
        PHP_VERSION=8.2
    else
        PHP_VERSION=8.3
    fi

    docker build -q -t codeblick/shopware-6-demo:$1 --build-arg PHP_VERSION=$PHP_VERSION --build-arg SW_VERSION=$1 .
    docker push codeblick/shopware-6-demo:$1
}

TAGS=$(curl -s https://api.github.com/repos/shopware/shopware/tags?per_page=3 | jq -r '. | reverse | .[].name') 

for TAG in $TAGS
do
    build $TAG
done

docker tag codeblick/shopware-6-demo:$TAG codeblick/shopware-6-demo
docker push codeblick/shopware-6-demo
