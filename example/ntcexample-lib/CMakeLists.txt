# Copyright Pavel A. Lebedev 2020
# Distributed under the Boost Software License, Version 1.0.
# (See accompanying file LICENSE.md or copy at http://boost.org/LICENSE_1_0.txt)
# SPDX-License-Identifier: BSL-1.0

cmake_minimum_required(VERSION 3.16)

set(NAMESPACE ntcexample)
set(COMPONENT lib)
project(${NAMESPACE}-${COMPONENT}
        VERSION 0.0.0
        DESCRIPTION "ntcexample library"
        LANGUAGES CXX
)

find_package(ntc-cmake REQUIRED)
include(ntc-dev-build)

add_library(${PROJECT_NAME}
    include/ntcexample/widget.hpp
    src/widget.cpp
)

target_compile_features(${PROJECT_NAME} PUBLIC cxx_std_20)

include(CheckCXXSourceCompiles)

check_cxx_source_compiles("#include <emmintrin.h>
    #include <wmmintrin.h>
    int main(int argc,char* /*argv*/[]) {
        return (int)_mm_cvtsi128_si64(_mm_clmulepi64_si128(
            _mm_cvtsi64_si128(argc),_mm_cvtsi64_si128(argc),0));
    }" HAVE_MM_CLMULEPI64_SI128)
include(FeatureSummary)
add_feature_info(PCLMUL HAVE_MM_CLMULEPI64_SI128
    "hardware support for carryless multiplication")

find_package(Boost REQUIRED)
target_link_libraries(${PROJECT_NAME} PUBLIC Boost::headers)

ntc_target(${PROJECT_NAME})
