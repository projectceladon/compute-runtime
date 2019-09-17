#! /usr/bin/env python3
"""
* Copyright (c) 2019, Intel Corporation
*
* Permission is hereby granted, free of charge, to any person obtaining a
* copy of this software and associated documentation files (the "Software"),
* to deal in the Software without restriction, including without limitation
* the rights to use, copy, modify, merge, publish, distribute, sublicense,
* and/or sell copies of the Software, and to permit persons to whom the
* Software is furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included
* in all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
* OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
* OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
* ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
* OTHER DEALINGS IN THE SOFTWARE.
"""

import os
import os.path as path
import re
from androidbpgenerator import INDENT, CCDefaults, ModuleInfo, Generator, NOVERBOSE

RUN_CALLABLE = True


class ComputeRuntimeGenerator(Generator):
    def __init__(self, root):
        self.proj = path.join(root, "compute-runtime/")
        super(ComputeRuntimeGenerator, self).__init__(self.proj, root)
        self.root = root

        # the reason why add or update some flags: https://wiki.ith.intel.com/display/GSE/Android+OpenCL+Driver+Porting+Problem+Fix
        self.allmoduleinfo[0] = ModuleInfo("libelflib", "libelflib.bp", "elf/CMakeFiles/elflib.dir/", 
            "library_static", "compute-runtime-defaults", updateflags = {"-Wclobbered" : "", "-Werror" : ""}, )
        self.allmoduleinfo[1] = ModuleInfo("libigdrcl_lib_mockable", "libigdrcl_lib_mockable.bp",
            "igdrcl_lib_mockable/CMakeFiles/igdrcl_lib_mockable.dir/", "library_static", "compute-runtime-defaults",
            updateflags = {"-Wclobbered" : "", "-Werror" : ""}, addflags = ["-DDEFAULT_GEN10_PLATFORM=CNL", 
            "-DDEFAULT_GEN8_PLATFORM=BDW", "-DDEFAULT_GEN9_PLATFORM=SKL", "-D__AVX2__", "-mavx2"], )
        self.allmoduleinfo[2] = ModuleInfo("igdrcl_lib_mockable_sharings_enable", "igdrcl_lib_mockable_sharings_enable.bp",
            "igdrcl_lib_mockable/sharings/CMakeFiles/igdrcl_lib_mockable_sharings_enable.dir/", 
            "library_static", "compute-runtime-defaults", updateflags = {"-Wclobbered" : "", "-Werror" : ""}, )
        self.allmoduleinfo[3] = ModuleInfo("libigdrcl_lib_release", "libigdrcl_lib_release.bp",
            "igdrcl_lib_release/CMakeFiles/igdrcl_lib_release.dir/", "library_static", "compute-runtime-defaults",
            updateflags = {"-Wclobbered" : "", "-Werror" : ""}, addflags = ["-DDEFAULT_GEN10_PLATFORM=CNL", 
            "-DDEFAULT_GEN8_PLATFORM=BDW", "-DDEFAULT_GEN9_PLATFORM=SKL", "-D__AVX2__", "-mavx2"], )
        self.allmoduleinfo[4] = ModuleInfo("igdrcl_lib_release_sharings_enable", "igdrcl_lib_release_sharings_enable.bp",
            "igdrcl_lib_release/sharings/CMakeFiles/igdrcl_lib_release_sharings_enable.dir/", 
            "library_static", "compute-runtime-defaults", updateflags = {"-Wclobbered" : "", "-Werror" : ""}, )
        self.allmoduleinfo[5] = ModuleInfo("libigdrcl", "libigdrcl.bp", "igdrcl_lib_release/CMakeFiles/igdrcl_dll.dir/",
            "library_shared", "compute-runtime-defaults", updateflags = {"-Wclobbered" : "", "-Werror" : ""}, )
        self.allmoduleinfo[6] = ModuleInfo("libgmock-gtest", "libgmock-gtest.bp", "third_party/gtest/CMakeFiles/gmock-gtest.dir/", 
            "library_static", "compute-runtime-defaults", )
        self.allmoduleinfo[7] = ModuleInfo("ocloc", "ocloc.bp", "offline_compiler/CMakeFiles/ocloc.dir/",
            "binary", "compute-runtime-defaults", updateflags = {"-Wclobbered" : "", "-Werror" : ""}, )
