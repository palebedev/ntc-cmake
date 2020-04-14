# Copyright Pavel A. Lebedev 2020
# Distributed under the Boost Software License, Version 1.0.
# (See accompanying file LICENSE.md or copy at http://boost.org/LICENSE_1_0.txt)
# SPDX-License-Identifier: BSL-1.0

include_guard(GLOBAL)

# Without this all standard tests will fail with IPO enabled, as
# IPO flags won't be added to linking step.
if(IPO_SUPPORTED)
    list(APPEND CMAKE_REQUIRED_FLAGS ${CMAKE_CXX_COMPILE_OPTIONS_IPO} ${CMAKE_CXX14_STANDARD_COMPILE_OPTION})
endif()

# Generate identifer for ${FLAG} and store it into variable named ${OUTPUT}.
function(ntc_gen_have_var_name FLAG OUTPUT)
    string(REGEX REPLACE "^SHELL:" "" result "${FLAG}")
    string(REGEX REPLACE "=.*$" "" result "${result}")
    string(MAKE_C_IDENTIFIER "${result}" result)
    string(REGEX REPLACE "__+" "_" result "${result}")
    string(TOUPPER "${result}" result)
    set(${OUTPUT} "HAVE${result}" PARENT_SCOPE)
endfunction()

include(CheckCXXCompilerFlag)

# Check if an empty project compiles with c++ compiler flag ${FLAG}.
# Generates a name for the result of the check and stores
# it into variable named ${OUTPUT_NAME}, if provided.
function(ntc_check_cxx_compiler_flag FLAG) # OUTPUT_NAME
    ntc_gen_have_var_name("${FLAG}" var_name)
    set(flag_parsed "${FLAG}")
    if(flag_parsed MATCHES "^SHELL:")
        string(SUBSTRING "${flag_parsed}" 6 -1 flag_parsed)
        separate_arguments(flag_parsed UNIX_COMMAND "${flag_parsed}")
    endif()
    check_cxx_compiler_flag("${flag_parsed}" ${var_name})
    if(ARGV1)
        set(${ARGV1} "${var_name}" PARENT_SCOPE)
    endif()
    set(${var_name} ${${var_name}} PARENT_SCOPE)
endfunction()

# Check if an empty project compiles with linker flag ${FLAG}.
# Generates a name for the result of the check and stores
# it into variable named ${OUTPUT_NAME}, if provided.
function(ntc_check_linker_flag FLAG) # OUTPUT_NAME
    ntc_gen_have_var_name("${FLAG}" var_name)
    list(APPEND CMAKE_REQUIRED_LINK_OPTIONS "${FLAG}")
    check_cxx_source_compiles("int main() {}" ${var_name})
    if(ARGV1)
        set(${ARGV1} "${var_name}" PARENT_SCOPE)
    endif()
    set(${var_name} ${${var_name}} PARENT_SCOPE)
endfunction()
