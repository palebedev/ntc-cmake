# Copyright Pavel A. Lebedev 2020
# Distributed under the Boost Software License, Version 1.0.
# (See accompanying file LICENSE.md or copy at http://boost.org/LICENSE_1_0.txt)
# SPDX-License-Identifier: BSL-1.0

cmake_minimum_required(VERSION 3.16)

set(NAMESPACE ntcexample)
set(COMPONENT exe)
project(${NAMESPACE}-${COMPONENT}
        VERSION 0.0.0
        DESCRIPTION "ntcexample executable"
        LANGUAGES CXX
)

find_package(ntc-cmake REQUIRED)
include(ntc-dev-build)

add_executable(${PROJECT_NAME}
    src/main.cpp
)

find_package(ntcexample-lib)

target_link_libraries(${PROJECT_NAME} PRIVATE ntcexample::lib)

ntc_target(${PROJECT_NAME})
