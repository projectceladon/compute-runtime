/*
 * Copyright (C) 2017-2018 Intel Corporation
 *
 * SPDX-License-Identifier: MIT
 *
 */

#ifndef CONFIG_H
#define CONFIG_H

#define USE_CL_CACHE
#if defined(USE_CL_CACHE)
static const bool clCacheEnabled = true;
#else
static const bool clCacheEnabled = false;
#endif

#define CL_CACHE_LOCATION "cl_cache"
#define NEO_ARCH "x64"

#endif /* CONFIG_H */
