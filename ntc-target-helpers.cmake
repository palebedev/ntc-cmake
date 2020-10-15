# Copyright Pavel A. Lebedev 2020
# Distributed under the Boost Software License, Version 1.0.
# (See accompanying file LICENSE.md or copy at http://boost.org/LICENSE_1_0.txt)
# SPDX-License-Identifier: BSL-1.0

include_guard(GLOBAL)

# Common target configuration.

# Used to provide subpath customization and handle lib32/lib64, etc.
include(GNUInstallDirs)

# ntc_target(<target_name> [INCLUDE_INFIX <include_infix>] [PRIVATE_CONFIG])
# Helper function to setup common target configuration for target <target_name>.
# If <include_infix> is specified, it is inserted between
# include/${NAMESPACE}/ and config/export header names. That is, to put
# headers in subdirectory subdir, specify "subdir/" as include infix.
# PRIVATE_CONFIG prevents installation of config header for libraries.
function(ntc_target TARGET_NAME)
    cmake_parse_arguments(PARSE_ARGV 1 args "" "INCLUDE_INFIX" "")
    if(args_UNPARSED_ARGUMENTS OR args_KEYWORDS_MISSING_VALUES)
        message(SEND_ERROR "Invalid arguments to ntc_target")
    endif()

    if(COMPONENT)
        set(alias_name "${NAMESPACE}::${COMPONENT}")
    else()
        set(alias_name "${NAMESPACE}::${NAMESPACE}")
    endif()

    get_target_property(project_type ${TARGET_NAME} TYPE)

    if(project_type STREQUAL OBJECT_LIBRARY)
        message(FATAL_ERROR "ntc_setup doesn't support object libraries")
    elseif(project_type STREQUAL EXECUTABLE)
        set(include_type PRIVATE)

        add_executable(${alias_name} ALIAS ${TARGET_NAME})

        install(TARGETS ${TARGET_NAME}
                COMPONENT ${alias_name}
        )
    else() # {STATIC,MODULE,SHARED,INTERFACE}_LIBRARY
        set(include_type PUBLIC)

        add_library(${alias_name} ALIAS ${TARGET_NAME})

        set_target_properties(${TARGET_NAME} PROPERTIES
            # Current library version is same as this project ("max API supported").
            VERSION "${PROJECT_VERSION}"
        )

        if(NOT project_type STREQUAL INTERFACE_LIBRARY)
            # Support proper visibility/dllexport handling for shared library builds.
            include(GenerateExportHeader)
            generate_export_header(${TARGET_NAME}
                EXPORT_FILE_NAME include/${NAMESPACE}/${args_INCLUDE_INFIX}export.h)
            target_sources(${TARGET_NAME} PRIVATE
                ${CMAKE_CURRENT_BINARY_DIR}/include/${NAMESPACE}/${args_INCLUDE_INFIX}export.h)
            install(FILES ${CMAKE_CURRENT_BINARY_DIR}/include/${NAMESPACE}/${args_INCLUDE_INFIX}export.h
                    DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/${NAMESPACE}/${args_INCLUDE_INFIX}"
                    COMPONENT ${alias_name}
            )

            # Use visibility in standard builds.
            if(NTC_DEV_BUILD)
                if(NOT project_type STREQUAL STATIC_LIBRARY)
                    set_target_properties(${TARGET_NAME} PROPERTIES
                        CXX_VISIBILITY_PRESET hidden
                        VISIBILITY_INLINES_HIDDEN ON
                    )
                endif()
            endif()
        endif()

        # Install library.
        install(TARGETS ${TARGET_NAME}
                EXPORT ${TARGET_NAME}-targets
                # This provides include directory in exported target
                # relative to prefix in single directory we've put everything in.
                INCLUDES DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
                COMPONENT ${alias_name}
        )

        # Install headers from source tree.
        install(DIRECTORY include/${NAMESPACE}
                TYPE INCLUDE
                COMPONENT ${alias_name}
        )
    endif()

    if(NTC_DEV_BUILD)
        # Activate flags found by ntc_standard_build, if any.
        foreach(var COMPILE_OPTIONS LINK_OPTIONS)
            set_property(TARGET ${TARGET_NAME} APPEND PROPERTY ${var} "${NTC_${var}}")
        endforeach()

        # Add Boost/Qt-specific definitions, if needed.
        function(_ntc_auto_add_definitions)
            foreach(target_var LINK_LIBRARIES INTERFACE_LINK_LIBRARIES)
                get_target_property(libs ${TARGET_NAME} ${target_var})
                if(target_var STREQUAL LINK_LIBRARIES)
                    set(scope PRIVATE)
                else()
                    set(scope INTERFACE)
                endif()
                math(EXPR end ${ARGC}-1)
                foreach(i RANGE 0 ${end} 2)
                    foreach(lib IN LISTS libs)
                        if(lib MATCHES "^${ARGV${i}}::")
                            math(EXPR j ${i}+1)
                            separate_arguments(defs WINDOWS_COMMAND "${ARGV${j}}")
                            target_compile_definitions(${TARGET_NAME} ${scope} ${defs})
                            break()
                        endif()
                    endforeach()
                endforeach()
            endforeach()
        endfunction()

        # Extra quotes as otherwise they get separated into multiple args.
        _ntc_auto_add_definitions(
            Boost "\"${NTC_BOOST_DEFINITIONS}\""
            Qt5 "\"${NTC_QT_DEFINITIONS}\""
        )
    endif()

    # Look for configuration file in source directory.
    if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/src/config.hpp.in")
        # If there is one, process and install it.
        target_sources(${TARGET_NAME} PRIVATE src/config.hpp.in)
        set(config_output "${NAMESPACE}/${args_INCLUDE_INFIX}config.hpp")
        configure_file(src/config.hpp.in "include/${config_output}" ESCAPE_QUOTES)
        if(NOT project_type STREQUAL EXECUTABLE AND NOT args_PRIVATE_CONFIG)
            install(FILES "${CMAKE_CURRENT_BINARY_DIR}/include/${config_output}"
                    DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/${NAMESPACE}/${args_INCLUDE_INFIX}"
                    COMPONENT ${alias_name}
            )
        endif()
    else()
        if(args_PRIVATE_CONFIG)
            message(SEND_ERROR "PRIVATE_CONFIG was specified, but no config file template found")
        endif()
    endif()

    # If there are include directories below current source/build trees, use them.
    foreach(incdir "${CMAKE_CURRENT_SOURCE_DIR}/include" "${CMAKE_CURRENT_BINARY_DIR}/include")
        if(EXISTS "${incdir}")
            # These directories are used only during build, common include directory
            # where everthing gets installed is specified in install(TARGETS ... INCLUDES DESTINATION)
            target_include_directories(${TARGET_NAME} ${include_type} "$<BUILD_INTERFACE:${incdir}>")
        endif()
    endforeach()

    # Set our output properties.
    set_target_properties(${TARGET_NAME} PROPERTIES
        # We don't want any language extensions.
        CXX_EXTENSIONS OFF
        # We can't rely on NAMESPACE option to export/install(EXPORT),
        # because then we will have to use COMPONENT as logical name,
        # which will have to be nontrivial to not clash with other projects
        # in same tree and duplicate parts of namespace name.
        # Set proper EXPORT_NAME manually.
        EXPORT_NAME "${alias_name}"
    )

    if(NTC_DEV_BUILD)
        # Enable IPO in standard builds, if supported.
        if(IPO_SUPPORTED)
            set_target_properties(${TARGET_NAME} PROPERTIES
                INTERPROCEDURAL_OPTIMIZATION ON
            )
        endif()
        if(CMAKE_BUILD_TYPE MATCHES "Release|MinSizeRel|RelWithDebInfo")
            set_target_properties(${TARGET_NAME} PROPERTIES
                UNITY_BUILD ON
            )
        endif()
    endif()

    # Export targets if there is a package file.
    if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${TARGET_NAME}-config.cmake.in)
        include(CMakePackageConfigHelpers)

        # Configure the main package file from source tree.
        configure_package_config_file(${TARGET_NAME}-config.cmake.in
            "${CMAKE_CURRENT_BINARY_DIR}/${TARGET_NAME}-config.cmake"
            INSTALL_DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/${NAMESPACE}"
        )

        # Write package version file.
        write_basic_package_version_file(${TARGET_NAME}-config-version.cmake
            VERSION ${PROJECT_VERSION}
            COMPATIBILITY SameMajorVersion
        )

        # Install the generated package version file and the main package file.
        install(FILES
            "${CMAKE_CURRENT_BINARY_DIR}/${TARGET_NAME}-config.cmake"
            "${CMAKE_CURRENT_BINARY_DIR}/${TARGET_NAME}-config-version.cmake"
            DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/${NAMESPACE}"
            COMPONENT ${alias_name}
        )

        # This installs package in install tree for using installed targets.
        install(EXPORT ${TARGET_NAME}-targets
                FILE ${TARGET_NAME}-targets.cmake
                DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/${NAMESPACE}"
                COMPONENT ${alias_name}
        )
    endif()

    set_property(GLOBAL APPEND PROPERTY NTC_PROJECTS ${TARGET_NAME})
endfunction()

# Disable find_package for in-tree projects.
# This allows uniform usage of find_package.
if(NOT COMMAND _find_package)
    macro(find_package)
        get_property(_NTC_PROJECTS GLOBAL PROPERTY NTC_PROJECTS)
        if(NOT "${ARGV0}" IN_LIST _NTC_PROJECTS AND NOT "${ARGV0}" STREQUAL ntc-cmake)
            _find_package(${ARGV})
        endif()
        unset(_NTC_PROJECTS)
    endmacro()
endif()
