# ---------------------------------------------------------------------------------------------------------------------------------------------------
#
# General CMake Setup
#
# ---------------------------------------------------------------------------------------------------------------------------------------------------

CMAKE_MINIMUM_REQUIRED( VERSION 2.8 )
cmake_policy(SET CMP0020 NEW)
cmake_policy(SET CMP0043 NEW)

SET( CMAKE_DISABLE_SOURCE_CHANGES ON )
SET( CMAKE_DISABLE_IN_SOURCE_BUILD ON )

PROJECT( braingl )
SET( BinName "${PROJECT_NAME}" )

# where to find our utils and cmake modules?
SET( FN_TOOLS_DIR ${PROJECT_SOURCE_DIR}/../tools )

# append search path for FindModules:
LIST( APPEND CMAKE_MODULE_PATH ${FN_TOOLS_DIR}/cmake )

INCLUDE( Utils )
INCLUDE( HGVersion )

OPTION( FN_VERBOSE_MAKEFILE "More output on compilation" OFF )
IF ( FN_VERBOSE_MAKEFILE )
    SET( CMAKE_VERBOSE_MAKEFILE ON )
ENDIF()

IF (NOT CMAKE_BUILD_TYPE)
    MESSAGE(STATUS "No build type selected, default to Release")
    SET(CMAKE_BUILD_TYPE "Release")
ENDIF()

# ---------------------------------------------------------------------------------------------------------------------------------------------------
# Some common setup
# ---------------------------------------------------------------------------------------------------------------------------------------------------
IF( ${CMAKE_BUILD_TYPE} MATCHES "Debug" )
    ADD_DEFINITIONS( -DQT_DEBUG_OUTPUT )
    ADD_DEFINITIONS( -D__DEBUG__ )
ENDIF()

IF( ${CMAKE_BUILD_TYPE} MATCHES "Release" )
    ADD_DEFINITIONS( -D__RELEASE__ )
ENDIF()

ADD_DEFINITIONS( -DHAVE_ZLIB )

# ---------------------------------------------------------------------------------------------------------------------------------------------------
#
# REQUIRED third party libs
#
# ---------------------------------------------------------------------------------------------------------------------------------------------------
IF( APPLE )
    FIND_PACKAGE( OpenGL REQUIRED )
ENDIF()

# -----------------------------------------------------------------------------------------------------------------------------------------------
# Boost
# -----------------------------------------------------------------------------------------------------------------------------------------------
FIND_PACKAGE( Boost 1.46.0 )
# include the boost headers
INCLUDE_DIRECTORIES( ${Boost_INCLUDE_DIR} )

# -----------------------------------------------------------------------------------------------------------------------------------------------
# VTK
# -----------------------------------------------------------------------------------------------------------------------------------------------
FIND_PACKAGE( VTK REQUIRED )
INCLUDE( ${VTK_USE_FILE} )


# ---------------------------------------------------------------------------------------------------------------------------------------------------
# Setup QT5
# ---------------------------------------------------------------------------------------------------------------------------------------------------
FIND_PACKAGE( Qt5 REQUIRED COMPONENTS Core Gui Widgets OpenGL Xml WebKit )

# Resources
SET(QtIcon_RCCS resources.qrc)

SET ( CMAKE_AUTOMOC ON )

# As moc files are generated in the binary dir, tell CMake to always look for includes there:
SET( CMAKE_INCLUDE_CURRENT_DIR ON )

QT5_ADD_RESOURCES( QtIcon_RCC_SRCS ${QtIcon_RCCS} )

