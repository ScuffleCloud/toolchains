project(libbrotli)

add_external_target(libbrotli
  GIT_REPOSITORY https://github.com/google/brotli.git
  GIT_TAG ed738e842d2fbdf2d6459e39267a633c4a9b2f5d
  CONFIGURE_COMMAND ${CMAKE_COMMAND}
    -G${CMAKE_GENERATOR}
    -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
    -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
    -DCMAKE_INSTALL_LIBDIR=lib
    -DCMAKE_INSTALL_BINDIR=bin
    -DCMAKE_INSTALL_INCLUDEDIR=include
    -DCMAKE_INSTALL_SHAREDIR=share
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON
    -DBUILD_SHARED_LIBS=OFF
    -DBUILD_TESTING=OFF
    -DBUILD_EXAMPLES=OFF
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5
    <SOURCE_DIR>
  BUILD_COMMAND ${CMAKE_COMMAND} --build . --config ${CMAKE_BUILD_TYPE}
  INSTALL_COMMAND ${CMAKE_COMMAND} --install .
)

if(WIN32)
  set(lib_prefix "")
else()
  set(lib_prefix "lib")
endif()

set_target_properties(libbrotli PROPERTIES
  LIBRARY_DIRECTORY ${libbrotli_INSTALL_DIR}/lib
  INCLUDE_DIRECTORY ${libbrotli_INSTALL_DIR}/include
  PKG_CONFIG_PATH ${libbrotli_INSTALL_DIR}/lib/pkgconfig
  DECODE_LIBRARY_FILE ${libbrotli_INSTALL_DIR}/lib/${lib_prefix}brotlidec${STATIC_LIBRARY_EXTENSION}
  ENCODE_LIBRARY_FILE ${libbrotli_INSTALL_DIR}/lib/${lib_prefix}brotlienc${STATIC_LIBRARY_EXTENSION}
  COMMON_LIBRARY_FILE ${libbrotli_INSTALL_DIR}/lib/${lib_prefix}brotlicommon${STATIC_LIBRARY_EXTENSION}
)
