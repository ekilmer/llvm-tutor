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

#===============================================================================
# 2. ADD SUB-TARGETS
# Doing this now so that we can add all common compilation settings to all
# targets at once.
#===============================================================================
add_subdirectory(lib)
add_subdirectory(tools)
add_subdirectory(test)
add_subdirectory(HelloWorld)

#===============================================================================
# 3. LLVM-TUTOR BUILD CONFIGURATION
#===============================================================================
# Convenience list for all of our targets, since they all get the same settings
set(ALL_TARGETS
  ${LLVM_TUTOR_PLUGINS} # ./lib
  static # ./tools
)

foreach(target ${ALL_TARGETS})
  # Use at least C++14 standard because LLVM requires it
  target_compile_features(${target} PUBLIC cxx_std_14)

  # Compiler flags
  separate_arguments(llvm_def_list NATIVE_COMMAND "${LLVM_DEFINITIONS}")
  target_compile_definitions(${target} PUBLIC ${llvm_def_list})

  # LLVM is normally built without RTTI. Be consistent with that.
  if(NOT LLVM_ENABLE_RTTI)
    target_compile_options(${target} PUBLIC
      # Replace with $<$<COMPILE_LANG_AND_ID:CXX,GNU,Clang,AppleClang>:...> if
      # CMake version is bumped to 3.15+
      $<$<AND:$<COMPILE_LANGUAGE:CXX>,$<CXX_COMPILER_ID:MSVC>>:/GR->
      $<$<AND:$<COMPILE_LANGUAGE:CXX>,$<NOT:$<CXX_COMPILER_ID:MSVC>>>:-fno-rtti>
    )
  endif()

  # -fvisibility-inlines-hidden is set when building LLVM and on Darwin warnings
  # are triggered if llvm-tutor is built without this flag (though otherwise it
  # builds fine). For consistency, add it here too.
  target_compile_options(${target} PUBLIC
    # Replace with $<$<COMPILE_LANG_AND_ID:CXX,GNU,Clang,AppleClang>:...> if
    # CMake version is bumped to 3.15+
    $<$<AND:$<COMPILE_LANGUAGE:CXX>,$<NOT:$<CXX_COMPILER_ID:MSVC>>>:-fvisibility-inlines-hidden>
  )
endforeach()