# ---------------------------------------------------------------------------------------------------------------------------------------------------
# CXX flags
# ---------------------------------------------------------------------------------------------------------------------------------------------------
IF ( CMAKE_BUILD_TYPE MATCHES "Release" )
    set( CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -w -std=c++0x" )
ELSE()
    set( CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -pedantic -std=c++0x" )
ENDIF()

IF( APPLE )
    SET(CMAKE_CXX_FLAGS " ${CMAKE_CXX_FLAGS} -stdlib=libc++")
ENDIF()

IF( WIN32 )
    OPTION( SURPRESS_CMD_WINDOW "No cmd window" OFF )
    IF ( SURPRESS_CMD_WINDOW MATCHES ON )
        SET(CMAKE_CXX_FLAGS " ${CMAKE_CXX_FLAGS} -mwindows")
    ENDIF()
ENDIF()

# supress warnings from boost includes
 SET(CMAKE_CXX_FLAGS " ${CMAKE_CXX_FLAGS} -Wno-unused-local-typedefs" )

# ---------------------------------------------------------------------------------------------------------------------------------------------------
# Add sources as target
# ---------------------------------------------------------------------------------------------------------------------------------------------------
# surpress warnings in 3rd party sources
SET_PROPERTY( SOURCE ${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/nifti/nifti1_io.cpp PROPERTY COMPILE_FLAGS "-Wno-write-strings -Wno-sign-compare -Wno-unused-but-set-variable")
#SET_PROPERTY( SOURCE ${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/cnifti/CiftiXMLReader.cxx PROPERTY COMPILE_FLAGS "-Wstrict-overflow")
SET_PROPERTY( SOURCE ${CMAKE_CURRENT_SOURCE_DIR}/data/writervtk.cpp PROPERTY COMPILE_FLAGS "-Wno-deprecated" )
SET_PROPERTY( SOURCE ${CMAKE_CURRENT_SOURCE_DIR}/data/loadervtk.cpp PROPERTY COMPILE_FLAGS "-Wno-deprecated" )

# Collect the compile-files for this target
COLLECT_COMPILE_FILES( "${CMAKE_CURRENT_SOURCE_DIR}" TARGET_CPP_FILES TARGET_H_FILES TARGET_TEST_FILES )

IF ( CMAKE_VERBOSE_MAKEFILE )
      MESSAGE(STATUS)
      MESSAGE(STATUS "*******************************************************************************")
      MESSAGE(STATUS "*        SUMMARY OF USED VARIABLES -> Details in AllVariables.txt             *")
      MESSAGE(STATUS "*******************************************************************************")
IF( APPLE )
          MESSAGE(STATUS "COMPILING FOR OSX, platforms: ${CMAKE_OSX_ARCHITECTURES}")
ENDIF()
      MESSAGE(STATUS "CMAKE_ROOT ........................... = ${CMAKE_ROOT}")
      MESSAGE(STATUS "CMAKE_HOME_DIRECTORY ................. = ${CMAKE_HOME_DIRECTORY}")
      MESSAGE(STATUS "CMAKE_VERSION ........................ = ${CMAKE_VERSION}")
      MESSAGE(STATUS "CMAKE_GENERATOR ...................... = ${CMAKE_GENERATOR}")
      MESSAGE(STATUS "CMAKE_MODULE_PATH .................... = ${CMAKE_MODULE_PATH}")
      MESSAGE(STATUS "CMAKE_HOST_SYSTEM .................... = ${CMAKE_HOST_SYSTEM}")
      MESSAGE(STATUS "CMAKE_HOST_SYSTEM_VERSION ............ = ${CMAKE_HOST_SYSTEM_VERSION}")
      MESSAGE(STATUS "CMAKE_HOST_SYSTEM_NAME ............... = ${CMAKE_HOST_SYSTEM_NAME}")
      MESSAGE(STATUS "CMAKE_HOST_SYSTEM_PROCESSOR .......... = ${CMAKE_HOST_SYSTEM_PROCESSOR}")
      MESSAGE(STATUS "CMAKE_HOST_UNIX ...................... = ${CMAKE_HOST_UNIX}")
      MESSAGE(STATUS "CMAKE_BUILD_TYPE ..................... = ${CMAKE_BUILD_TYPE}")
      MESSAGE(STATUS "CMAKE_C_COMPILER ..................... = ${CMAKE_C_COMPILER}")
      MESSAGE(STATUS "CMAKE_CXX_COMPILER ................... = ${CMAKE_CXX_COMPILER}")
      MESSAGE(STATUS "CMAKE_CXX_FLAGS ...................... = ${CMAKE_CXX_FLAGS}")
      MESSAGE(STATUS "CMAKE_CURRENT_SOURCE_DIR ............. = ${CMAKE_CURRENT_SOURCE_DIR}")
      MESSAGE(STATUS "CMAKE_CURRENT_BINARY_DIR ............. = ${CMAKE_CURRENT_BINARY_DIR}")
      MESSAGE(STATUS "CMAKE_LIBRARY_PATH ................... = ${CMAKE_LIBRARY_PATH}")
      MESSAGE(STATUS "BOOST_INCLUDE_DIR..................... = ${Boost_INCLUDE_DIR}" )          
ENDIF()

IF( NOT  APPLE )
    ADD_EXECUTABLE( ${BinName} ${TARGET_CPP_FILES} ${TARGET_H_FILES} ${QtIcon_RCC_SRCS} )

    ReadProjectRevisionStatus()

    QT5_USE_MODULES( ${BinName} Widgets OpenGL Network Xml WebKit WebKitWidgets )

    TARGET_LINK_LIBRARIES( ${BinName} ${VTK_LIBRARIES} z  )
ENDIF()


IF( APPLE )
    SET( MACOSX_RESOURCE_FILES ${CMAKE_SOURCE_DIR}/icons/brainGL.icns )
    SET_SOURCE_FILES_PROPERTIES( ${CMAKE_SOURCE_DIR}/icons/brainGL.icns
                               PROPERTIES MACOSX_PACKAGE_LOCATION Resources )

    # XXX merge with definition above
    ADD_EXECUTABLE( ${BinName} MACOSX_BUNDLE ${TARGET_CPP_FILES} ${TARGET_H_FILES} ${FNAV_HEADERS_MOC} ${QtIcon_RCC_SRCS} ${MACOSX_RESOURCE_FILES} )

    # XXX ditto
    ReadProjectRevisionStatus()

    SET( MACOSX_BUNDLE_INFO_STRING "${PROJECT_NAME} - Version ${__HGTIP__}" )
    # XXX value should be formed like 1.2.3
    SET( MACOSX_BUNDLE_BUNDLE_VERSION ${__HGTIP__} )
    SET( MACOSX_BUNDLE_ICON_FILE "brainGL.icns" )
    SET( MACOSX_BUNDLE_GUI_IDENTIFIER "de.braingl" )
    SET( MACOSX_BUNDLE_BUNDLE_NAME "${PROJECT_NAME}" )
    
    QT5_USE_MODULES( ${BinName} Widgets OpenGL Network Xml WebKit WebKitWidgets )
    TARGET_LINK_LIBRARIES( ${BinName} ${OPENGL_LIBRARY} ${VTK_LIBRARIES} "-framework Foundation" "-framework Cocoa" z)

    # create self-contained application bundle with embedded Frameworks and dylibs
    SET( BUNDLED_DIR ${CMAKE_CURRENT_BINARY_DIR}/selfcontained )

    # path to macdeployqt
    GET_FILENAME_COMPONENT( MACDEPLOYQT_DIR ${QT_MOC_EXECUTABLE} DIRECTORY CACHE )

    INSTALL( CODE "
      INCLUDE( BundleUtilities )

      # prepare a clean copy of the bundle
      FILE( REMOVE_RECURSE ${BUNDLED_DIR} )
      FILE( COPY ${CMAKE_CURRENT_BINARY_DIR}/${BinName}.app DESTINATION ${BUNDLED_DIR} )

      # let macdeployqt handle Qt frameworks and plugins, qt.conf
      MESSAGE( \"Running macdeployqt (${MACDEPLOYQT_DIR}/macdeployqt) on ${BUNDLED_DIR}/${BinName}.app.\" )
      EXECUTE_PROCESS( 
        COMMAND ${MACDEPLOYQT_DIR}/macdeployqt ${BUNDLED_DIR}/${BinName}.app 
        RESULT_VARIABLE result
        ERROR_VARIABLE errorstr
      )
      IF(result)
        MESSAGE(FATAL_ERROR \"Error (\${result}) running ${MACDEPLOYQT_DIR}/macdeployqt: \${errstr}\")
      ENDIF(result)

      # fixup remaining non-Qt dependencies (MacPorts) 
      # XXX Qt plugins as LIBS arg?
      MESSAGE( \"Running FIXUP_BUNDLE on ${BUNDLED_DIR}/${BinName}.app.\" )
      FIXUP_BUNDLE( ${BUNDLED_DIR}/${BinName}.app \"\" \"\" )
 
      MESSAGE( \"Verifying application bundle.\" )
      VERIFY_APP( ${BUNDLED_DIR}/${BinName}.app )
   ")
 
    # create distribution disk image (build target: package)
    SET( CPACK_GENERATOR "DragNDrop" )
    SET( CPACK_INSTALLED_DIRECTORIES ${BUNDLED_DIR} . )
    SET( CPACK_PACKAGE_VENDOR "de.braingl" )
    # replace colon from filename; XXX filename is now unambiguous, but user-unfriendly
    STRING( REPLACE ":" "-" CPACK_PACKAGE_VERSION "${__HGTIP__}" )
    # XXX on some Macs the Finder takes a very long time to show the contents of the dmg
    #SET( CPACK_PACKAGE_ICON ${CMAKE_SOURCE_DIR}/icons/brainGL.icns )
    #SET( CPACK_DMG_BACKGROUND_IMAGE ${CMAKE_SOURCE_DIR}/icons/brainGL.icns )
    INCLUDE( CPack )

ENDIF()
