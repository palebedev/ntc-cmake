# Copyright Pavel A. Lebedev 2020
# Distributed under the Boost Software License, Version 1.0.
# (See accompanying file LICENSE.md or copy at http://boost.org/LICENSE_1_0.txt)
# SPDX-License-Identifier: BSL-1.0

# We use UNITY_BUILD.
cmake_minimum_required(VERSION 3.16)

project(ntc-cmake
        DESCRIPTION "NTC CMake helpers package"
        VERSION 0.0.0
        LANGUAGES CXX # Needed to determine CMAKE_INSTALL_LIBDIR
)

if("${CMAKE_SOURCE_DIR}" STREQUAL "${CMAKE_CURRENT_SOURCE_DIR}")
    # We're building ourselves, create version file and install everyting.

    include(CMakePackageConfigHelpers)
    write_basic_package_version_file(${PROJECT_NAME}-config-version.cmake
        VERSION ${PROJECT_VERSION}
        COMPATIBILITY SameMajorVersion
    )
    
    include(GNUInstallDirs)

    install(FILES
        ntc-checks.cmake
        ntc-dev-build.cmake
        ntc-target-helpers.cmake
        ${PROJECT_NAME}-config.cmake
        "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}-config-version.cmake"
        DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}"
    )
else()
    message(FATAL_ERROR
"To use ntc-cmake in bundled configuration, add its directory to module
search path like
list(APPEND CMAKE_MODULE_PATH ntc-cmake)
"
    )
endif()
