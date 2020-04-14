# Copyright Pavel A. Lebedev 2020
# Distributed under the Boost Software License, Version 1.0.
# (See accompanying file LICENSE.md or copy at http://boost.org/LICENSE_1_0.txt)
# SPDX-License-Identifier: BSL-1.0

cmake_minimum_required(VERSION 3.16)

project(ntcexample
        DESCRIPTION "example of using ntc-cmake"
        VERSION 0.0.0
        LANGUAGES CXX
)

# Include ntc-cmake as bundled if present (could be a git submodule
# that is not checked out), look for system one otherwise.
if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/ntc-cmake/CMakeLists.txt")
    list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/ntc-cmake")
else()
    find_package(ntc-cmake REQUIRED)
endif()

# Include ntc-dev-build to disable find_package(ntc-cmake)
# in subprojects and establish default for BUILD_SHARED_LIBS.
include(ntc-dev-build)

add_subdirectory(ntcexample-lib)
add_subdirectory(ntcexample-exe)

include(FeatureSummary)
feature_summary(WHAT ALL)