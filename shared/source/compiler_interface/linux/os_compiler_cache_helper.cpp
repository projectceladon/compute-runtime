/*
 * Copyright (C) 2023-2024 Intel Corporation
 *
 * SPDX-License-Identifier: MIT
 *
 */

#include "shared/source/compiler_interface/os_compiler_cache_helper.h"

#include "shared/source/helpers/path.h"
#include "shared/source/os_interface/debug_env_reader.h"
#include "shared/source/os_interface/linux/sys_calls.h"
#include "shared/source/utilities/io_functions.h"

#include "os_inc.h"

#include <dlfcn.h>
#include <link.h>

#include <binder/IPCThreadState.h>
#include <cutils/multiuser.h>
#include <string>

using ::android::IPCThreadState;

namespace NEO {
bool createCompilerCachePath(std::string &cacheDir) {
    if (NEO::SysCalls::pathExists(cacheDir)) {
        if (NEO::SysCalls::pathExists(joinPath(cacheDir, "neo_compiler_cache"))) {
            cacheDir = joinPath(cacheDir, "neo_compiler_cache");
            return true;
        }

        if (NEO::SysCalls::mkdir(joinPath(cacheDir, "neo_compiler_cache")) == 0) {
            cacheDir = joinPath(cacheDir, "neo_compiler_cache");
            return true;
        } else {
            if (errno == EEXIST) {
                cacheDir = joinPath(cacheDir, "neo_compiler_cache");
                return true;
            }
        }
    }

    cacheDir = "";
    return false;
}

bool checkDefaultCacheDirSettings(std::string &cacheDir, NEO::EnvironmentVariableReader &reader) {
    std::string emptyString = "";
    cacheDir = reader.getSetting("XDG_CACHE_HOME", emptyString);

    if (cacheDir.empty()) {
#ifdef ANDROID
        cacheDir = "/data/data";
        cacheDir = joinPath(cacheDir, getprogname());
        if (!NEO::SysCalls::pathExists(cacheDir)) {
            NEO::SysCalls::mkdir(cacheDir);
        }

        cacheDir = joinPath(cacheDir, ".cache/");
        if (!NEO::SysCalls::pathExists(cacheDir)) {
            NEO::SysCalls::mkdir(cacheDir);
        }

        // In case /data/data/progname/.cache creation fails, which can happen in case of multiuser or due to service
        //  running in shell due to permission issue, try multiuser path /data/user/userid/progname/.cache
        if (!NEO::SysCalls::pathExists(cacheDir)) {
            PRINT_DEBUG_STRING(NEO::debugManager.flags.PrintDebugMessages.get(), stdout, "unable to create cache in: %s\n\n",
                                cacheDir.c_str());

            cacheDir = "/data/user";

            //get current userid
            IPCThreadState* ipc = IPCThreadState::self();
            const int32_t uid = ipc->getCallingUid();
            userid_t user = multiuser_get_user_id(uid);

            cacheDir = joinPath(cacheDir, (std::to_string(user)).c_str());
            cacheDir = joinPath(cacheDir, getprogname());

            cacheDir = joinPath(cacheDir, ".cache/");
            if (!NEO::SysCalls::pathExists(cacheDir)) {
                NEO::SysCalls::mkdir(cacheDir);
            }
            PRINT_DEBUG_STRING(NEO::debugManager.flags.PrintDebugMessages.get(), stdout, "Trying to create cache in: %s\n\n",
                                cacheDir.c_str());
        }

        //now if cache dir is still not created use /data/local/tmp/cache/ as fallback cache dir
        if (!NEO::SysCalls::pathExists(cacheDir)) {
            PRINT_DEBUG_STRING(NEO::debugManager.flags.PrintDebugMessages.get(), stdout, "unable to create cache in: %s\n\n",
                                cacheDir.c_str());
            cacheDir = "/data/local/tmp/cache";
            if (!NEO::SysCalls::pathExists(cacheDir)) {
                NEO::SysCalls::mkdir(cacheDir);
            }

            cacheDir = joinPath(cacheDir, getprogname());
            if (!NEO::SysCalls::pathExists(cacheDir)) {
                NEO::SysCalls::mkdir(cacheDir);
            }

            cacheDir = joinPath(cacheDir, ".cache/");
            if (!NEO::SysCalls::pathExists(cacheDir)) {
                NEO::SysCalls::mkdir(cacheDir);
            }
            PRINT_DEBUG_STRING(NEO::debugManager.flags.PrintDebugMessages.get(), stdout, "creating temporay cache in:  %s\n\n",
                                cacheDir.c_str());
        }
#else
        cacheDir = reader.getSetting("HOME", emptyString);
        if (cacheDir.empty()) {
            return false;
        }

        cacheDir = joinPath(cacheDir, ".cache/");
        if (!NEO::SysCalls::pathExists(cacheDir)) {
            NEO::SysCalls::mkdir(cacheDir);
        }
#endif
        return createCompilerCachePath(cacheDir);
    }

    if (NEO::SysCalls::pathExists(cacheDir)) {
        return createCompilerCachePath(cacheDir);
    }

    return false;
}

time_t getFileModificationTime(const std::string &path) {
    struct stat st;
    if (NEO::SysCalls::stat(path, &st) == 0) {
        return st.st_mtime;
    }
    return 0;
}

size_t getFileSize(const std::string &path) {
    struct stat st;
    if (NEO::SysCalls::stat(path, &st) == 0) {
        return static_cast<size_t>(st.st_size);
    }
    return 0u;
}
} // namespace NEO
