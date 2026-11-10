cmake_minimum_required(VERSION "3.28.3")
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(OUTDIR "$ENV{out}/bin")
project("$ENV{APPNAME}")
set(SOURCES
    "$ENV{src}/src/main.cpp"
    "$ENV{src}/src/next.cpp"
)
add_executable("${PROJECT_NAME}" "${SOURCES}")
install(TARGETS "${PROJECT_NAME}" DESTINATION "${OUTDIR}")
install(FILES "${CMAKE_BINARY_DIR}/compile_commands.json" DESTINATION "$ENV{out}/build")
