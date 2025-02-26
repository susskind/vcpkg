# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

if(UNIX)
  set(CMAKE_HIP_OUTPUT_EXTENSION .o)
else()
  set(CMAKE_HIP_OUTPUT_EXTENSION .obj)
endif()
set(CMAKE_INCLUDE_FLAG_HIP "-I")

# Load compiler-specific information.
if(CMAKE_HIP_COMPILER_ID)
  include(Compiler/${CMAKE_HIP_COMPILER_ID}-HIP OPTIONAL)
endif()

# load the system- and compiler specific files
if(CMAKE_HIP_COMPILER_ID)
  # load a hardware specific file, mostly useful for embedded compilers
  if(CMAKE_SYSTEM_PROCESSOR)
    include(Platform/${CMAKE_EFFECTIVE_SYSTEM_NAME}-${CMAKE_HIP_COMPILER_ID}-HIP-${CMAKE_SYSTEM_PROCESSOR} OPTIONAL)
  endif()
  include(Platform/${CMAKE_EFFECTIVE_SYSTEM_NAME}-${CMAKE_HIP_COMPILER_ID}-HIP OPTIONAL)
endif()


if(NOT CMAKE_SHARED_LIBRARY_RUNTIME_HIP_FLAG)
  set(CMAKE_SHARED_LIBRARY_RUNTIME_HIP_FLAG ${CMAKE_SHARED_LIBRARY_RUNTIME_C_FLAG})
endif()

if(NOT CMAKE_SHARED_LIBRARY_RUNTIME_HIP_FLAG_SEP)
  set(CMAKE_SHARED_LIBRARY_RUNTIME_HIP_FLAG_SEP ${CMAKE_SHARED_LIBRARY_RUNTIME_C_FLAG_SEP})
endif()

if(NOT CMAKE_SHARED_LIBRARY_RPATH_LINK_HIP_FLAG)
  set(CMAKE_SHARED_LIBRARY_RPATH_LINK_HIP_FLAG ${CMAKE_SHARED_LIBRARY_RPATH_LINK_C_FLAG})
endif()

if(NOT DEFINED CMAKE_EXE_EXPORTS_HIP_FLAG)
  set(CMAKE_EXE_EXPORTS_HIP_FLAG ${CMAKE_EXE_EXPORTS_C_FLAG})
endif()

if(NOT DEFINED CMAKE_SHARED_LIBRARY_SONAME_HIP_FLAG)
  set(CMAKE_SHARED_LIBRARY_SONAME_HIP_FLAG ${CMAKE_SHARED_LIBRARY_SONAME_C_FLAG})
endif()

if(NOT CMAKE_EXECUTABLE_RUNTIME_HIP_FLAG)
  set(CMAKE_EXECUTABLE_RUNTIME_HIP_FLAG ${CMAKE_SHARED_LIBRARY_RUNTIME_HIP_FLAG})
endif()

if(NOT CMAKE_EXECUTABLE_RUNTIME_HIP_FLAG_SEP)
  set(CMAKE_EXECUTABLE_RUNTIME_HIP_FLAG_SEP ${CMAKE_SHARED_LIBRARY_RUNTIME_HIP_FLAG_SEP})
endif()

if(NOT CMAKE_EXECUTABLE_RPATH_LINK_HIP_FLAG)
  set(CMAKE_EXECUTABLE_RPATH_LINK_HIP_FLAG ${CMAKE_SHARED_LIBRARY_RPATH_LINK_HIP_FLAG})
endif()

if(NOT DEFINED CMAKE_SHARED_LIBRARY_LINK_HIP_WITH_RUNTIME_PATH)
  set(CMAKE_SHARED_LIBRARY_LINK_HIP_WITH_RUNTIME_PATH ${CMAKE_SHARED_LIBRARY_LINK_C_WITH_RUNTIME_PATH})
endif()


# for most systems a module is the same as a shared library
# so unless the variable CMAKE_MODULE_EXISTS is set just
# copy the values from the LIBRARY variables
if(NOT CMAKE_MODULE_EXISTS)
  set(CMAKE_SHARED_MODULE_HIP_FLAGS ${CMAKE_SHARED_LIBRARY_HIP_FLAGS})
  set(CMAKE_SHARED_MODULE_CREATE_HIP_FLAGS ${CMAKE_SHARED_LIBRARY_CREATE_HIP_FLAGS})
endif()

