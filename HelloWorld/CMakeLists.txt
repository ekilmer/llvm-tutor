cmake_minimum_required(VERSION 3.13.4)
project(llvm-tutor-hello-world CXX)
include(GNUInstallDirs)

#===============================================================================
# 1. LOAD LLVM CONFIGURATION
#===============================================================================
# Set 'LLVM_DIR' to the directory location of LLVMConfig.cmake so that
# find_package can locate it
find_package(LLVM 13 REQUIRED CONFIG)

# Another sanity check
if(NOT "13" VERSION_EQUAL "${LLVM_VERSION_MAJOR}")
  message(FATAL_ERROR "Found LLVM ${LLVM_VERSION_MAJOR}, but need LLVM 13")
endif()

message(STATUS "Found LLVM ${LLVM_PACKAGE_VERSION}")
message(STATUS "Using LLVMConfig.cmake in: ${LLVM_CMAKE_DIR}")

message("LLVM STATUS:
  Definitions ${LLVM_DEFINITIONS}
  Includes    ${LLVM_INCLUDE_DIRS}
  Libraries   ${LLVM_LIBRARY_DIRS}
  Targets     ${LLVM_TARGETS_TO_BUILD}"
)

#===============================================================================
# 2. ADD THE TARGET
#===============================================================================
if(NOT (WIN32 OR CYGWIN))
  add_library(HelloWorld SHARED HelloWorld.cpp)
else()
  message(WARNING "Building loadable pass modules on Windows is difficult/impossible.")
  # See the following references:
  #  * https://reviews.llvm.org/D79771
  #  * https://reviews.llvm.org/D47082
  #  * https://reviews.llvm.org/D18826
  #  * https://llvm.discourse.group/t/how-to-create-pass-independently-on-windows/474
  # Load LLVM's CMake macros and functions
  # list(APPEND CMAKE_MODULE_PATH "${LLVM_CMAKE_DIR}")
  # include(AddLLVM)

  # add_llvm_library(HelloWorld MODULE BUILDTREE_ONLY
  #   HelloWorld.cpp

  #   DEPENDS
  #     intrinsics_gen
  #   PLUGIN_TOOL
  #     opt
  # )
  return()
endif()

# Add LLVM include directories
target_include_directories(HelloWorld SYSTEM PUBLIC
  "$<BUILD_INTERFACE:${LLVM_INCLUDE_DIRS}>"
)

#===============================================================================
# 3. LLVM-TUTOR BUILD CONFIGURATION
#===============================================================================
# Use at least C++14 standard because LLVM requires it
target_compile_features(HelloWorld PUBLIC cxx_std_14)

# Allow undefined symbols in shared objects on Darwin (this is the default
# behaviour on Linux)
target_link_options(HelloWorld PUBLIC
  $<$<PLATFORM_ID:Darwin>:-undefined dynamic_lookup>
)

# Compiler flags
separate_arguments(llvm_def_list UNIX_COMMAND "${LLVM_DEFINITIONS}")
target_compile_definitions(HelloWorld PUBLIC ${llvm_def_list})

# LLVM is normally built without RTTI. Be consistent with that.
if(NOT LLVM_ENABLE_RTTI)
  # Replace with $<$<COMPILE_LANG_AND_ID:CXX,GNU,Clang,AppleClang>:...> if
  # CMake version is bumped to 3.15+
  target_compile_options(HelloWorld PUBLIC
    $<$<AND:$<COMPILE_LANGUAGE:CXX>,$<CXX_COMPILER_ID:MSVC>>:/GR->
    $<$<AND:$<COMPILE_LANGUAGE:CXX>,$<NOT:$<CXX_COMPILER_ID:MSVC>>>:-fno-rtti>
  )
endif()

# -fvisibility-inlines-hidden is set when building LLVM and on Darwin warnings
# are triggered if llvm-tutor is built without this flag (though otherwise it
# builds fine). For consistency, add it here too.
target_compile_options(HelloWorld PUBLIC
  # Replace with $<$<COMPILE_LANG_AND_ID:CXX,GNU,Clang,AppleClang>:...> if
  # CMake version is bumped to 3.15+
  $<$<AND:$<COMPILE_LANGUAGE:CXX>,$<NOT:$<CXX_COMPILER_ID:MSVC>>>:-fvisibility-inlines-hidden>
)
