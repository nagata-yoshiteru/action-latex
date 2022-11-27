#!/bin/sh

echo Pull the Docker image
docker pull $BUILD_IMAGE

ARG_ENTRYPOINT=""
if [ -n "$BUILD_ENTRYPOINT" ]; then
    ARG_ENTRYPOINT="--entrypoint \"$BUILD_ENTRYPOINT\""
fi

ARG_MOUNT=""
BUILD_DIR="$PWD"
if [ -n "$HOST_WORKSPACE" ]; then
    ARG_MOUNT="-v \"$HOST_WORKSPACE\":/custom/workspace"
    BUILD_DIR="/custom/workspace"
fi

echo "$BUILD_FILES" | xargs -I{TEX_FILE} -P $(nproc) -t sh -c "
    echo $BUILD_DIR/\$(dirname ./{TEX_FILE})
"

echo "$BUILD_FILES" | xargs -I{TEX_FILE} -P $(nproc) -t sh -c "
    ls $BUILD_DIR/\$(dirname ./{TEX_FILE})
"

echo "$BUILD_FILES" | xargs -I{TEX_FILE} -P $(nproc) -t sh -c "
    docker run --rm \\
        -v $BUILD_DIR/\$(dirname ./{TEX_FILE}):/workdir \\
        $ARG_ENTRYPOINT \\
        $ARG_MOUNT \\
        --workdir=\"/workdir\" \\
        $BUILD_IMAGE \\
        $BUILD_ARGS \\
        \$(basename {TEX_FILE})
"
