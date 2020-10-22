# Copyright Pavel A. Lebedev 2020
# Distributed under the Boost Software License, Version 1.0.
# (See accompanying file LICENSE.md or copy at http://boost.org/LICENSE_1_0.txt)
# SPDX-License-Identifier: BSL-1.0

cmake_minimum_required(VERSION 3.19)

project(ntcexample-headerlib
        VERSION 0.0.0
        DESCRIPTION "ntcexample header-only library"
        LANGUAGES CXX
)

find_package(ntc-cmake REQUIRED)
include(ntc-dev-build)

add_library(${PROJECT_NAME} INTERFACE
    include/ntcexample/headerlib/gadget.hpp
)

target_compile_features(${PROJECT_NAME} INTERFACE cxx_std_20)

ntc_target(${PROJECT_NAME} ALIAS_NAME ntcexample::headerlib)
