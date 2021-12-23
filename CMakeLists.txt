cmake_minimum_required(VERSION 3.13.4)
project(llvm-tutor CXX)
include(GNUInstallDirs)

# Global CMake Project configuration(s)
# Place all binary and library artifacts in a consistent location for lit testing
if(NOT CMAKE_RUNTIME_OUTPUT_DIRECTORY)
  set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_INSTALL_BINDIR})
endif()
if(NOT CMAKE_LIBRARY_OUTPUT_DIRECTORY)
  set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR})
endif()
if(NOT CMAKE_ARCHIVE_OUTPUT_DIRECTORY)
  set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR})
endif()

#===============================================================================
# 1. LOAD LLVM CONFIGURATION
#    For more: http://llvm.org/docs/CMake.html#embedding-llvm-in-your-project
#===============================================================================
# During CMake configuration, set 'LLVM_DIR' to the directory containing
# LLVMConfig.cmake, so that find_package can locate it
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
include(cmake/fix_llvm_compilation_settings.cmake)

#===============================================================================
# 2. ADD SUB-TARGETS
# Doing this now so that we can add all common compilation settings to all
# targets at once.
#===============================================================================
add_subdirectory(lib)
add_subdirectory(tools)
add_subdirectory(test)
add_subdirectory(HelloWorld)