#        self.allmoduleinfo[8] = ModuleInfo("igdrcl_tests", "igdrcl_tests.bp", "unit_tests/CMakeFiles/igdrcl_tests.dir/",
#            "binary", "compute-runtime-defaults", updateflags = {"-Wclobbered" : "", "-Werror" : ""}, 
#            addflags = ["-D_FORTIFY_SOURCE=0"], )
        self.allmoduleinfo[9] = ModuleInfo("igdrcl_aub_tests", "igdrcl_aub_tests.bp",
            "unit_tests/aub_tests/CMakeFiles/igdrcl_aub_tests.dir/", "binary", "compute-runtime-defaults",
            updateflags = {"-Wclobbered" : "", "-Werror" : ""}, )
        self.allmoduleinfo[10] = ModuleInfo("elflib_tests", "elflib_tests.bp",
            "unit_tests/elflib/CMakeFiles/elflib_tests.dir/", "binary", "compute-runtime-defaults",
            updateflags = {"-Wclobbered" : "", "-Werror" : ""}, )
        self.allmoduleinfo[11] = ModuleInfo("igdrcl_libult_cs", "igdrcl_libult_cs.bp",
            "unit_tests/libult/CMakeFiles/igdrcl_libult_cs.dir/", "library_static", "compute-runtime-defaults",
            updateflags = {"-Wclobbered" : "", "-Werror" : ""}, )
#        self.allmoduleinfo[12] = ModuleInfo("igdrcl_libult_env", "igdrcl_libult_env.bp",
#            "unit_tests/libult/CMakeFiles/igdrcl_libult_env.dir/", "binary", "compute-runtime-defaults",
#            updateflags = {"-Wclobbered" : "", "-Werror" : ""}, )
        self.allmoduleinfo[13] = ModuleInfo("igdrcl_libult", "igdrcl_libult.bp",
            "unit_tests/libult/CMakeFiles/igdrcl_libult.dir/", "library_static", "compute-runtime-defaults",
            updateflags = {"-Wclobbered" : "", "-Werror" : ""}, )
