#!/bin/bash
#
# Copyright (c) 2018 Intel Corporation
#
# SPDX-License-Identifier: Apache-2.0
#
# -*- mode: shell-script; indent-tabs-mode: nil; sh-basic-offset: 4; -*-
# ex: ts=8 sw=4 sts=4 et filetype=sh

# Automation script to create specs to build kata containers kernel
[ -z "${DEBUG}" ] || set -o xtrace

set -o errexit
set -o nounset
set -o pipefail

source ../versions.txt
source ../scripts/pkglib.sh

SCRIPT_NAME=$0
SCRIPT_DIR=$(dirname $0)
PKG_NAME="qemu-lite"
VERSION=$qemu_lite_version

GENERATED_FILES=(qemu-lite.dsc qemu-lite.spec debian.rules _service debian.control)
STATIC_FILES=(debian.compat "${SCRIPT_DIR}/../../scripts/configure-hypervisor.sh" qemu-lite-rpmlintrc)

# Parse arguments
cli "$@"

[ "$VERBOSE" == "true" ] && set -x
PROJECT_REPO=${PROJECT_REPO:-home:${OBS_PROJECT}:${OBS_SUBPROJECT}/qemu-lite}
RELEASE=$(get_obs_pkg_release "${PROJECT_REPO}")
((RELEASE++))

set_versions "${qemu_lite_hash}"

replace_list=(
	"VERSION=$VERSION"
	"RELEASE=$RELEASE"
	"QEMU_LITE_HASH=${qemu_lite_hash:0:${short_commit_length}}"
)
verify
echo "Verify succeed."
get_git_info
changelog_update $VERSION
generate_files "$SCRIPT_DIR" "${replace_list[@]}"
build_pkg "${PROJECT_REPO}"
