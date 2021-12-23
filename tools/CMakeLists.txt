add_executable(static
  StaticMain.cpp
  ../lib/StaticCallCounter.cpp
)

# Link to the required LLVM static libraries
target_link_libraries(static PUBLIC
  LLVMCore
  LLVMPasses
  LLVMIRReader
  LLVMSupport
)

# Use at least C++14 standard because LLVM requires it
target_compile_features(static PRIVATE cxx_std_14)

# Setup the include directories
target_include_directories(static PUBLIC
  "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/../include>"
)
target_include_directories(static SYSTEM PUBLIC
  "$<BUILD_INTERFACE:${LLVM_INCLUDE_DIRS}>"
)
