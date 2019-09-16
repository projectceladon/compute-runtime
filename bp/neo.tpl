# Copyright(c) 2019 Intel Corporation
# 
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files(the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and / or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
# 
# Intel(R) Graphics Compute Runtime for OpenCL(TM) (https://github.com/intel/compute-runtime) 
# |
# +---- elf 
# |     |
# |     +---- libelflib.a -> Tools/Android/build/neo/elf/CMakeFiles/elflib.dir 
# |
# +---- igdrcl_lib_mockable 
# |     |
# |     +---- libigdrcl_lib_mockable.a -> Tools/Android/build/neo/igdrcl_lib_mockable/CMakeFiles/igdrcl_lib_mockable.dir 
# |     | 
# |     +---- sharings 
# |           |
# |           +---- igdrcl_lib_mockable_sharings_enable.a -> Tools/Android/build/neo/igdrcl_lib_mockable/sharings/CMakeFiles/igdrcl_lib_mockable_sharings_enable.dir 
# |
# +---- igdrcl_lib_release 
# |     |
# |     +---- libigdrcl.so -> Tools/Android/build/neo/igdrcl_lib_release/CMakeFiles/igdrcl_dll.dir 
# |     |
# |     +---- libigdrcl_lib_release.a -> Tools/Android/build/neo/igdrcl_lib_release/CMakeFiles/igdrcl_lib_release.dir 
# |     |
# |     +---- builtin_kernels_simulation
# |     |     |
# |     |     +---- biksim.a -> Tools/Android/build/neo/igdrcl_lib_release/builtin_kernels_simulation/CMakeFiles/biksim.dir 
# |     |
# |     +---- built_ins
# |     |     |
# |     |     +---- builtins_binaries.a -> igdrcl_lib_release/built_ins/CMakeFiles/builtins_binaries.dir 
# |     |     |
# |     |     +---- registry
# |     |           |
# |     |           +---- scheduler_binary.a -> Tools/Android/build/neo/igdrcl_lib_release/built_ins/registry/CMakeFiles/builtins_sources.dir 
# |     |
# |     +---- scheduler 
# |     |     |
# |     |     +---- scheduler_binary.a -> Tools/Android/build/neo/igdrcl_lib_release/scheduler/CMakeFiles/scheduler_binary.dir 
# |     |
# |     +---- sharings 
# |           |
# |           +---- igdrcl_lib_release_sharings_enable.a -> Tools/Android/build/neo/igdrcl_lib_release/sharings/CMakeFiles/igdrcl_lib_release_sharings_enable.dir 
# |
# +---- offline_compiler 
# |     |
# |     +---- ocloc -> Tools/Android/build/neo/offline_compiler/CMakeFiles/ocloc.dir 
# |
# +---- third_party 
# |     |
# |     +---- gtest 
# |           |
# |           +---- libgmock-gtest.a -> Tools/Android/build/neo/third_party/gtest/CMakeFiles/gmock-gtest.dir 
# |
# +---- unit_tests 
#       |
#       +---- igdrcl_tests -> Tools/Android/build/neo/unit_tests/CMakeFiles/igdrcl_tests.dir 
#       |
#       +---- aub_tests 
#       |     |
#       |     +---- igdrcl_aub_tests -> Tools/Android/build/neo/unit_tests/aub_tests/CMakeFiles/igdrcl_aub_tests.dir 
#       |
#       +---- elflib 
#       |     |
#       |     +---- elflib_tests -> Tools/Android/build/neo/unit_tests/elflib/CMakeFiles/elflib_tests.dir 
#       |
#       +---- libult 
#       |     |
#       |     +---- igdrcl_libult_cs.a -> Tools/Android/build/neo/unit_tests/libult/CMakeFiles/igdrcl_libult_cs.dir 
#       |     |
#       |     +---- igdrcl_libult_env -> Tools/Android/build/neo/unit_tests/libult/CMakeFiles/igdrcl_libult_env.dir 
#       |     |
#       |     +---- igdrcl_libult.a -> Tools/Android/build/neo/unit_tests/libult/CMakeFiles/igdrcl_libult.dir 
#       |
#       +---- linux 
#       |     |
#       |     +---- igdrcl_linux_dll_tests -> Tools/Android/build/neo/unit_tests/linux/CMakeFiles/igdrcl_linux_dll_tests.dir 
#       |     |
#       |     +---- igdrcl_linux_tests -> Tools/Android/build/neo/unit_tests/linux/CMakeFiles/igdrcl_linux_tests.dir
#       |
#       +---- libmock_gmm.so -> Tools/Android/build/neo/unit_tests/mock_gmm/CMakeFiles/mock_gmm.dir 
#       |
#       +---- mocks 
#       |     |
#       |     +---- libigdrcl_mocks.a -> Tools/Android/build/neo/unit_tests/mocks/CMakeFiles/igdrcl_mocks.dir 
#       |
#       +---- mt_tests 
#       |     |
#       |     +---- igdrcl_mt_tests -> Tools/Android/build/neo/unit_tests/mt_tests/CMakeFiles/igdrcl_mt_tests.dir 
#       |
#       +---- offline_compiler 
#       |     |
#       |     +---- ocloc_tests -> Tools/Android/build/neo/unit_tests/offline_compiler/CMakeFiles/ocloc_tests.dir 
#       |     |
#       |     +---- segfault_test
#       |           |
#       |           +---- ocloc_segfault_test -> Tools/Android/build/neo/unit_tests/offline_compiler/segfault_test/CMakeFiles/ocloc_segfault_test.dir  
#       |
#       +---- tbx 
#       |     |
#       |     +---- igdrcl_tbx_tests -> Tools/Android/build/neo/unit_tests/tbx/CMakeFiles/igdrcl_tbx_tests.dir
#       |
#       +---- libtest_dynamic_lib.so -> Tools/Android/build/neo/unit_tests/test_dynamic_lib/CMakeFiles/test_dynamic_lib.dir
# 
# library_static, library_shared, binary 
cc_@module {
    name: "@name",

    vendor_available: true,

    defaults: [
@defaults
    ],

    srcs: [
@srcs
    ],

    cflags: [
@cflags
    ],

    cppflags: [
@cppflags
    ],

    local_include_dirs: [
@local_include_dirs
    ],

    shared_libs: [
@shared_libs
    ],

    static_libs: [
@static_libs
    ],

}