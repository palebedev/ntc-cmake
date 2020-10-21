# Copyright Pavel A. Lebedev 2020
# Distributed under the Boost Software License, Version 1.0.
# (See accompanying file LICENSE.md or copy at http://boost.org/LICENSE_1_0.txt)
# SPDX-License-Identifier: BSL-1.0

option(NTC_DEV_BUILD "Apply developer settings and optimizations" ON)

if(NTC_DEV_BUILD)
    if(CMAKE_BUILD_TYPE STREQUAL Debug)
        set(_default_shared_libs ON)
    else()
        set(_default_shared_libs OFF)
    endif()
    option(BUILD_SHARED_LIBS "Build shared libraries" ${_default_shared_libs})

    # We can't use interface target plus target_link_libraries, as for static library
    # builds cmake will insist it's a dependency and must be exported.

    include(CheckIPOSupported)
    check_ipo_supported(RESULT IPO_SUPPORTED)

    include(ntc-checks)

    function(_ntc_try_append_cxx_flag FLAG)
        ntc_check_cxx_compiler_flag("${FLAG}" OUTPUT_NAME var_name ${ARGN})
        if(${var_name})
            list(APPEND NTC_COMPILE_OPTIONS "${FLAG}")
            set(NTC_COMPILE_OPTIONS "${NTC_COMPILE_OPTIONS}" PARENT_SCOPE)
        endif()
    endfunction()

    function(_ntc_try_append_linker_flag FLAG)
        ntc_check_linker_flag("${FLAG}" OUTPUT_NAME var_name ${ARGN})
        if(${var_name})
            list(APPEND NTC_LINK_OPTIONS "${FLAG}")
            set(NTC_LINK_OPTIONS "${NTC_LINK_OPTIONS}" PARENT_SCOPE)
        endif()
    endfunction()

    # Language features
    _ntc_try_append_cxx_flag(-pedantic-errors)

    # Math optimizations
    _ntc_try_append_cxx_flag(-fno-math-errno)
    _ntc_try_append_cxx_flag(-fno-signed-zeros)
    _ntc_try_append_cxx_flag(-fno-trapping-math)

    # Diagnostics
    _ntc_try_append_cxx_flag(-Wall)
    _ntc_try_append_cxx_flag(-Wextra)
    _ntc_try_append_cxx_flag(-Wabstract-vbase-init)
    _ntc_try_append_cxx_flag(-Warray-bounds-pointer-arithmetic)
    _ntc_try_append_cxx_flag(-Wcast-align)
    _ntc_try_append_cxx_flag(-Wclass-varargs)
    _ntc_try_append_cxx_flag(-Wconversion)
    _ntc_try_append_cxx_flag(-Wctor-dtor-privacy)
    _ntc_try_append_cxx_flag(-Wdeprecated)
    _ntc_try_append_cxx_flag(-Wdocumentation)
    _ntc_try_append_cxx_flag(-Wdocumentation-pedantic)
    _ntc_try_append_cxx_flag(-Wdouble-promotion)
    _ntc_try_append_cxx_flag(-Wduplicated-branches)
    _ntc_try_append_cxx_flag(-Wduplicated-cond)
    _ntc_try_append_cxx_flag(-Wextra-semi)
    _ntc_try_append_cxx_flag(-Wheader-hygiene)
    _ntc_try_append_cxx_flag(-Wimplicit-fallthrough)
    _ntc_try_append_cxx_flag(-Winconsistent-missing-destructor-override)
    _ntc_try_append_cxx_flag(-Wlogical-op)
    _ntc_try_append_cxx_flag(-Wmissing-declarations)
    _ntc_try_append_cxx_flag(-Wmissing-prototypes)
    _ntc_try_append_cxx_flag(-Wmissing-variable-declarations)
    _ntc_try_append_cxx_flag(-Wnewline-eof)
    _ntc_try_append_cxx_flag(-Wno-assume)
    _ntc_try_append_cxx_flag(-Wno-missing-field-initializers)
    _ntc_try_append_cxx_flag(-Wnull-dereference)
    _ntc_try_append_cxx_flag(-Wnullable-to-nonnull-conversion)
    _ntc_try_append_cxx_flag(-Wold-style-cast)
    _ntc_try_append_cxx_flag(-Wover-aligned)
    _ntc_try_append_cxx_flag(-Wpragmas)
    _ntc_try_append_cxx_flag(-Wrange-loop-analysis)
    _ntc_try_append_cxx_flag(-Wredundant-decls)
    _ntc_try_append_cxx_flag(-Wredundant-parens)
    _ntc_try_append_cxx_flag(-Wreserved-id-macro)
    _ntc_try_append_cxx_flag(-Wshadow-field)
    _ntc_try_append_cxx_flag(-Wshadow-field-in-constructor-modified)
    _ntc_try_append_cxx_flag(-Wshift-sign-overflow)
    _ntc_try_append_cxx_flag(-Wstatic-in-inline)
    _ntc_try_append_cxx_flag(-Wthread-safety)
    _ntc_try_append_cxx_flag(-Wundef)
    _ntc_try_append_cxx_flag(-Wundefined-func-template)
    _ntc_try_append_cxx_flag(-Wundefined-reinterpret-cast)
    _ntc_try_append_cxx_flag(-Wweak-vtables)
    _ntc_try_append_cxx_flag(-Wweak-template-vtables)
    _ntc_try_append_cxx_flag(-Wzero-as-null-pointer-constant)
    _ntc_try_append_cxx_flag(-fmacro-backtrace-limit=0)
    _ntc_try_append_cxx_flag(-ftemplate-backtrace-limit=0)
    _ntc_try_append_cxx_flag(-fdiagnostics-show-template-tree)

    # Optimizations
    _ntc_try_append_linker_flag(-Wl,--as-needed)
    if(CMAKE_BUILD_TYPE MATCHES "Release|MinSizeRel|RelWithDebInfo")
        _ntc_try_append_cxx_flag(-fno-enforce-eh-specs)
        _ntc_try_append_cxx_flag("SHELL:-Xclang -fexternc-nounwind")
        _ntc_try_append_cxx_flag(-fipa-pta)
        _ntc_try_append_cxx_flag(-fdevirtualize-at-ltrans)
        _ntc_try_append_cxx_flag(-fstrict-vtable-pointers)
        if(IPO_SUPPORTED)
            # Only works with -flto.
            # Currently broken, lld claims -fsplit-lto-unit was not specified,
            # but even manual specification doesn't help.
            # _ntc_try_append_cxx_flag(-fwhole-program-vtables)
        endif()
        _ntc_try_append_cxx_flag(-fforce-emit-vtables)
        _ntc_try_append_cxx_flag(-fno-semantic-interposition)
        _ntc_try_append_linker_flag(-Wl,-O1)
        _ntc_try_append_linker_flag(-Wl,--sort-common)
        _ntc_try_append_linker_flag(-Wl,--relax)
        _ntc_try_append_linker_flag(-Wl,-z,relro,-z,now)
        if(HAVE_WL_Z_RELRO_Z_NOW)
            _ntc_try_append_cxx_flag(-fno-plt)
        endif()
        _ntc_try_append_linker_flag(-Wl,--icf=safe)
        set(NTC_BOOST_DEFINITIONS
            BOOST_ASIO_NO_TS_EXECUTORS BOOST_DISABLE_ASSERTS
            BOOST_EXCEPTION_DISABLE BOOST_HANA_CONFIG_DISABLE_CONCEPT_CHECKS)
        string(REPLACE "=thin" "" CMAKE_C_COMPILE_OPTIONS_IPO "${CMAKE_C_COMPILE_OPTIONS_IPO}")
        string(REPLACE "=thin" "" CMAKE_CXX_COMPILE_OPTIONS_IPO "${CMAKE_CXX_COMPILE_OPTIONS_IPO}")
    elseif(CMAKE_BUILD_TYPE STREQUAL Debug)
        _ntc_try_append_cxx_flag(-ftrivial-auto-var-init=pattern)
        include(CheckIncludeFileCXX)
        check_include_file_cxx(valgrind/valgrind.h HAVE_VALGRIND_H)
        if(HAVE_VALGRIND_H)
            set(NTC_BOOST_DEFINITIONS BOOST_USE_VALGRIND)
        endif()
    endif()
    if(CMAKE_C_COMPILE_OPTIONS_IPO MATCHES thin OR CMAKE_CXX_COMPILE_OPTIONS_IPO MATCHES thin)
        _ntc_try_append_linker_flag("-Wl,--thinlto-cache-dir=${CMAKE_BINARY_DIR}/.thinlto-cache" STRIP_VALUE)
    endif()
    if(CMAKE_BUILD_TYPE MATCHES "Debug|RelWithDebInfo")
        # gdb complains about .debug_names table making debugging impossible.
        # _ntc_try_append_cxx_flag(-gdwarf-5)
        _ntc_try_append_cxx_flag(-gsplit-dwarf)
        if(HAVE_GSPLIT_DWARF)
            _ntc_try_append_linker_flag(-Wl,--gdb-index)
        endif()
    endif()

    list(APPEND NTC_BOOST_DEFINITIONS BOOST_ASIO_NO_DEPRECATED)
    if(BUILD_SHARED_LIBS)
        list(APPEND NTC_BOOST_DEFINITIONS BOOST_ALL_DYN_LINK BOOST_ALL_NO_LIB)
        # clang + LTO + -Bsymbolic-functions breaks Qt Signals, too dangerous.
        #_ntc_try_append_linker_flag(-Wl,-Bsymbolic-functions)
    else()
        if(NOT DEFINED Boost_USE_STATIC_LIBS)
            set(Boost_USE_STATIC_LIBS ON)
        endif()
    endif()

    set(NTC_QT_DEFINITIONS QT_DISABLE_DEPRECATED_BEFORE=0x060000
                           QT_NO_CAST_FROM_ASCII QT_NO_CAST_FROM_BYTEARRAY QT_NO_CAST_TO_ASCII
                           QT_NO_URL_CAST_FROM_STRING QT_NO_NARROWING_CONVERSIONS_IN_CONNECT
                           QT_NO_PROCESS_COMBINED_ARGUMENT_START
                           QT_STRICT_ITERATORS QT_NO_JAVA_STYLE_ITERATORS
                           QT_NO_LINKED_LIST
                           QT_USE_QSTRINGBUILDER)

    unset(_var_name)
endif()

# Most of this functionality is used by ntc-target-helpers.
include(ntc-target-helpers)
