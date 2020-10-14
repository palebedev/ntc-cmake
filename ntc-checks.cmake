# Copyright Pavel A. Lebedev 2020
# Distributed under the Boost Software License, Version 1.0.
# (See accompanying file LICENSE.md or copy at http://boost.org/LICENSE_1_0.txt)
# SPDX-License-Identifier: BSL-1.0

include_guard(GLOBAL)

if(IPO_SUPPORTED)
    # Add IPO flags if it's enabled to ensure we fail checks for flags
    # that are incompatible with IPO.
    list(APPEND CMAKE_REQUIRED_FLAGS ${CMAKE_CXX_COMPILE_OPTIONS_IPO})
endif()

# ntc_gen_have_var_name(<flag> <output> [STRIP_VALUE])
# Generate identifer for <flag> and store it into variable named <output> in
# caller's scope. If STRIP_VALUE is specified remove equals sign and text after it.
function(ntc_gen_have_var_name FLAG OUTPUT)
    cmake_parse_arguments(PARSE_ARGV 2 args "STRIP_VALUE" "" "")
    if(args_UNPARSED_ARGUMENTS OR args_KEYWORDS_MISSING_VALUES)
        message(SEND_ERROR "Invalid arguments to ntc_gen_have_var_name")
    endif()
    string(REGEX REPLACE "^SHELL:" "" result "${FLAG}")
    if(args_STRIP_VALUE)
        string(REGEX REPLACE "=.*$" "" result "${result}")
    endif()
    string(MAKE_C_IDENTIFIER "${result}" result)
    string(REGEX REPLACE "__+" "_" result "${result}")
    string(TOUPPER "${result}" result)
    set(${OUTPUT} "HAVE${result}" PARENT_SCOPE)
endfunction()

function(_ntc_check_flag_args_common FLAG)
    cmake_parse_arguments(PARSE_ARGV 1 args "STRIP_VALUE" "OUTPUT_NAME" "")
    if(args_UNPARSED_ARGUMENTS OR args_KEYWORDS_MISSING_VALUES)
        message(SEND_ERROR "Invalid arguments to ntc_check_*_flag")
    endif()
    if(args_STRIP_VALUE)
        set(gen_have_var_name_args STRIP_VALUE)
    endif()
    ntc_gen_have_var_name("${FLAG}" var_name ${gen_have_var_name_args})
    set(var_name "${var_name}" PARENT_SCOPE)
    set(output_name "${args_OUTPUT_NAME}" PARENT_SCOPE)
    set(flag_parsed "${FLAG}")
    if(flag_parsed MATCHES "^SHELL:")
        string(SUBSTRING "${flag_parsed}" 6 -1 flag_parsed)
        separate_arguments(flag_parsed UNIX_COMMAND "${flag_parsed}")
    endif()
    set(flag_parsed "${flag_parsed}" PARENT_SCOPE)
endfunction()

include(CheckCXXCompilerFlag)

# ntc_check_cxx_compiler_flag(<flag> [STRIP_VALUE] [OUTPUT_NAME <output_name>])
# Check if an empty project compiles with c++ compiler flag <flag>.
# Generates a name for the result of the check and stores
# it into variable named <output_name> in caller's scope if provided.
# If STRIP_VALUE is specified, remove equals sign and text after it from
# generated variable name.
function(ntc_check_cxx_compiler_flag FLAG)
    _ntc_check_flag_args_common("${FLAG}" ${ARGN})
    check_cxx_compiler_flag("${flag_parsed}" ${var_name})
    if(output_name)
        set(${output_name} "${var_name}" PARENT_SCOPE)
    endif()
    set(${var_name} ${${var_name}} PARENT_SCOPE)
endfunction()

# ntc_check_linker_flag(<flag> [STRIP_VALUE] [OUTPUT_NAME <output_name>])
# Check if an empty project compiles with linker flag <flag>.
# Generates a name for the result of the check and stores
# it into variable named <output_name> in caller's scope if provided.
# If STRIP_VALUE is specified, remove equals sign and text after it from
# generated variable name.
function(ntc_check_linker_flag FLAG)
    _ntc_check_flag_args_common("${FLAG}" ${ARGN})
    list(APPEND CMAKE_REQUIRED_LINK_OPTIONS "${flag_parsed}")
    check_cxx_source_compiles("int main() {}" ${var_name})
    if(output_name)
        set(${output_name} "${var_name}" PARENT_SCOPE)
    endif()
    set(${var_name} ${${var_name}} PARENT_SCOPE)
endfunction()
