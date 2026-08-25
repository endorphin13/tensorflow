#!/usr/bin/env bash
#
# Copyright 2024 The TensorFlow Authors. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ==============================================================================
#
# Sets up custom apt sources for our TF images.

set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

# 1. Install prerequisites
apt-get update
apt-get install -y --no-install-recommends ca-certificates curl gnupg software-properties-common
add-apt-repository -y universe

# 2. Prepare dedicated keyrings directory
install -m 0755 -d /etc/apt/keyrings

# 3. Fetch GPG keys over HTTPS
curl -fsSL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0xF23C5A6CF475977595C89F51BA6932366A755776" \
  | gpg --dearmor -o /etc/apt/keyrings/deadsnakes.gpg

curl -fsSL "https://apt.llvm.org/llvm-snapshot.gpg.key" \
  | gpg --dearmor -o /etc/apt/keyrings/llvm.gpg

# 4. Configure custom repositories with scoped 'signed-by' keys
cat >/etc/apt/sources.list.d/custom.list <<SOURCES
# Deadsnakes (Python 3.10 - 3.14)
deb [signed-by=/etc/apt/keyrings/deadsnakes.gpg] https://ppa.launchpadcontent.net/deadsnakes/ppa/ubuntu jammy main
deb-src [signed-by=/etc/apt/keyrings/deadsnakes.gpg] https://ppa.launchpadcontent.net/deadsnakes/ppa/ubuntu jammy main

# LLVM/Clang
deb [signed-by=/etc/apt/keyrings/llvm.gpg] http://apt.llvm.org/jammy/ llvm-toolchain-jammy-18 main
deb-src [signed-by=/etc/apt/keyrings/llvm.gpg] http://apt.llvm.org/jammy/ llvm-toolchain-jammy-18 main
SOURCES

# 5. Refresh package cache
apt-get update
