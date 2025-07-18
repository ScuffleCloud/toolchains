project(openssl)

if(WIN32)
    set(OPENSSL_CONFIG VC-WIN64A)
elseif(APPLE AND CMAKE_SYSTEM_PROCESSOR STREQUAL "arm64")
    set(OPENSSL_CONFIG darwin64-arm64-cc)
elseif(APPLE AND CMAKE_SYSTEM_PROCESSOR STREQUAL "x86_64")
    set(OPENSSL_CONFIG darwin64-x86_64-cc)
elseif(UNIX AND CMAKE_SYSTEM_PROCESSOR MATCHES "aarch64" OR CMAKE_SYSTEM_PROCESSOR MATCHES "arm64")
    set(OPENSSL_CONFIG linux-aarch64)
elseif(UNIX AND CMAKE_SYSTEM_PROCESSOR STREQUAL "x86_64")
    set(OPENSSL_CONFIG linux-x86_64)
else()
    message(FATAL_ERROR "Unsupported platform: ${CMAKE_SYSTEM_NAME}")
endif()

if(WIN32)
    if(JOM_BIN_NOTFOUND)
        set(OPENSSL_MAKE_BIN ${NMAKE_BIN})
    else()
        set(OPENSSL_MAKE_BIN ${JOM_BIN})
        set(MAKE_ARGS /J $ENV{CMAKE_BUILD_PARALLEL_LEVEL})
        set(CONFIGURE_ARGS /FS /O2 /Ob2 /DNDEBUG)
    endif()

    set(ZLIB_LIB $<TARGET_PROPERTY:zlib,LIBRARY_DIRECTORY>/zlib.lib)
else()
    set(MAKE_ARGS -j$ENV{CMAKE_BUILD_PARALLEL_LEVEL})
    set(OPENSSL_MAKE_BIN ${MAKE_BIN})

    set(ZLIB_LIB $<TARGET_PROPERTY:zlib,LIBRARY_DIRECTORY>)
    set(CONFIGURE_ARGS -fPIC -O3)
endif()

add_external_target(openssl
    GIT_REPOSITORY https://github.com/openssl/openssl.git
    GIT_TAG 0c6656a7a31492ddd61e3d0d8b0e66645f4b2d6f # v3.5.0-beta1
    CONFIGURE_COMMAND ${PERL_BIN} 
        <SOURCE_DIR>/Configure ${OPENSSL_CONFIG}
            --prefix=<INSTALL_DIR>
            --openssldir=<INSTALL_DIR>/ssl
            no-shared
            no-docs
            no-tests
            zlib
            --with-zlib-include=$<TARGET_PROPERTY:zlib,INCLUDE_DIRECTORY>
            --with-zlib-lib=${ZLIB_LIB}
            ${CONFIGURE_ARGS}
    BUILD_COMMAND ${OPENSSL_MAKE_BIN} ${MAKE_ARGS}
    INSTALL_COMMAND ${OPENSSL_MAKE_BIN} install
    DEPENDS zlib
)

set_target_properties(openssl PROPERTIES
    PKG_CONFIG_PATH ${openssl_INSTALL_DIR}/lib64/pkgconfig
    INCLUDE_DIRECTORY ${openssl_INSTALL_DIR}/include
    LIBRARY_DIRECTORY ${openssl_INSTALL_DIR}/lib64
    CMAKE_PREFIX_PATH ${openssl_INSTALL_DIR}
)
