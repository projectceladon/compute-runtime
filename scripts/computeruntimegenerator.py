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

        self.allmoduleinfo[1] = ModuleInfo("libneo_shared", "libneo_shared.bp",
            "shared/source/CMakeFiles/neo_shared.dir/", "library_static", "compute-runtime-defaults",
            updateflags = {"-Wclobbered" : "", "-Werror" : "", "-mindirect-branch-register" : "", "-Wimplicit-fallthrough=4" : "", "-Wno-noexcept-type" : "", 
            "-Wno-unused-but-set-variable" : "", },
            )

        self.allmoduleinfo[2] = ModuleInfo("libigdrcl_lib_release", "libigdrcl_lib_release.bp",
            "igdrcl_lib_release/CMakeFiles/igdrcl_lib_release.dir/", "library_static", "compute-runtime-defaults",
            updateflags = {"-Wclobbered" : "", "-Werror" : "", "-mindirect-branch-register" : "", "-Wimplicit-fallthrough=4" : "", "-Wno-noexcept-type" : "", 
            "-Wno-unused-but-set-variable" : "", },
            )

        self.allmoduleinfo[3] = ModuleInfo("libigdrcl", "libigdrcl.bp", "igdrcl_lib_release/CMakeFiles/igdrcl_dll.dir/",
            "library_shared", "compute-runtime-defaults", 
            updateflags = {"-Wclobbered" : "", "-Werror" : "", "-mindirect-branch-register" : "", "-Wimplicit-fallthrough=4" : "", "-Wno-noexcept-type" : "", 
            "-Wno-unused-but-set-variable" : "", },
            )

        self.allmoduleinfo[4] = ModuleInfo("ocloc_lib", "ocloc_lib.bp", "offline_compiler/source/CMakeFiles/ocloc_lib.dir/",
            "library_static", "compute-runtime-defaults", 
            updateflags = {"-Wclobbered" : "", "-Werror" : "", "-mindirect-branch-register" : "", "-Wimplicit-fallthrough=4" : "", "-Wno-noexcept-type" : "", 
            "-Wno-unused-but-set-variable" : "", },
            )

        self.allmoduleinfo[5] = ModuleInfo("ocloc", "ocloc.bp", "offline_compiler/source/CMakeFiles/ocloc.dir/",
            "binary", "compute-runtime-defaults", 
            updateflags = {"-Wclobbered" : "", "-Werror" : "", "-mindirect-branch-register" : "", "-Wimplicit-fallthrough=4" : "", "-Wno-noexcept-type" : "", 
            "-Wno-unused-but-set-variable" : "", },
            )

        self.allmoduledefaults = CCDefaults(self.proj, "compute-runtime-defaults",
            cppflags = ["-Wno-error", "-fexceptions", "-msse4.2", "-mavx2", "-D__AVX2__", "-mretpoline", 
            "-Wshorten-64-to-32", "-Wno-extern-c-compat", "-Wno-instantiation-after-specialization", "-DSANITIZER_BUILD", "-Wno-deprecated-register", "-Wno-deprecated-copy",],
            clang_cflags = ["-Wno-error=non-virtual-dtor"],
            include_dirs = ["hardware/intel/external/libva",
                "hardware/intel/external/media/gmmlib/Source/inc",
                "hardware/intel/external/media/gmmlib/Source/inc/common",
                "hardware/intel/external/media/gmmlib/Source/GmmLib/inc",
                "hardware/intel/external/opencl/intel-graphics-compiler/include/igc",
                "hardware/intel/external/opencl/intel-graphics-compiler/include/igc/cif",
                "hardware/intel/external/opencl/intel-graphics-compiler/include/igc/ocl_igc_shared/executable_format",
                "hardware/intel/external/opencl/intel-graphics-compiler/include/igc/ocl_igc_shared/device_enqueue",
                "hardware/intel/external/opencl/intel-graphics-compiler/include/visa",
                "hardware/intel/external/opencl/compute-runtime/device/include/"
                ],
            shared_libs = ["libgmm_umd",],
            bpfiles = [
                "libigdrcl_lib_release.bp",
                "libneo_shared.bp",
                "libigdrcl.bp",
                "ocloc_lib.bp",
                "ocloc.bp",
            ], )

    def getTemplate(self):
        return "compute-runtime.tpl"

    def adjustSources(self, mode, all_sources):
        for i, l in enumerate(all_sources):
            all_sources[i] = INDENT * 2 + "\"" + re.sub(r".*?: " + self.allmoduleinfo[mode].Mid_Dir, "",
                re.sub("CMakeFiles/.*?\\.dir/", "", l.replace("__/", "../")))
            all_sources[i] = re.sub(r"offline_compiler/source/", r"shared/offline_compiler/source/", all_sources[i])
            all_sources[i] = re.sub(r"shared/source/built_ins/../../../bin/", r"device/", all_sources[i])
            all_sources[i] = re.sub(r"igdrcl_lib_release/../../", r"", all_sources[i])
            all_sources[i] = re.sub(r"igdrcl_lib_release/", r"opencl/source/", all_sources[i])

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
        cmd += "mkdir -p " + path.join(self.proj, "device/built_ins/x64/gen12lp/") + NOVERBOSE
        cmd += "mkdir -p " + path.join(self.proj, "device/built_ins/x64/xe_hpc_core/") + NOVERBOSE
        cmd += "mkdir -p " + path.join(self.proj, "device/built_ins/x64/xe_hpg_core/") + NOVERBOSE
        cmd += "cp -f " + path.join(build_dir, "*.h") + " " + path.join(self.proj, "device/include/") + NOVERBOSE
        cmd += "cp -f " + path.join(build_dir, "bin/built_ins/x64/gen12lp/*.cpp") + " " + path.join(self.proj, "device/built_ins/x64/gen12lp/") + NOVERBOSE
        cmd += "cp -f " + path.join(build_dir, "bin/built_ins/x64/xe_hpc_core/*.cpp") + " " + path.join(self.proj, "device/built_ins/x64/xe_hpc_core/") + NOVERBOSE
        cmd += "cp -f " + path.join(build_dir, "bin/built_ins/x64/xe_hpg_core/*.cpp") + " " + path.join(self.proj, "device/built_ins/x64/xe_hpg_core/") + NOVERBOSE
        os.system(cmd)

class Main:

    def run(self):
        script = path.dirname(__file__)
        root = path.abspath(path.join(script, "../.."))

        print(("script = " + script))
        print(("root = " + root))

        ComputeRuntimeGenerator(root).generate(to_make = False)


if RUN_CALLABLE:
    m = Main()
    m.run()
