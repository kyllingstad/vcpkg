# Common Ambient Variables:
#   CURRENT_BUILDTREES_DIR    = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR      = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#   CURRENT_PORT_DIR          = ${VCPKG_ROOT_DIR}\ports\${PORT}
#   PORT                      = current port name (zlib, etc)
#   TARGET_TRIPLET            = current triplet (x86-windows, x64-windows-static, etc)
#   VCPKG_CRT_LINKAGE         = C runtime linkage type (static, dynamic)
#   VCPKG_LIBRARY_LINKAGE     = target library linkage type (static, dynamic)
#   VCPKG_ROOT_DIR            = <C:\path\to\current\vcpkg>
#   VCPKG_TARGET_ARCHITECTURE = target architecture (x64, x86, arm)
#

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/FMILibrary-master)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/svn2github/FMILibrary/archive/master.zip"
    FILENAME "master.zip"
    SHA512 e566bc2f8877bc1e188fcba952764ba73bdbeea2a89dc3b89ea958720b68b84861bd01e055e00b6b951793f041d6bb58d78cb11afee09472a29dcbff7a60cbbb
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH "${SOURCE_PATH}"
    PATCHES
        "${CMAKE_CURRENT_LIST_DIR}/build-static-c99snprintf.patch"
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_DYNAMIC)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DFMILIB_BUILD_SHARED_LIB=${BUILD_DYNAMIC}
        -DFMILIB_BUILD_STATIC_LIB=${BUILD_STATIC}
        -DFMILIB_BUILD_TESTS=OFF
        -DFMILIB_BUILD_WITH_STATIC_RTLIB=${BUILD_STATIC}
    OPTIONS_RELEASE
        "-DFMILIB_INSTALL_PREFIX=${CURRENT_PACKAGES_DIR}"
    OPTIONS_DEBUG
        "-DFMILIB_INSTALL_PREFIX=${CURRENT_PACKAGES_DIR}/debug"
)

vcpkg_install_cmake()
if(WIN32 AND BUILD_DYNAMIC)
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
    file(RENAME "${CURRENT_PACKAGES_DIR}/lib/fmilib_shared.dll" "${CURRENT_PACKAGES_DIR}/bin/fmilib_shared.dll")
    file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/fmilib_shared.dll" "${CURRENT_PACKAGES_DIR}/debug/bin/fmilib_shared.dll")
endif()
file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/doc"
    "${CURRENT_PACKAGES_DIR}/doc"
)
file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/fmi-library" RENAME "copyright")

vcpkg_copy_pdbs()
