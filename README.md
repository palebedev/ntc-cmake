NTC CMake - common cmake tasks helpers
======================================

This package contains a set of CMake modules that automate common tasks. It can be used with CMake 3.16+ either as bundled code by adding to CMake module path or installed as a package to some prefix and loaded with `find_package`. See `examples` subdirectory for sample usage.

The following modules are available:

ntc-target-helpers
------------------

Provides the following command:

```CMake
ntc_target(<target> [INCLUDE_INFIX <include_infix>] [PRIVATE_CONFIG])
```

Before calling this function, set the value of `NAMESPACE` and, optionally, `COMPONENT` variables to specify structured name of the target.

`ntc_target` applies the following changes to target:

- An alias target named `${NAMESPACE}::${COMPONENT}` or `${NAMESPACE}::${NAMESPACE}` if `COMPONENT` is unset.
- Target binary is installed.
- If a file named `src/config.hpp.in` exists in current source directory, it is processed with `configure_file` in `ESCAPE_QUOTES` mode and the result is written to `include/${NAMESPACE}/${include_infix}/config.hpp` in current binary directory. Unless the target is an executable or `PRIVATE_CONFIG` is specified, this header is installed.
- If the target is a library:
  - Object libraries are not supported and rejected with an error.
  - Subdirectory `include/${NAMESPACE}` in current source directory is installed.
  - Binary version is set to the version of current project.
  - For library targets that are not interface libraries, an export header `include/${NAMESPACE}/${include_infix}export.h` is created in current binary directory. This header is then installed.
- `include` subdirectories under current source and binary directories are added to the target include directories, if present. These includes are added as `PUBLIC` for libraries and `PRIVATE` for executables and are effective only during build.
- C++ standard extensions are disabled for target.
- If the file `<target>-config.cmake.in` exists in current source directory, it is processed with `configure_package_config_file` from `CMakePackageConfigHelpers` module. A package version file is generated with the current project's version and compatibility mode `SameMajorVersion`. These cmake modules and the corresponding target export module are then installed into subdirectory `${NAMESPACE}` under cmake module path in install prefix directory.

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
