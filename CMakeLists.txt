cmake_minimum_required(VERSION 3.18)
project(parts LANGUAGES CXX CUDA)

set(CMAKE_CUDA_STANDARD 14)

#find_package(yaml-cpp REQUIRED)

file(GLOB SOURCES
     *.cpp
     *.cu
     *.hpp
     *.cuh)

add_executable(parts ${SOURCES})

#target_link_libraries(parts PRIVATE yaml-cpp)

