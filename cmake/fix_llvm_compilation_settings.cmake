# Use this to add missing compilation settings to a target that links against LLVM
# Optionally, pass an explicit visibility keyword (PUBLIC, PRIVATE, INTERFACE) to
# set all properties to that keyword
function(fix_llvm_compilation_settings target)
  if(NOT TARGET ${target})
    message(WARNING "Cannot fixup LLVM compilation settings because '${target}' is not a CMake target. Doing nothing")
  else()
    get_target_property(target_type ${target} TYPE)

    # Setup some sane CMake property visibility defaults
    if(${ARGC} GREATER 1)
      set(visibility ${ARGV1})
    else()
      set(visibility PUBLIC)
      if("${target_type}" STREQUAL "EXECUTABLE")
        set(visibility PRIVATE)
      elseif("${target_type}" STREQUAL "INTERFACE_LIBRARY")
        set(visibility INTERFACE)
      endif()
    endif()

    # LLVM passes require special fixups
    if("${target_type}" STREQUAL "MODULE_LIBRARY")
      # Remove the "lib" prefix, because this isn't a normal library for other
      # tools to link against
      set_target_properties(${target} PROPERTIES PREFIX "")

      if (APPLE)
        # Allow undefined symbols in shared objects on Darwin (this is the
        # default behaviour on Linux)
        target_link_options(${target} PUBLIC -undefined dynamic_lookup)

        # Change default CMake module output suffix on macOS. By default this
        # is '.so', but opt looks for '.dylib'
        set_target_properties(${target} PROPERTIES SUFFIX ".dylib")
      endif()
    endif()

    # Add LLVM include directories
    target_include_directories(${target} SYSTEM ${visibility}
      "$<BUILD_INTERFACE:${LLVM_INCLUDE_DIRS}>"
    )

    # LLVM interface compiler flags
    separate_arguments(llvm_def_list NATIVE_COMMAND "${LLVM_DEFINITIONS}")
    target_compile_definitions(${target} ${visibility} ${llvm_def_list})

    # LLVM is normally built without RTTI. Be consistent with that.
    if(NOT LLVM_ENABLE_RTTI)
      target_compile_options(${target} ${visibility}
        # Replace with $<$<COMPILE_LANG_AND_ID:CXX,GNU,Clang,AppleClang>:...> if
        # CMake version is bumped to 3.15+
        $<$<AND:$<COMPILE_LANGUAGE:CXX>,$<CXX_COMPILER_ID:MSVC>>:/GR->
        $<$<AND:$<COMPILE_LANGUAGE:CXX>,$<NOT:$<CXX_COMPILER_ID:MSVC>>>:-fno-rtti>
      )
    endif()

    # -fvisibility-inlines-hidden is set when building LLVM and on Darwin warnings
    # are triggered if llvm-tutor is built without this flag (though otherwise it
    # builds fine). For consistency, add it here too.
    target_compile_options(${target} ${visibility}
      # Replace with $<$<COMPILE_LANG_AND_ID:CXX,GNU,Clang,AppleClang>:...> if
      # CMake version is bumped to 3.15+
      $<$<AND:$<COMPILE_LANGUAGE:CXX>,$<NOT:$<CXX_COMPILER_ID:MSVC>>>:-fvisibility-inlines-hidden>
    )
  endif()
endfunction()