# add the flags to the cache based
# on the initial values computed in the platform/*.cmake files
# use _INIT variables so that this only happens the first time
# and you can set these flags in the cmake cache
set(CMAKE_HIP_FLAGS_INIT "$ENV{HIPFLAGS} ${CMAKE_HIP_FLAGS_INIT}")

cmake_initialize_per_config_variable(CMAKE_HIP_FLAGS "Flags used by the HIP compiler")

if(CMAKE_HIP_STANDARD_LIBRARIES_INIT)
  set(CMAKE_HIP_STANDARD_LIBRARIES "${CMAKE_HIP_STANDARD_LIBRARIES_INIT}"
    CACHE STRING "Libraries linked by default with all HIP applications.")
  mark_as_advanced(CMAKE_HIP_STANDARD_LIBRARIES)
endif()

if(NOT CMAKE_HIP_COMPILER_LAUNCHER AND DEFINED ENV{CMAKE_HIP_COMPILER_LAUNCHER})
  set(CMAKE_HIP_COMPILER_LAUNCHER "$ENV{CMAKE_HIP_COMPILER_LAUNCHER}"
    CACHE STRING "Compiler launcher for HIP.")
endif()

include(CMakeCommonLanguageInclude)

# now define the following rules:
# CMAKE_HIP_CREATE_SHARED_LIBRARY
# CMAKE_HIP_CREATE_SHARED_MODULE
# CMAKE_HIP_COMPILE_OBJECT
# CMAKE_HIP_LINK_EXECUTABLE

# create a shared library
if(NOT CMAKE_HIP_CREATE_SHARED_LIBRARY)
  set(CMAKE_HIP_CREATE_SHARED_LIBRARY
      "<CMAKE_HIP_COMPILER> <CMAKE_SHARED_LIBRARY_HIP_FLAGS> <LANGUAGE_COMPILE_FLAGS> <LINK_FLAGS> <CMAKE_SHARED_LIBRARY_CREATE_HIP_FLAGS> <SONAME_FLAG><TARGET_SONAME> -o <TARGET> <OBJECTS> <LINK_LIBRARIES>")
endif()

# create a shared module copy the shared library rule by default
if(NOT CMAKE_HIP_CREATE_SHARED_MODULE)
  set(CMAKE_HIP_CREATE_SHARED_MODULE ${CMAKE_HIP_CREATE_SHARED_LIBRARY})
endif()

# Create a static archive incrementally for large object file counts.
if(NOT DEFINED CMAKE_HIP_ARCHIVE_CREATE)
  set(CMAKE_HIP_ARCHIVE_CREATE "<CMAKE_AR> qc <TARGET> <LINK_FLAGS> <OBJECTS>")
endif()
if(NOT DEFINED CMAKE_HIP_ARCHIVE_APPEND)
  set(CMAKE_HIP_ARCHIVE_APPEND "<CMAKE_AR> q <TARGET> <LINK_FLAGS> <OBJECTS>")
endif()
if(NOT DEFINED CMAKE_HIP_ARCHIVE_FINISH)
  set(CMAKE_HIP_ARCHIVE_FINISH "<CMAKE_RANLIB> <TARGET>")
endif()

# compile a HIP file into an object file
if(NOT CMAKE_HIP_COMPILE_OBJECT)
  set(CMAKE_HIP_COMPILE_OBJECT
    "<CMAKE_HIP_COMPILER> <DEFINES> <INCLUDES> <FLAGS> -o <OBJECT> ${_CMAKE_COMPILE_AS_HIP_FLAG} -c <SOURCE>")
endif()

# compile a cu file into an executable
if(NOT CMAKE_HIP_LINK_EXECUTABLE)
  set(CMAKE_HIP_LINK_EXECUTABLE
    "<CMAKE_HIP_COMPILER> <FLAGS> <CMAKE_HIP_LINK_FLAGS> <LINK_FLAGS> <OBJECTS> -o <TARGET> <LINK_LIBRARIES>")
endif()

set(CMAKE_HIP_INFORMATION_LOADED 1)

# Load the file and find the relevant HIP runtime.
# This file will only exist after all compiler detection has finished
include(${CMAKE_PLATFORM_INFO_DIR}/CMakeHIPRuntime.cmake OPTIONAL)
if(COMMAND _CMAKE_FIND_HIP_RUNTIME)
  _CMAKE_FIND_HIP_RUNTIME()
endif()
