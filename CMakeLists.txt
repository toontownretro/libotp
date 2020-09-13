cmake_minimum_required(VERSION 2.8.8 FATAL_ERROR)
project(libotp)

SET(BUILD_STATIC_LIB OFF CACHE BOOL "If true, will build a static lib")

set(Python_USE_STATIC_LIBS ${BUILD_STATIC_LIB})

set(PYTHON_VERSION "" CACHE STRING "Optional user-selected Python version")
if(PYTHON_VERSION)
  find_package(Python ${PYTHON_VERSION} EXACT COMPONENTS Interpreter Development REQUIRED)
else()
  find_package(Python COMPONENTS Interpreter Development REQUIRED)
endif()

if(NOT Python_FOUND)
    message(FATAL_ERROR "Python not found.")
endif()

find_package(PythonInterp)
if(NOT PYTHONINTERP_FOUND)
    message(FATAL_ERROR "Python interpreter not found.")
endif()

if(PYTHON_VERSION_MAJOR EQUAL 2)
    set(PYTHON2_EXECUTABLE "${PYTHON_EXECUTABLE}")
else()
    set(PYTHON2_EXECUTABLE python2)
endif()

### Panda3D dir ###
if(APPLE)
    SET(PANDA_DIR "/Developer/Panda3D" CACHE STRING "Panda3D directory.")
endif()
if(WIN32)
    SET(PANDA_DIR "C:/Panda3D-1.11.0-x64-astron" CACHE STRING "Panda3D directory.")
endif()
execute_process(COMMAND ${PYTHON2_EXECUTABLE} "${CMAKE_SOURCE_DIR}/src/run_interrogate.py" "${PANDA_DIR}")

### Define core components ###
    
set(OTPBASE_FILES
    src/otpbase/otpbase.cxx
    src/otpbase/otpbase.h
    src/otpbase/otpsymbols.cxx
    src/otpbase/otpsymbols.h
)

set(MOVEMENT_FILES
    src/movement/config_movement.cxx
    src/movement/config_movement.h
    src/movement/cImpulse.cxx
    src/movement/cImpulse.h
    src/movement/cImpulse.I
    src/movement/cMover.cxx
    src/movement/cMover.h
    src/movement/cMover.I
    src/movement/cMoverGroup.cxx
    src/movement/cMoverGroup.h
    src/movement/cMoverGroup.I
)

set(NAMETAG_FILES
    src/nametag/config_nametag.cxx
    src/nametag/config_nametag.h
    src/nametag/chatBalloon.cxx
    src/nametag/chatBalloon.h
    src/nametag/chatBalloon.I
    src/nametag/chatFlags.h
    src/nametag/clickablePopup.cxx
    src/nametag/clickablePopup.h
    src/nametag/clickablePopup.I
    src/nametag/marginManager.cxx
    src/nametag/marginManager.h
    src/nametag/marginManager.I
    src/nametag/marginPopup.cxx
    src/nametag/marginPopup.h
    src/nametag/marginPopup.I
    src/nametag/nametag.cxx
    src/nametag/nametag.h
    src/nametag/nametag.I
    src/nametag/nametag2d.cxx
    src/nametag/nametag2d.h
    src/nametag/nametag2d.I
    src/nametag/nametag3d.cxx
    src/nametag/nametag3d.h
    src/nametag/nametag3d.I
    src/nametag/nametagFloat2d.cxx
    src/nametag/nametagFloat2d.h
    src/nametag/nametagFloat3d.cxx
    src/nametag/nametagFloat3d.h
    src/nametag/nametagGlobals.cxx
    src/nametag/nametagGlobals.h
    src/nametag/nametagGroup.cxx
    src/nametag/nametagGroup.h
    src/nametag/nametagGroup.I
    src/nametag/popupMouseWatcherRegion.cxx
    src/nametag/popupMouseWatcherRegion.h
    src/nametag/popupMouseWatcherRegion.I
    src/nametag/whisperPopup.cxx
    src/nametag/whisperPopup.h
    src/nametag/whisperPopup.I
)

set(IGATE_FILES
    src/movement_igate.cxx
    src/nametag_igate.cxx
    src/libotp_module.cxx
)

include_directories(src/otpbase)
include_directories(src/movement)
include_directories(src/nametag)
include_directories(${PANDA_DIR}/include)
include_directories(${Python_INCLUDE_DIRS})
include_directories(/usr/include/eigen3)
link_directories(${PANDA_DIR}/lib)

set(LIBPFX "")
if(MSVC)
    set(LIBPFX "lib")
    add_definitions(/wd4275)
endif()

