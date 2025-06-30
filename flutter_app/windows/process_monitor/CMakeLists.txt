cmake_minimum_required(VERSION 3.5)
project(process_monitor)

add_library(process_monitor SHARED process_monitor.cpp)
set_target_properties(process_monitor PROPERTIES
    WINDOWS_EXPORT_ALL_SYMBOLS ON
    OUTPUT_NAME "process_monitor"
) 