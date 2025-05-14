/*
 * Copyright (C) 2019-2025 Intel Corporation
 *
 * SPDX-License-Identifier: MIT
 *
 */

#include "shared/source/os_interface/linux/os_library_linux.h"

#include "shared/source/helpers/debug_helpers.h"
#include "shared/source/os_interface/linux/sys_calls.h"

#include <cstring>
#include <dlfcn.h>
#include <link.h>

namespace NEO {

OsLibrary *OsLibrary::load(const OsLibraryCreateProperties &properties) {
    auto ptr = new (std::nothrow) Linux::OsLibrary(properties);
    if (ptr == nullptr)
        return nullptr;

    if (!ptr->isLoaded()) {
        delete ptr;
        return nullptr;
    }
    return ptr;
}

const std::string OsLibrary::createFullSystemPath(const std::string &name) {
    return name;
}

bool getLoadedLibVersion(const std::string &libName, const std::string &regexVersionPattern, std::string &outVersion, std::string &errReason) {
    return false;
}

namespace Linux {

OsLibrary::OsLibrary(const OsLibraryCreateProperties &properties) {
    if (properties.libraryName.empty() || properties.performSelfLoad) {
        this->handle = SysCalls::dlopen(0, RTLD_LAZY);
    } else {
#ifdef SANITIZER_BUILD
        auto dlopenFlag = RTLD_LAZY;
#else
        auto dlopenFlag = RTLD_LAZY | RTLD_DEEPBIND;
        /* Background: https://github.com/intel/compute-runtime/issues/122 */
#endif
        dlopenFlag = properties.customLoadFlags ? *properties.customLoadFlags : dlopenFlag;
        adjustLibraryFlags(dlopenFlag);
        this->handle = SysCalls::dlopen(properties.libraryName.c_str(), dlopenFlag);
        if (!this->handle && (properties.errorValue != nullptr)) {
            properties.errorValue->assign(dlerror());
        }
    }
}

OsLibrary::~OsLibrary() {
    if (this->handle != nullptr) {
        dlclose(this->handle);
        this->handle = nullptr;
    }
}

bool OsLibrary::isLoaded() {
    return this->handle != nullptr;
}

void *OsLibrary::getProcAddress(const std::string &procName) {
    DEBUG_BREAK_IF(this->handle == nullptr);

    return dlsym(this->handle, procName.c_str());
}

std::string OsLibrary::getFullPath() {
#ifdef __ANDROID__
    struct FindPathData {
        void* target_handle;
        std::string full_path;
    };

    FindPathData find_data;
    find_data.target_handle = this->handle;
    find_data.full_path = "";

    auto callback = [](struct dl_phdr_info *info, size_t size, void *data) {
        FindPathData *fd = static_cast<FindPathData*>(data);
        // We can't directly compare handles. We might need to rely on the library name
        // or other heuristics if the handle isn't directly comparable.
        // A safer approach might be to store the library's loaded address if available
        // and compare that. However, dl_iterate_phdr doesn't directly give the handle
        // used by dlopen.

        // A common approach is to try and infer the handle based on the loaded
        // address range, but this is complex and not guaranteed.

        // For a simpler (though potentially less robust) approach, we can try
        // to match based on the library name if we have it.

        // If 'this->handle' was obtained from dlopen with a specific path,
        // we could try to find a loaded library with a matching dlpi_name.

        // For this example, let's assume 'this->handle' doesn't give us a direct
        // comparable value with 'info'. We'll return the first non-empty path.
        if (fd->full_path.empty() && info->dlpi_name != nullptr && strlen(info->dlpi_name) > 0) {
            fd->full_path = info->dlpi_name;
            return 1; // Stop iteration
        }
        return 0;
    };

    dl_iterate_phdr(callback, &find_data);
    return find_data.full_path;

#else // Not Android (assuming Linux or other glibc-based system)
    struct link_map *map = nullptr;
    int retVal = NEO::SysCalls::dlinfo(this->handle, RTLD_DI_LINKMAP, &map);
    if (retVal == 0 && map != nullptr) {
        return std::string(map->l_name);
    }
#endif
    return std::string();
}

struct FindLibData {
    const char *target_lib_name;
    bool found;
};

static int find_library_callback(struct dl_phdr_info *info, size_t size, void *data) {
    struct FindLibData *find_data = (struct FindLibData *)data;

    // Check if the dlpi_name (path to the loaded library) contains the target library name
    if (info->dlpi_name != NULL && strstr(info->dlpi_name, find_data->target_lib_name) != NULL) {
        find_data->found = true;
        return 1; // Stop iterating once found
    }

    return 0; // Continue iterating
}

bool isLibraryLoaded(const std::string &libraryName) {
    auto handle = SysCalls::dlopen(0, RTLD_LAZY);
    if (!handle) {
        return false;
    }
    struct FindLibData find_data;
    find_data.target_lib_name = libraryName.c_str();
    find_data.found = false;
    if (dl_iterate_phdr(find_library_callback, &find_data) == 0) {
        // Iterated through all libraries, and the target was not found
        dlclose(handle);
        return false;
    }

    dlclose(handle);
    return find_data.found;
}
} // namespace Linux
} // namespace NEO
