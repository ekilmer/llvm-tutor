# Our main executable
add_executable(static
  StaticMain.cpp
)

# Link to the static library pass we built in lib
target_link_libraries(static PRIVATE StaticCallCounter)

# Compilation settings
# Use at least C++14 standard because LLVM requires it
target_compile_features(static PRIVATE cxx_std_14)

# Setup the include directories
target_include_directories(static PRIVATE
  "$<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>"
)

# Fixup everything else required to build with LLVM
fix_llvm_compilation_settings(static)