#        self.allmoduleinfo[14] = ModuleInfo("igdrcl_linux_dll_tests", "igdrcl_linux_dll_tests.bp",
#            "unit_tests/linux/CMakeFiles/igdrcl_linux_dll_tests.dir/", "binary", "compute-runtime-defaults",
#            updateflags = {"-Wclobbered" : "", "-Werror" : ""}, )
        self.allmoduleinfo[15] = ModuleInfo("igdrcl_linux_tests", "igdrcl_linux_tests.bp",
            "unit_tests/linux/CMakeFiles/igdrcl_linux_tests.dir/", "binary", "compute-runtime-defaults",
            updateflags = {"-Wclobbered" : "", "-Werror" : ""}, )
        self.allmoduleinfo[16] = ModuleInfo("libmock_gmm", "libmock_gmm.bp",
            "unit_tests/mock_gmm/CMakeFiles/mock_gmm.dir/", "library_shared", "compute-runtime-defaults",
            updateflags = {"-Wclobbered" : "", "-Werror" : ""}, )
        self.allmoduleinfo[17] = ModuleInfo("libigdrcl_mocks", "libigdrcl_mocks.bp",
            "unit_tests/mocks/CMakeFiles/igdrcl_mocks.dir/", "library_static", "compute-runtime-defaults",
            updateflags = {"-Wclobbered" : "", "-Werror" : ""}, )
        self.allmoduleinfo[18] = ModuleInfo("igdrcl_mt_tests", "igdrcl_mt_tests.bp",
            "unit_tests/mt_tests/CMakeFiles/igdrcl_mt_tests.dir/", "binary", "compute-runtime-defaults",
            updateflags = {"-Wclobbered" : "", "-Werror" : ""}, )
        self.allmoduleinfo[19] = ModuleInfo("ocloc_tests", "ocloc_tests.bp",
            "unit_tests/offline_compiler/CMakeFiles/ocloc_tests.dir/", "binary", "compute-runtime-defaults",
            updateflags = {"-Wclobbered" : "", "-Werror" : ""}, )
        self.allmoduleinfo[20] = ModuleInfo("ocloc_segfault_test", "ocloc_segfault_test.bp",
            "unit_tests/offline_compiler/segfault_test/CMakeFiles/ocloc_segfault_test.dir/",
            "binary", "compute-runtime-defaults", updateflags = {"-Wclobbered" : "", "-Werror" : ""}, )
        self.allmoduleinfo[21] = ModuleInfo("igdrcl_tbx_tests", "igdrcl_tbx_tests.bp",
            "unit_tests/tbx/CMakeFiles/igdrcl_tbx_tests.dir/", "binary", "compute-runtime-defaults",
            updateflags = {"-Wclobbered" : "", "-Werror" : ""}, )
        self.allmoduleinfo[22] = ModuleInfo("libtest_dynamic_lib", "libtest_dynamic_lib.bp",
            "unit_tests/test_dynamic_lib/CMakeFiles/test_dynamic_lib.dir/", "library_shared",
            "compute-runtime-defaults", updateflags = {"-Wclobbered" : "", "-Werror" : ""}, )

        self.allmoduledefaults = CCDefaults(self.proj, "compute-runtime-defaults",
            cppflags = ["-Wno-error", "-fexceptions", "-fno-strict-aliasing", "-msse", "-msse2", "-msse3",
                "-mssse3", "-msse4", "-msse4.1", "-msse4.2", "-DBIONIC_IOCTL_NO_SIGNEDNESS_OVERLOAD"],
            clang_cflags = ["-Wno-error=non-virtual-dtor"],
            include_dirs = ["hardware/intel/external/libva",
                "hardware/intel/external/media/gmmlib/Source/inc",
                "hardware/intel/external/media/gmmlib/Source/inc/common",
                "hardware/intel/external/media/gmmlib/Source/GmmLib/inc",
                "hardware/intel/external/opencl/intel-graphics-compiler/include/IGC",
                "hardware/intel/external/opencl/intel-graphics-compiler/include/IGC/AdaptorOCL",
                "hardware/intel/external/opencl/intel-graphics-compiler/include/IGC/AdaptorOCL/cif",
                "hardware/intel/external/opencl/intel-graphics-compiler/include/IGC/AdaptorOCL/ocl_igc_shared",
                "hardware/intel/external/opencl/intel-graphics-compiler/include/IGC/AdaptorOCL/ocl_igc_shared/device_enqueue",
                "hardware/intel/external/opencl/intel-graphics-compiler/include/IGC/AdaptorOCL/ocl_igc_shared/executable_format",
                "hardware/intel/external/opencl/compute-runtime/device/include",
                "hardware/intel/external/opencl/compute-runtime/third_party",
                "hardware/intel/external/opencl/compute-runtime/third_party/gtest",
                "hardware/intel/external/opencl/compute-runtime/third_party/opencl_headers",
                "hardware/intel/external/opencl/compute-runtime/third_party/opengl_headers",
                "hardware/intel/external/opencl/compute-runtime/third_party/source_level_debugger",
                "hardware/intel/external/opencl/compute-runtime/third_party/uapi",
                "hardware/intel/external/opencl/compute-runtime/runtime/sku_info/definitions",
                "hardware/intel/external/opencl/compute-runtime/runtime/os_interface/definitions",
                "hardware/intel/external/opencl/compute-runtime/runtime/os_interface/linux",
                "hardware/intel/external/opencl/compute-runtime/runtime/command_stream/definitions",
                "hardware/intel/external/opencl/compute-runtime/runtime/gen_common",
                "hardware/intel/external/opencl/compute-runtime/runtime/gen_common/reg_configs",
                "hardware/intel/external/opencl/compute-runtime/runtime/gmm_helper",
                "hardware/intel/external/opencl/compute-runtime/runtime/gmm_helper/client_context",
                "hardware/intel/external/opencl/compute-runtime/runtime/gmm_helper/gmm_memory",
                "hardware/intel/external/opencl/compute-runtime/runtime/mem_obj/definitions",
                "hardware/intel/external/opencl/compute-runtime/runtime/memory_manager/definitions",
                "hardware/intel/external/opencl/compute-runtime/runtime/instrumentation",
                "hardware/intel/external/opencl/compute-runtime/runtime/dll/linux/devices",
                "hardware/intel/external/opencl/compute-runtime/unit_tests/mocks",],
            bpfiles = ["libelflib.bp", "libigdrcl_lib_mockable.bp", "igdrcl_lib_mockable_sharings_enable.bp",
                "libigdrcl_lib_release.bp", "igdrcl_lib_release_sharings_enable.bp", "libigdrcl.bp",
                "libgmock-gtest.bp", "ocloc.bp", "igdrcl_aub_tests.bp", "elflib_tests.bp",
                "igdrcl_linux_tests.bp", "libmock_gmm.bp", "libigdrcl_mocks.bp", "igdrcl_mt_tests.bp",
                "ocloc_tests.bp", "ocloc_segfault_test.bp", "igdrcl_tbx_tests.bp", "libtest_dynamic_lib.bp",
                "igdrcl_libult_cs.bp", "igdrcl_libult.bp", 
#                "igdrcl_linux_dll_tests.bp", "igdrcl_libult_env.bp", "igdrcl_tests.bp", 
            ], )

    def getTemplate(self):
        return "compute-runtime.tpl"

    def adjustSources(self, mode, all_sources):
        for i, l in enumerate(all_sources):
            all_sources[i] = INDENT * 2 + "\"" + re.sub(r".*?: " + self.allmoduleinfo[mode].Mid_Dir, "",
                re.sub("CMakeFiles/.*?\\.dir/", "", l.replace("__/", "../")))
            all_sources[i] = re.sub(r"igdrcl_lib_mockable/", r"runtime/", all_sources[i])
            all_sources[i] = re.sub(r"igdrcl_lib_release/", r"runtime/", all_sources[i])
            all_sources[i] = re.sub(r"/bin/", r"/device/", all_sources[i])

    def adjustFlags(self, mode, all_flags, is_add = True):
        update_flags = self.allmoduleinfo[mode].Update_Flags
        add_flags = self.allmoduleinfo[mode].Add_Flags

        for i, f in enumerate(update_flags):
            all_flags = re.sub(INDENT * 2 + "\"" + f + "\",\n", update_flags[f], all_flags)

        if is_add:
            all_flags += "\n"

            for i, f in enumerate(add_flags):
                all_flags += INDENT * 2 + "\"" + f + "\",\n"

        return all_flags

    def adjustFiles(self):
        print("It is adjusting some files for compute-runtime ... ")
        build_dir = self.getBuildDir()
        cmd = "mkdir -p " + path.join(self.proj, "device/include/") + NOVERBOSE
        cmd += "mkdir -p " + path.join(self.proj, "device/built_ins/x64/gen8/") + NOVERBOSE
        cmd += "mkdir -p " + path.join(self.proj, "device/built_ins/x64/gen9/") + NOVERBOSE
        cmd += "mkdir -p " + path.join(self.proj, "device/built_ins/x64/gen10/") + NOVERBOSE
        cmd += "mkdir -p " + path.join(self.proj, "device/Gen9core/") + NOVERBOSE
        cmd += "mkdir -p " + path.join(self.proj, "device/scheduler/x64/gen8/") + NOVERBOSE
        cmd += "mkdir -p " + path.join(self.proj, "device/scheduler/x64/gen9/") + NOVERBOSE
        cmd += "mkdir -p " + path.join(self.proj, "device/scheduler/x64/gen10/") + NOVERBOSE
        cmd += "cp -f " + path.join(build_dir, "*.h") + " " + path.join(self.proj, "device/include/") + NOVERBOSE
        cmd += "cp -f " + path.join(build_dir, "bin/built_ins/x64/gen8/*.cpp") + " " + path.join(self.proj, "device/built_ins/x64/gen8/") + NOVERBOSE
        cmd += "cp -f " + path.join(build_dir, "bin/built_ins/x64/gen9/*.cpp") + " " + path.join(self.proj, "device/built_ins/x64/gen9/") + NOVERBOSE
        cmd += "cp -f " + path.join(build_dir, "bin/built_ins/x64/gen10/*.cpp") + " " + path.join(self.proj, "device/built_ins/x64/gen10/") + NOVERBOSE
        cmd += "cp -f " + path.join(build_dir, "bin/scheduler/x64/gen8/*.cpp") + " " + path.join(self.proj, "device/scheduler/x64/gen8/") + NOVERBOSE
        cmd += "cp -f " + path.join(build_dir, "bin/scheduler/x64/gen9/*.cpp") + " " + path.join(self.proj, "device/scheduler/x64/gen9/") + NOVERBOSE
        cmd += "cp -f " + path.join(build_dir, "bin/scheduler/x64/gen10/*.cpp") + " " + path.join(self.proj, "device/scheduler/x64/gen10/") + NOVERBOSE
        cmd += "cp -f " + path.join(build_dir, "bin/Gen9core/*.cpp") + " " + path.join(self.proj, "device/Gen9core/") + NOVERBOSE
        os.system(cmd)


class Main:

    def run(self):
        script = path.dirname(__file__)
        root = path.abspath(path.join(script, "../.."))

        print("script = " + script)
        print("root = " + root)

        ComputeRuntimeGenerator(root).generate(to_make = True)


if RUN_CALLABLE:
    m = Main()
    m.run()
