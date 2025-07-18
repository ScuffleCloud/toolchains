project(libfreetype)

include(ExternalProject)

add_external_target(
  libfreetype
  GIT_REPOSITORY https://github.com/freetype/freetype.git
  GIT_TAG 42608f77f20749dd6ddc9e0536788eaad70ea4b5 # v2.13.3
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
    -DFT_REQUIRE_ZLIB=ON
    -DFT_REQUIRE_PNG=ON
    -DFT_REQUIRE_BROTLI=ON
    -DFT_DISABLE_BZIP2=ON
    -DFT_DISABLE_HARFBUZZ=ON
    -DZLIB_INCLUDE_DIR=$<TARGET_PROPERTY:zlib,INCLUDE_DIRECTORY>
    -DZLIB_LIBRARY=$<TARGET_PROPERTY:zlib,LIBRARY_FILE>
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5
    <SOURCE_DIR>
  BUILD_COMMAND ${CMAKE_COMMAND} --build . --config ${CMAKE_BUILD_TYPE}
  INSTALL_COMMAND ${CMAKE_COMMAND} --install .
  DEPENDS zlib libpng libbrotli
)

set_target_properties(libfreetype PROPERTIES
  LIBRARY_DIRECTORY ${libfreetype_INSTALL_DIR}/lib
  INCLUDE_DIRECTORY ${libfreetype_INSTALL_DIR}/include
  PKG_CONFIG_PATH ${libfreetype_INSTALL_DIR}/lib/pkgconfig
  CMAKE_PREFIX_PATH ${libfreetype_INSTALL_DIR}
  LIBRARY_FILE ${libfreetype_INSTALL_DIR}/lib/libfreetype${STATIC_LIBRARY_EXTENSION}
)

# On windows this library does not link the dependencies automatically
# So we need to manually add the library paths and link the libraries
if(WIN32)
  set_target_properties(libfreetype PROPERTIES
    LDFLAGS "-L$<TARGET_PROPERTY:libpng,LIBRARY_DIRECTORY> -llibpng16_static -L$<TARGET_PROPERTY:libbrotli,LIBRARY_DIRECTORY> -lbrotlidec -lbrotlicommon -L$<TARGET_PROPERTY:zlib,LIBRARY_DIRECTORY> -L$<TARGET_PROPERTY:zlib,LIBRARY_DIRECTORY> -lzlib"
  )
endif()
