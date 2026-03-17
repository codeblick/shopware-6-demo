#!/usr/bin/env bash
set -euo pipefail

PHP_VERSION_MAP_URL="https://raw.githubusercontent.com/FriendsOfShopware/shopware-static-data/refs/heads/main/data/php-version.json"

resolve_php_version() {
    local tag="$1"
    local normalized_tag="${tag#v}"

    # Prefer authoritative Shopware -> PHP mapping; keep a small fallback for very new tags.
    local php_version
    php_version=$(jq -r --arg version "$normalized_tag" '.[$version] // empty' /tmp/php-version-map.json)

    if [[ -z "$php_version" ]]; then
        if [[ $tag == v6.4.* ]]; then
            php_version="8.0"
        elif [[ $tag == v6.5.* ]]; then
            php_version="8.1"
        else
            php_version="8.2"
        fi
    fi

    echo "$php_version"
}

build() {
    echo "Building Shopware $1"

    PHP_VERSION=$(resolve_php_version "$1")

    docker build -q -t codeblick/shopware-6-demo:$1 --build-arg PHP_VERSION=$PHP_VERSION --build-arg SW_VERSION=$1 .
    docker push codeblick/shopware-6-demo:$1
}

curl -fsSL "$PHP_VERSION_MAP_URL" -o /tmp/php-version-map.json
TAGS=$(git ls-remote --tags --refs https://github.com/shopware/shopware.git \
    | awk '{print $2}' \
    | sed 's#refs/tags/##' \
    | sort -V \
    | tail -n 4)

for TAG in $TAGS
do
    build $TAG
done

docker tag codeblick/shopware-6-demo:$TAG codeblick/shopware-6-demo
docker push codeblick/shopware-6-demo