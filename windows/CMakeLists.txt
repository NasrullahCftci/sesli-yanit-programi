cmake_minimum_required(VERSION 3.14)
project(voice_reader_app LANGUAGES CXX)

set(BINARY_NAME "voice_reader_app")
set(APPLICATION_ID "com.example.voice_reader_app")

cmake_policy(SET CMP0063 NEW)

set(CMAKE_INSTALL_RPATH "$ORIGIN/lib")

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -DNDEBUG")

set(FLUTTER_MANAGED_DIR "${CMAKE_CURRENT_SOURCE_DIR}/flutter")

add_subdirectory(${FLUTTER_MANAGED_DIR})

add_subdirectory("runner")

add_custom_target(flutter_assemble DEPENDS
  "${FLUTTER_MANAGED_DIR}/generated_plugin_registrant.cc"
)
