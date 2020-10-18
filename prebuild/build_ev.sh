#!/bin/bash

source env.sh
source utils.sh

function build_ios() {
    BUILD_DIR=${CURRENT_DIR}/build/libevent
    OUTPUT_DIR=${PROJECT_DIR}/output/iOS
    ARCHS=$1
    for ARCH in ${ARCHS}
    do
        if [ ${ARCH} == "x86_64" ] || [ ${ARCH} == "i386" ] ; then
            PLATFORM="iPhoneSimulator"
            EXTRA_CFLAGS=""
        else
            PLATFORM="iPhoneOS"
            EXTRA_CFLAGS="-fembed-bitcode"
        fi
        BUILD_PATH=${BUILD_DIR}/${PLATFORM}.${ARCH}.build
        TARGET_PATH=${BUILD_DIR}/${PLATFORM}.${ARCH}.target

        rm -rf ${BUILD_PATH}
        rm -rf ${TARGET_PATH}
        mkdir -p ${BUILD_PATH}
        mkdir -p ${TARGET_PATH}
        pushd ${BUILD_PATH}

        cmake ${LIBEVENT_DIR} \
            -DCMAKE_OSX_SYSROOT=`tolower ${PLATFORM}` \
            -DCMAKE_OSX_ARCHITECTURES=${ARCH} \
            -DCMAKE_INSTALL_PREFIX=${TARGET_PATH} \
            -DCMAKE_C_FLAGS=${EXTRA_CFLAGS} \
            -DEVENT__LIBRARY_TYPE=static \
            -DEVENT__DISABLE_OPENSSL=ON \
            -DEVENT__DISABLE_TEST=ON \
            -DEVENT__DISABLE_BENCHMARK=ON \
            -DEVENT__DISABLE_SAMPLES=ON \
            -DEVENT__DISABLE_DEBUG_MODE=ON
        make VERBOSE=1
        make install

        EVENT_LIBS+="${TARGET_PATH}/lib/libevent.a "
        CORE_LIBS+="${TARGET_PATH}/lib/libevent_core.a "
        EXTRA_LIBS+="${TARGET_PATH}/lib/libevent_extra.a "
        PTHREAD_LIBS+="${TARGET_PATH}/lib/libevent_pthreads.a "
        SSL_LIBS+="${TARGET_PATH}/lib/libevent_ssl.a "
    done

    mkdir -p ${OUTPUT_DIR}/lib
    mkdir -p ${OUTPUT_DIR}/include

    lipo -create -output ${OUTPUT_DIR}/lib/libevent.a          ${EVENT_LIBS}
    lipo -create -output ${OUTPUT_DIR}/lib/libevent_core.a     ${CORE_LIBS}
    lipo -create -output ${OUTPUT_DIR}/lib/libevent_extra.a    ${EXTRA_LIBS}
    lipo -create -output ${OUTPUT_DIR}/lib/libevent_pthreads.a ${PTHREAD_LIBS}
    cp -R ${BUILD_DIR}/iPhoneOS.arm64.target/include/* ${OUTPUT_DIR}/include/
}



if [ $# != 1 ] ; then
    echo "./build_ev.sh [ios|android|host]"
elif [ $1 == "android" ] ; then
    echo "build libevent for android."
elif [ $1 == "ios" ] ; then
    echo "build libevent for ios."
    build_ios "arm64 armv7 x86_64"
elif [ $1 == "host" ] ; then
    ARCH=`uname -m`
    PLATFORM=`uname -s`
    echo "build libevent for ${PLATFORM}.${ARCH}"
fi
