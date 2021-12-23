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

# Provides macro to fixup LLVM compilation settings for our targets
include(../cmake/fix_llvm_compilation_settings.cmake)

#===============================================================================
# 2. ADD THE TARGET
#===============================================================================
if(NOT (WIN32 OR CYGWIN))
  add_library(HelloWorldPass MODULE HelloWorld.cpp)
  # Set the name back to the plugin name
  set_target_properties(HelloWorldPass PROPERTIES OUTPUT_NAME HelloWorld)
else()
  message(WARNING "Building loadable pass modules on Windows is difficult/impossible.")
  # See the following references:
  #  * https://reviews.llvm.org/D79771
  #  * https://reviews.llvm.org/D47082
  #  * https://reviews.llvm.org/D18826
  #  * https://llvm.discourse.group/t/how-to-create-pass-independently-on-windows/474
  return()
endif()

#===============================================================================
# 3. LLVM-TUTOR BUILD CONFIGURATION
#===============================================================================
# Use at least C++14 standard because LLVM requires it
target_compile_features(HelloWorldPass PRIVATE cxx_std_14)

# Fixup everything else required to build with LLVM
fix_llvm_compilation_settings(HelloWorldPass)