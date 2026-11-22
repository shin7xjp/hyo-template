cmake_minimum_required(VERSION 3.22)
project(hyo_app LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Locate hyo-core framework
if(DEFINED ENV{HYO_CORE_DIR} AND EXISTS "$ENV{HYO_CORE_DIR}")
    set(HYO_CORE_PATH "$ENV{HYO_CORE_DIR}")
elseif(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/../../hyo-core")
    set(HYO_CORE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/../../hyo-core")
else()
    set(HYO_CORE_PATH "/home/doyun/dev/hyo/hyo-core")
endif()

message(STATUS "Using Hyo Core from: ${HYO_CORE_PATH}")

add_subdirectory(
    "${HYO_CORE_PATH}"
    "${CMAKE_CURRENT_BINARY_DIR}/hyo-core-build"
)
