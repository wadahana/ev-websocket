#!/bin/bash

source env.sh
source utils.sh

OPENSSL_GIT_URL="git@github.com:openssl/openssl.git"
OPENSSL_BRANCH="OpenSSL_1_1_0-stable"

BORINGSSL_GIT_URL=""
BORINGSSL_BRANCH=""

function fetch_openssl() {
	pushd $THIRD_PARTY_DIR
	git clone -b "$OPENSSL_BRANCH" "$OPENSSL_GIT_URL" "$OPENSSL_DIR"
	popd
}

function fetch_boringssl() {
	pushd $THIRD_PARTY_DIR
	git clone -b "$BORINGSSL_BRANCH" "$BORINGSSL_GIT_URL" "$BORINGSSL_DIR"
	popd
}