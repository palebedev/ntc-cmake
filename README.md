NTC CMake - common cmake tasks helpers
======================================

This package contains a set of CMake modules that automate common tasks. It can be used with CMake 3.16+ either as bundled code by adding to CMake module path or installed as a package to some prefix and loaded with `find_package`. See `examples` subdirectory for sample usage.

The following modules are available:

ntc-target-helpers
------------------

Provides the following command:

```CMake
ntc_target(<target> [ALIAS_NAME <alias_name>]
                    [HEADER_PREFIX <header_prefix>]
                    [PRIVATE_CONFIG]
                    [TRANSLATIONS lang1 [lang2...]]
)
```

`ntc_target` applies the following changes to `${target}`:

- An alias target named `${alias_name}` is created. When `alias_name` is not specified, this defaults to `${target}::${target}`.
- When any of the following steps installs any files, corresponding locations from `GNUInstallDirs` are used, unless specified otherwise.
- Target binary is installed.
- The following steps may generate files in current build directory. Names of these files are prefixed with `include/${header_prefix}`. When `header_prefix` is not specified, this defaults to `include/${target}/`.
- If a file named `src/config.hpp.in` exists in current source directory, it is processed with `configure_file` in `ESCAPE_QUOTES` mode and the result is written to `config.hpp`. Unless the target is an executable or `PRIVATE_CONFIG` is specified, this header is installed. The following variables will be computed to be available in this file:
  - `<ID_TARGET>_REL_DATADIR`, where `ID_TARGET` is the result of applying `MAKE_C_IDENTIFIER` and `TOUPPER` `string` CMake operations to `${target}`, is set to relative path from `${CMAKE_INSTALL_BINDIR}` to `${CMAKE_INSTALL_DATADIR}/${target}` which may be used to find application resources when installed to prefix.
- If the target is a library:
  - Object libraries are not supported and rejected with an error.
  - Everything in `include` subdirectory in current source directory is installed.
  - Binary version is set to the version of current project.
  - For library targets that are not interface libraries, an export header `export.h` is created with `generate_export_header`. This header is then installed.
- `include` subdirectories under current source and binary directories are added to the target include directories, if present. These includes are added as `PUBLIC` for libraries and `PRIVATE` for executables and are effective only during build. When the package is installed, `${CMAKE_INSTALL_INCLUDEDIR` is used instead in config files.
- The following target properties are set:
  - `CXX_EXTENSIONS OFF`: disable C++ standard extensions.
  - `COMPILE_OPTIONS` and `INTERFACE_COMPILE_OPTIONS` are accordingly extended with `-fcoroutines`, if `COMPILE_FEATURES` or `INTERFACE_COMPILE_FEATURES` contain `cxx_std_20`, which is required by GCC to enable C++20 coroutine support.
  - `AUTOMOC ON` if target links directly to any Qt5 component: enable Qt Meta Object Compiler.
  - `AUTOUIC ON` if target sources contain `.ui` files: enable Qt UI Compiler.
  - `AUTORCC ON` if target sources contain `.qrc` files: enable Qt Resource Compiler.
  - `WIN32_EXECUTABLE ON` if target links directly to `Qt5::Widgets`: disable creation of new console for the application when run on Windows.
- If the file `<target>-config.cmake.in` exists in current source directory, it is processed with `configure_package_config_file` from `CMakePackageConfigHelpers` module. A package version file is generated with the current project's version and compatibility mode `SameMajorVersion`. These cmake modules and the corresponding target export module are then installed into subdirectory `${target}` under cmake module path in install prefix directory.
- If `TRANSLATIONS` are specified, it is assumed `find_packahe(Qt5 COMPONENTS LinguistTools)` has been called successfully. For each `lang` specified the translation is expected to be stored under `translations/${target}_{lang}.ts` in source directory. All translations are compiled to `.qm` files in `translations` subdirectory in build directory and installed to `${CMAKE_INSTALL_DATADIR}/${target}/translations`. A target named `${target}-lupdate` is created that calls `lupdate` for these `.ts` files and whole current source directory. A target named just `lupdate` depends on all target-specific lupdate targets. These lupdate targets must be built manually, no other target depends on them.

Inclusion of this module modifies behavior of `find_package` command to ignore requests to find packages with the names of targets processed with `ntc_target` before. As the latter registers alias targets, this allows for uniform usage of `find_package`.

ntc-dev-build
-------------

This module includes `ntc-target-helpers` and modifies functionality of `ntc_target` as follows:

- Adds an option `NTC_DEV_BUILD` with a default of `ON`. Setting it to `OFF` disables any further functionality of this module. This prevents any interference with externally specified build options.
- The default for `BUILD_SHARED_LIBS` option is set to `ON` for `Debug` build type.
- For shared and module library targets, hidden visibility is enabled, including for inlines.
- A number of compiler and linker flags are checked for availability and applied to target. These flags depend on `CMAKE_BUILD_TYPE` and `BUILD_SHARED_LIBS` variables and enable advanced debugging and optimization options. For the full list, see `ntc-dev-build.cmake` file.
- If Boost or Qt libraries are found in direct dependencies of the target, additional preprocessor definitions and module options are enabled. See `ntc-dev-build.cmake` for full list.
- Interprocedural optimizations are enabled, if supported. Full LTO is preferred to thin in release builds.
- Unity builds are enabled for release build types.

ntc-checks
----------

This module provides the following commands:

```CMake
ntc_check_cxx_compiler_flag(<flag> [STRIP_VALUE] [OUTPUT_NAME <output_name>])
```
Check if an empty project compiles with c++ compiler `${flag}`.
Generates a name for the result of the check and stores it into variable `${output_name}` in caller's scope if provided.
If `STRIP_VALUE` is specified, remove equals sign and text after it from the generated variable name.

```CMake
ntc_check_linker_flag(<flag> [STRIP_VALUE] [OUTPUT_NAME <output_name>])
```
As above, but checks if `${flag}` is accepted by linker.

Usage
-----

Root of this repository contains an example project using ntc-cmake.

To use ntc-cmake itself you can either:
- Build ntc-cmake subdirectory and install it. When ntc-cmake is the root of cmake source directory, it installs itself into prefix to be used by other projects by using `find_package(ntc-cmake REQUIRED)`.
- Make ntc-cmake subdirectory a part of your project ("bundled") by copying, using git submodules or otherwise. To use bundled ntc-cmake, add its subdirectory to CMake module path with `list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/ntc-cmake")`.

The example project shows both approaches.
