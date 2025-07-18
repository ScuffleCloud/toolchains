project(libfdk-aac)

add_external_target(libfdk-aac
  GIT_REPOSITORY https://github.com/mstorsjo/fdk-aac.git
  GIT_TAG 716f4394641d53f0d79c9ddac3fa93b03a49f278 # v2.0.3
  CONFIGURE_COMMAND ${CMAKE_COMMAND}
    -G${CMAKE_GENERATOR}
    -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
    -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
    -DCMAKE_INSTALL_LIBDIR=lib
    -DCMAKE_INSTALL_BINDIR=bin
    -DCMAKE_INSTALL_INCLUDEDIR=include
    -DCMAKE_INSTALL_SHAREDIR=share
    -DBUILD_SHARED_LIBS=OFF
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5
    <SOURCE_DIR>
  BUILD_COMMAND ${CMAKE_COMMAND} --build . --config ${CMAKE_BUILD_TYPE}
  INSTALL_COMMAND ${CMAKE_COMMAND} --install .
)

set_target_properties(libfdk-aac PROPERTIES
  LIBRARY_DIRECTORY ${libfdk-aac_INSTALL_DIR}/lib
  INCLUDE_DIRECTORY ${libfdk-aac_INSTALL_DIR}/include
  PKG_CONFIG_PATH ${libfdk-aac_INSTALL_DIR}/lib/pkgconfig
  CMAKE_PREFIX_PATH ${libfdk-aac_INSTALL_DIR}
  LIBRARY_FILE ${libfdk-aac_INSTALL_DIR}/lib/libfdk-aac${STATIC_LIBRARY_EXTENSION}
)
