#!/usr/bin/env bash
#
# Copyright 2018-present Open Networking Foundation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# update_xos_docker.sh
# Updates docker FROM lines of synchronizers and xos core, when XOS is updated,
# and the synchronizer has the same parent SemVer major version
#
# Before using this, update XOS version in orchestration/xos/VERSION file
#
# After running script, `repo diff` will show the updated files.
#
# To undo changes: `repo forall -c git checkout *Dockerfile*`

set -eu -o pipefail

WORKSPACE=${WORKSPACE:-../../..}

XOS_MAJOR=$(cut -b 1 "${WORKSPACE}/cord/orchestration/xos/VERSION")

XOS_VERSION=$(cat "${WORKSPACE}/cord/orchestration/xos/VERSION")

# Update Synchronizer FROM parent versions
for df in ${WORKSPACE}/cord/orchestration/xos_services/*/Dockerfile.synchronizer \
          ${WORKSPACE}/cord/orchestration/profiles/*/Dockerfile.synchronizer
do
  df_contents=$(cat "$df")

  # shellcheck disable=SC2076
  if [[ "$df_contents" =~ "FROM xosproject/xos-synchronizer-base:${XOS_MAJOR}" ||
        "$df_contents" =~ "FROM xosproject/xos-synchronizer-base:master" ]]
  then
    echo "Updating synchronizer Dockerfile: ${df}"
    sed -i -- "s/^FROM\\(.*\\):.*$/FROM\\1:$XOS_VERSION/" "$df"
  fi
done

# Update XOS parent versions
for df in ${WORKSPACE}/cord/orchestration/xos/containers/*/Dockerfile* \
          ${WORKSPACE}/cord/orchestration/xos-tosca/Dockerfile
do
  echo "Updating core Dockerfile: ${df}"
  sed -i -- "s/^FROM xos\\(.*\\):.*$/FROM xos\\1:$XOS_VERSION/" "$df"
done