if(CMAKE_CXX_COMPILER_ID MATCHES "GNU")
    execute_process(COMMAND "${CMAKE_C_COMPILER}" -dumpversion OUTPUT_VARIABLE GCC_VERSION)
    message(STATUS "GCC Version: ${GCC_VERSION}")
    if(GCC_VERSION VERSION_GREATER 4.7 OR GCC_VERSION VERSION_EQUAL 4.7)
        add_definitions(-std=c++11) # Enable the new C++ standard
    else()
        add_definitions(-std=c++0x) # Enable the new C++ standard
    endif()

    add_definitions(-Wno-ignored-attributes -Wno-deprecated-declarations -Wno-misleading-indentation)
elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    execute_process(COMMAND "${CMAKE_C_COMPILER}" -dumpversion OUTPUT_VARIABLE CLANG_VERSION)
    message(STATUS "Clang Version: ${CLANG_VERSION}")
    add_definitions(-std=c++11) # Enable the new C++ standard
    add_definitions(-Wno-ignored-attributes -Wno-deprecated-declarations)
endif()

add_definitions(-DBUILDING_OTP)

if(NOT BUILD_STATIC_LIB)
    set(PANDA_LIBS
        ${LIBPFX}p3framework
        ${LIBPFX}panda
        ${LIBPFX}pandafx
        ${LIBPFX}pandaexpress
        ${LIBPFX}p3dtool
        ${LIBPFX}p3dtoolconfig
        ${LIBPFX}p3direct
    )

    # Add p3interrogatedb, if it exists
    find_library(HAVE_P3INTERROGATEDB
                 ${LIBPFX}p3interrogatedb
                 HINTS ${PANDA_DIR}/lib)

    if(HAVE_P3INTERROGATEDB)
        message(STATUS "libp3interrogatedb found")
        LIST(APPEND PANDA_LIBS ${LIBPFX}p3interrogatedb)
    else()
        message(STATUS "libp3interrogatedb not found")
    endif()

    # Add p3pandatoolbase, if it exists
    find_library(HAVE_P3PANDATOOLBASE
                 ${LIBPFX}p3pandatoolbase
                 HINTS ${PANDA_DIR}/lib)

    if(HAVE_P3PANDATOOLBASE)
        message(STATUS "libp3pandatoolbase found")
        LIST(APPEND PANDA_LIBS ${LIBPFX}p3pandatoolbase)
    else()
        message(STATUS "libp3pandatoolbase not found")
    endif()
    
    if(WIN32)
        add_library(libotp SHARED
            ${OTPBASE_FILES}
            ${MOVEMENT_FILES}
            ${NAMETAG_FILES}
            ${IGATE_FILES}
        )
        SET_TARGET_PROPERTIES(libotp PROPERTIES SUFFIX ".pyd")
        target_link_libraries(libotp ${PANDA_LIBS} ${Python_LIBRARIES})
        add_custom_command(TARGET libotp
                           PRE_BUILD
                           COMMAND ${PYTHON2_EXECUTABLE} "${CMAKE_SOURCE_DIR}/src/run_interrogate.py" "${PANDA_DIR}"
                           COMMENT "Interrogate")

    else()
        add_library(otp MODULE
            ${OTPBASE_FILES}
            ${MOVEMENT_FILES}
            ${NAMETAG_FILES}
            ${IGATE_FILES}
        )
        target_link_libraries(otp otp ${PANDA_LIBS} ${Python_LIBRARIES})
        add_custom_command(TARGET otp
                           PRE_BUILD
                           COMMAND ${PYTHON2_EXECUTABLE} "${CMAKE_SOURCE_DIR}/src/run_interrogate.py" "${PANDA_DIR}"
                           COMMENT "Interrogate")
    endif()

else()

    if(WIN32)
        add_library(libotp STATIC
            ${OTPBASE_FILES}
            ${MOVEMENT_FILES}
            ${NAMETAG_FILES}
            ${IGATE_FILES}
        )
        add_custom_command(TARGET libotp
                           PRE_BUILD
                           COMMAND ${PYTHON2_EXECUTABLE} "${CMAKE_SOURCE_DIR}/src/run_interrogate.py" "${PANDA_DIR}"
                           COMMENT "Interrogate")

    else()
        add_library(otp STATIC
            ${OTPBASE_FILES}
            ${MOVEMENT_FILES}
            ${NAMETAG_FILES}
            ${IGATE_FILES}
        )
        add_custom_command(TARGET otp
                           PRE_BUILD
                           COMMAND ${PYTHON2_EXECUTABLE} "${CMAKE_SOURCE_DIR}/src/run_interrogate.py" "${PANDA_DIR}"
                           COMMENT "Interrogate")
    endif()

endif()

### Setup source groups and defines for configurables ###
source_group("otpbase" FILES ${OTPBASE_FILES})
source_group("movement" FILES ${MOVEMENT_FILES})
source_group("nametag" FILES ${NAMETAG_FILES})
source_group("interrogate_files" FILES ${IGATE_FILES})