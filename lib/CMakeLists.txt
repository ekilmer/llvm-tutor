# THE LIST OF PLUGINS AND THE CORRESPONDING SOURCE FILES
# ======================================================
if(WIN32 OR CYGWIN)
  message(WARNING "Building loadable pass modules on Windows is difficult/impossible.")
  # See notes below on references concerning loadable LLVM pass modules
  # Load LLVM's CMake macros and functions
  # list(APPEND CMAKE_MODULE_PATH "${LLVM_CMAKE_DIR}")
  # include(AddLLVM)
  return()
endif()

set(LLVM_TUTOR_PLUGINS
    StaticCallCounter
    DynamicCallCounter
    FindFCmpEq
    ConvertFCmpEq
    InjectFuncCall
    MBAAdd
    MBASub
    RIV
    DuplicateBB
    OpcodeCounter
    MergeBB
    )
# Set in parent scope also for adding project-wide settings to all of these
# targets. Convenience variable
set(LLVM_TUTOR_PLUGINS ${LLVM_TUTOR_PLUGINS} PARENT_SCOPE)

set(StaticCallCounter_SOURCES
  StaticCallCounter.cpp)
set(DynamicCallCounter_SOURCES
  DynamicCallCounter.cpp)
set(FindFCmpEq_SOURCES
  FindFCmpEq.cpp)
set(ConvertFCmpEq_SOURCES
  ConvertFCmpEq.cpp)
set(InjectFuncCall_SOURCES
  InjectFuncCall.cpp)
set(MBAAdd_SOURCES
  MBAAdd.cpp
  Ratio.cpp)
set(MBASub_SOURCES
  MBASub.cpp
  Ratio.cpp)
set(RIV_SOURCES
  RIV.cpp)
set(DuplicateBB_SOURCES
  DuplicateBB.cpp)
set(OpcodeCounter_SOURCES
  OpcodeCounter.cpp)
set(MergeBB_SOURCES
  MergeBB.cpp)

# CONFIGURE THE PLUGIN LIBRARIES
# ==============================
foreach( plugin ${LLVM_TUTOR_PLUGINS} )
  # Create a library corresponding to 'plugin'
  if(NOT (WIN32 OR CYGWIN))
    add_library(${plugin} SHARED ${${plugin}_SOURCES})
  else()
    # Building loadable modules on Windows is difficult/impossible.
    # See the following references:
    #  * https://reviews.llvm.org/D79771
    #  * https://reviews.llvm.org/D47082
    #  * https://reviews.llvm.org/D18826
    #  * https://llvm.discourse.group/t/how-to-create-pass-independently-on-windows/474

    # add_llvm_library(${plugin} MODULE BUILDTREE_ONLY
    #   ${${plugin}_SOURCES}

    #   DEPENDS
    #     intrinsics_gen
    #   PLUGIN_TOOL
    #     opt
    # )
  endif()

  # Configure include directories for 'plugin'
  # plugin specific include directory
  target_include_directories(${plugin} PRIVATE
    "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/../include>"
  )
  # LLVM include directories
  target_include_directories(${plugin} SYSTEM PUBLIC
    "$<BUILD_INTERFACE:${LLVM_INCLUDE_DIRS}>"
  )

  # On Darwin (unlike on Linux), undefined symbols in shared objects are not
  # allowed at the end of the link-edit. The plugins defined here:
  #  - _are_ shared objects
  #  - reference symbols from LLVM shared libraries, i.e. symbols which are
  #    undefined until those shared objects are loaded in memory (and hence
  #    _undefined_ during static linking)
  # The build will fail with errors like this:
  #    "Undefined symbols for architecture x86_64"
  # with various LLVM symbols being undefined. Since those symbols are later
  # loaded and resolved at runtime, these errors are false positives.
  # This behaviour can be modified via the '-undefined' OS X linker flag as
  # follows.
  target_link_options(${plugin} PUBLIC
    $<$<PLATFORM_ID:Darwin>:-undefined dynamic_lookup>
  )
endforeach()
