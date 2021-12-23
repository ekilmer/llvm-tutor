# THE LIST OF PLUGINS AND THE CORRESPONDING SOURCE FILES
# ======================================================
if(WIN32 OR CYGWIN)
  message(WARNING "Building loadable pass modules on Windows is difficult/impossible.")
  # Building loadable modules on Windows is difficult/impossible.
  # See the following references:
  #  * https://reviews.llvm.org/D79771
  #  * https://reviews.llvm.org/D47082
  #  * https://reviews.llvm.org/D18826
  #  * https://llvm.discourse.group/t/how-to-create-pass-independently-on-windows/474
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
foreach(plugin ${LLVM_TUTOR_PLUGINS})
  set(pass "${plugin}Pass")
  # Create a module corresponding to 'plugin'
  add_library(${pass} MODULE ${${plugin}_SOURCES})
  # Set the name back to the plugin name
  set_target_properties(${pass} PROPERTIES OUTPUT_NAME ${plugin})

    # Use at least C++14 standard because LLVM requires it
  target_compile_features(${pass} PRIVATE cxx_std_14)

  # Configure include directories for 'plugin'
  # plugin specific include directory
  target_include_directories(${pass} PRIVATE
    "$<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>"
  )

  # Fixup everything else required to build with LLVM
  fix_llvm_compilation_settings("${pass}")

  # We also create a standalone tool for this pass, so we need a usable library
  if("${plugin}" STREQUAL "StaticCallCounter")
    # We create only a static library for now
    add_library(${plugin} STATIC ${${plugin}_SOURCES})
    # Link to the required LLVM static libraries
    target_link_libraries(${plugin} PUBLIC
      LLVMCore
      LLVMPasses
      LLVMIRReader
      LLVMSupport
    )
    target_compile_features(${plugin} PUBLIC cxx_std_14)
    target_include_directories(${plugin} PUBLIC
      "$<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>"
    )
    fix_llvm_compilation_settings("${plugin}")
  endif()
endforeach()
