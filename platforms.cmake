#
# Copyright (C) 2018-2020 Intel Corporation
#
# SPDX-License-Identifier: MIT
#

set(MAX_GEN 64)

set(ALL_GEN_TYPES "")

list(APPEND ALL_GEN_TYPES "GEN8")
list(APPEND ALL_GEN_TYPES "GEN9")
list(APPEND ALL_GEN_TYPES "GEN11")
list(APPEND ALL_GEN_TYPES "GEN12LP")

set(ALL_GEN_TYPES_REVERSED ${ALL_GEN_TYPES})
list(REVERSE ALL_GEN_TYPES_REVERSED)

macro(FIND_IDX_FOR_GEN_TYPE GEN_TYPE GEN_IDX)
  list(FIND ALL_GEN_TYPES "${GEN_TYPE}" GEN_IDX)
  if(${GEN_IDX} EQUAL -1)
    message(FATAL_ERROR "No ${GEN_TYPE} allowed, exiting")
  endif()
endmacro()

macro(INIT_LIST LIST_TYPE ELEMENT_TYPE)
  foreach(IT RANGE 0 ${MAX_GEN} 1)
    list(APPEND ALL_${ELEMENT_TYPE}_${LIST_TYPE} " ")
  endforeach()
endmacro()

macro(GET_LIST_FOR_GEN LIST_TYPE ELEMENT_TYPE GEN_IDX OUT_LIST)
  list(GET ALL_${ELEMENT_TYPE}_${LIST_TYPE} ${GEN_IDX} GEN_X_${LIST_TYPE})
  string(REPLACE "_" ";" ${OUT_LIST} ${GEN_X_${LIST_TYPE}})
endmacro()

macro(ADD_ITEM_FOR_GEN LIST_TYPE ELEMENT_TYPE GEN_TYPE ITEM)
  FIND_IDX_FOR_GEN_TYPE(${GEN_TYPE} GEN_IDX)
  list(GET ALL_${ELEMENT_TYPE}_${LIST_TYPE} ${GEN_IDX} GEN_X_LIST)
  string(REPLACE " " "" GEN_X_LIST ${GEN_X_LIST})
  if("${GEN_X_LIST}" STREQUAL "")
    set(GEN_X_LIST "${ITEM}")
  else()
    set(GEN_X_LIST "${GEN_X_LIST}_${ITEM}")
  endif()
  list(REMOVE_AT ALL_${ELEMENT_TYPE}_${LIST_TYPE} ${GEN_IDX})
  list(INSERT ALL_${ELEMENT_TYPE}_${LIST_TYPE} ${GEN_IDX} ${GEN_X_LIST})
endmacro()

macro(GEN_CONTAINS_PLATFORMS TYPE GEN_TYPE OUT_FLAG)
  FIND_IDX_FOR_GEN_TYPE(${GEN_TYPE} GEN_IDX)
  GET_LIST_FOR_GEN("PLATFORMS" ${TYPE} ${GEN_IDX} GEN_X_PLATFORMS)
  string(REPLACE " " "" GEN_X_PLATFORMS ${GEN_X_PLATFORMS})
  if("${GEN_X_PLATFORMS}" STREQUAL "")
    set(${OUT_FLAG} FALSE)
  else()
    set(${OUT_FLAG} TRUE)
  endif()
endmacro()

macro(INIT_PRODUCTS_LIST TYPE)
  list(APPEND ALL_${TYPE}_PRODUCT_FAMILY " ")
  list(APPEND ALL_${TYPE}_PRODUCT_TO_PRODUCT_FAMILY " ")
endmacro()

macro(ADD_PRODUCT TYPE PRODUCT ITEM)
  list(APPEND ALL_${TYPE}_PRODUCT_FAMILY ${ITEM})
  list(APPEND ALL_${TYPE}_PRODUCT_TO_PRODUCT_FAMILY ${PRODUCT})
endmacro()

macro(GET_AVAILABLE_PRODUCTS TYPE PRODUCT_FAMILY_LIST DEFAULT_PRODUCT_FAMILY)
  list(REMOVE_ITEM ALL_${TYPE}_PRODUCT_FAMILY " ")
  list(REMOVE_ITEM ALL_${TYPE}_PRODUCT_TO_PRODUCT_FAMILY " ")

  set(${PRODUCT_FAMILY_LIST} ${ALL_${TYPE}_PRODUCT_FAMILY})
  set(${DEFAULT_PRODUCT_FAMILY})

  if(NOT "${DEFAULT_${TYPE}_PLATFORM}" STREQUAL "")
    list(FIND ALL_${TYPE}_PRODUCT_TO_PRODUCT_FAMILY ${DEFAULT_${TYPE}_PLATFORM} INDEX)
    if(${INDEX} EQUAL -1)
      message(FATAL_ERROR "${DEFAULT_${TYPE}_PLATFORM} not found in product families.")
    endif()

    list(GET ALL_${TYPE}_PRODUCT_FAMILY ${INDEX} DEFAULT)
    set(${DEFAULT_PRODUCT_FAMILY} ${DEFAULT})
  endif()
endmacro()

macro(GET_AVAILABLE_PLATFORMS TYPE FLAG_NAME OUT_STR)
  set(${TYPE}_PLATFORM_LIST)
  set(${TYPE}_GEN_FLAGS_DEFINITONS)
  if(NOT DEFAULT_${TYPE}_PLATFORM AND DEFINED PREFERRED_PLATFORM AND ${FLAG_NAME}_${PREFERRED_PLATFORM})
    set(DEFAULT_${TYPE}_PLATFORM ${PREFERRED_PLATFORM})
  endif()
  foreach(GEN_TYPE ${ALL_GEN_TYPES_REVERSED})
    GEN_CONTAINS_PLATFORMS(${TYPE} ${GEN_TYPE} GENX_HAS_PLATFORMS)
    if(${GENX_HAS_PLATFORMS})
      FIND_IDX_FOR_GEN_TYPE(${GEN_TYPE} GEN_IDX)
      list(APPEND ${TYPE}_GEN_FLAGS_DEFINITONS ${FLAG_NAME}_${GEN_TYPE})
      GET_LIST_FOR_GEN("PLATFORMS" ${TYPE} ${GEN_IDX} ${TYPE}_GENX_PLATFORMS)
      list(APPEND ${TYPE}_PLATFORM_LIST ${${TYPE}_GENX_PLATFORMS})
      if(NOT DEFAULT_${TYPE}_PLATFORM)
        list(GET ${TYPE}_PLATFORM_LIST 0 DEFAULT_${TYPE}_PLATFORM ${PLATFORM_IT})
      endif()
      if(NOT DEFAULT_${TYPE}_${GEN_TYPE}_PLATFORM)
        list(GET ${TYPE}_GENX_PLATFORMS 0 DEFAULT_${TYPE}_${GEN_TYPE}_PLATFORM)
      endif()
    endif()
  endforeach()
  foreach(PLATFORM_IT ${${TYPE}_PLATFORM_LIST})
    set(${OUT_STR} "${${OUT_STR}} ${PLATFORM_IT}")
    list(APPEND ${TYPE}_GEN_FLAGS_DEFINITONS ${FLAG_NAME}_${PLATFORM_IT})
  endforeach()
endmacro()

macro(GET_PLATFORMS_FOR_GEN TYPE GEN_TYPE OUT_LIST)
  FIND_IDX_FOR_GEN_TYPE(${GEN_TYPE} GEN_IDX)
  GET_LIST_FOR_GEN("PLATFORMS" ${TYPE} ${GEN_IDX} ${OUT_LIST})
endmacro()

macro(GET_TEST_CONFIGURATIONS_FOR_PLATFORM TYPE GEN_TYPE PLATFORM OUT_LIST)
  FIND_IDX_FOR_GEN_TYPE(${GEN_TYPE} GEN_IDX)
  set(${OUT_LIST})
  string(TOLOWER ${PLATFORM} PLATFORM_LOWER)
  GET_LIST_FOR_GEN("CONFIGURATIONS" ${TYPE} ${GEN_IDX} ALL_CONFIGURATIONS_FOR_GEN)
  foreach(CONFIGURATION ${ALL_CONFIGURATIONS_FOR_GEN})
    string(REPLACE "/" ";" CONFIGURATION_PARAMS ${CONFIGURATION})
    list(GET CONFIGURATION_PARAMS 0 CONFIGURATION_PLATFORM)
    if(${CONFIGURATION_PLATFORM} STREQUAL ${PLATFORM_LOWER})
      list(APPEND ${OUT_LIST} ${CONFIGURATION})
    endif()
  endforeach()
endmacro()

macro(PLATFORM_HAS_2_0 GEN_TYPE PLATFORM_NAME OUT_FLAG)
  FIND_IDX_FOR_GEN_TYPE(${GEN_TYPE} GEN_IDX)
  GET_LIST_FOR_GEN("PLATFORMS" "SUPPORTED_2_0" ${GEN_IDX} GEN_X_PLATFORMS)
  list(FIND GEN_X_PLATFORMS ${PLATFORM_NAME} PLATFORM_EXISTS)
  if("${PLATFORM_EXISTS}" LESS 0)
    set(${OUT_FLAG} FALSE)
  else()
    set(${OUT_FLAG} TRUE)
  endif()
endmacro()

macro(PLATFORM_HAS_VME GEN_TYPE PLATFORM_NAME OUT_FLAG)
  FIND_IDX_FOR_GEN_TYPE(${GEN_TYPE} GEN_IDX)
  GET_LIST_FOR_GEN("PLATFORMS" "SUPPORTED_VME" ${GEN_IDX} GEN_X_PLATFORMS)
  list(FIND GEN_X_PLATFORMS ${PLATFORM_NAME} PLATFORM_EXISTS)
  if("${PLATFORM_EXISTS}" LESS 0)
    set(${OUT_FLAG} FALSE)
  else()
    set(${OUT_FLAG} TRUE)
  endif()
endmacro()

# default flag for GenX devices support
set(SUPPORT_GEN_DEFAULT TRUE CACHE BOOL "default value for SUPPORT_GENx")
# default flag for platform support
set(SUPPORT_PLATFORM_DEFAULT TRUE CACHE BOOL "default value for support platform")

# Define the hardware configurations we support and test
macro(SET_FLAGS_FOR GEN_TYPE)
  set(SUPPORT_${GEN_TYPE} ${SUPPORT_GEN_DEFAULT} CACHE BOOL "Support ${GEN_TYPE} devices")
  set(TESTS_${GEN_TYPE} ${SUPPORT_${GEN_TYPE}} CACHE BOOL "Build ULTs for ${GEN_TYPE} devices")
  set(SUPPORT_DEVICE_ENQUEUE_${GEN_TYPE} TRUE CACHE BOOL "Support ${GEN_TYPE} for device side enqueue")

  if(NOT SUPPORT_${GEN_TYPE} OR SKIP_UNIT_TESTS)
    set(TESTS_${GEN_TYPE} FALSE)
  endif()
  if(SUPPORT_${GEN_TYPE})
    foreach(${GEN_TYPE}_PLATFORM ${ARGN})
      set(SUPPORT_${${GEN_TYPE}_PLATFORM} ${SUPPORT_PLATFORM_DEFAULT} CACHE BOOL "Support ${${GEN_TYPE}_PLATFORM}")
      if(TESTS_${GEN_TYPE})
        set(TESTS_${${GEN_TYPE}_PLATFORM} ${SUPPORT_${${GEN_TYPE}_PLATFORM}} CACHE BOOL "Build ULTs for ${${GEN_TYPE}_PLATFORM}")
      endif()
      if(NOT SUPPORT_${${GEN_TYPE}_PLATFORM} OR NOT TESTS_${GEN_TYPE} OR SKIP_UNIT_TESTS)
        set(TESTS_${${GEN_TYPE}_PLATFORM} FALSE)
      endif()
    endforeach()
  endif()
endmacro()
macro(ADD_PLATFORM_FOR_GEN LIST_TYPE GEN_TYPE PLATFORM_NAME PLATFORM_TYPE)
  list(APPEND PLATFORM_TYPES ${PLATFORM_TYPE})
  list(REMOVE_DUPLICATES PLATFORM_TYPES)
  ADD_ITEM_FOR_GEN("PLATFORMS" ${LIST_TYPE} ${GEN_TYPE} ${PLATFORM_NAME})
  set(${GEN_TYPE}_HAS_${PLATFORM_TYPE} TRUE)
  set(${PLATFORM_NAME}_IS_${PLATFORM_TYPE} TRUE)
  if(NOT DEFAULT_${LIST_TYPE}_${GEN_TYPE}_${PLATFORM_TYPE}_PLATFORM)
    string(TOLOWER ${PLATFORM_NAME} DEFAULT_${LIST_TYPE}_${GEN_TYPE}_${PLATFORM_TYPE}_PLATFORM)
  endif()
endmacro()

SET_FLAGS_FOR("GEN8" "BDW")
SET_FLAGS_FOR("GEN9" "SKL" "KBL" "BXT" "GLK" "CFL")
SET_FLAGS_FOR("GEN11" "ICLLP" "LKF" "EHL")
SET_FLAGS_FOR("GEN12LP" "TGLLP")

# Init lists
INIT_LIST("FAMILY_NAME" "TESTED")
INIT_LIST("PLATFORMS" "SUPPORTED")
INIT_LIST("PLATFORMS" "SUPPORTED_2_0")
INIT_LIST("PLATFORMS" "SUPPORTED_VME")
INIT_LIST("PLATFORMS" "TESTED")
INIT_LIST("CONFIGURATIONS" "MT_TESTS")
INIT_PRODUCTS_LIST("TESTED")
INIT_PRODUCTS_LIST("SUPPORTED")

# Add supported and tested platforms
if(SUPPORT_GEN8)
  if(TESTS_GEN8)
    ADD_ITEM_FOR_GEN("FAMILY_NAME" "TESTED" "GEN8" "BDWFamily")
  endif()
  if(SUPPORT_BDW)
    ADD_PRODUCT("SUPPORTED" "BDW" "IGFX_BROADWELL")
    ADD_PLATFORM_FOR_GEN("SUPPORTED" "GEN8" "BDW" "CORE")
    ADD_PLATFORM_FOR_GEN("SUPPORTED_2_0" "GEN8" "BDW" "CORE")
    if(TESTS_BDW)
      ADD_ITEM_FOR_GEN("PLATFORMS" "TESTED" "GEN8" "BDW")
      ADD_ITEM_FOR_GEN("CONFIGURATIONS" "MT_TESTS" "GEN8" "bdw/1/3/8")
      ADD_PRODUCT("TESTED" "BDW" "IGFX_BROADWELL")
    endif()
  endif()
endif()

if(SUPPORT_GEN9)
  if(TESTS_GEN9)
    ADD_ITEM_FOR_GEN("FAMILY_NAME" "TESTED" "GEN9" "SKLFamily")
  endif()
  if(SUPPORT_SKL)
    ADD_PRODUCT("SUPPORTED" "SKL" "IGFX_SKYLAKE")
    ADD_PLATFORM_FOR_GEN("SUPPORTED" "GEN9" "SKL" "CORE")
    ADD_PLATFORM_FOR_GEN("SUPPORTED_2_0" "GEN9" "SKL" "CORE")
    ADD_PLATFORM_FOR_GEN("SUPPORTED_VME" "GEN9" "SKL" "CORE")
    set(PREFERRED_PLATFORM "SKL")
    if(TESTS_SKL)
      set(PREFERRED_FAMILY_NAME "SKLFamily")
      ADD_ITEM_FOR_GEN("PLATFORMS" "TESTED" "GEN9" "SKL")
      ADD_ITEM_FOR_GEN("CONFIGURATIONS" "MT_TESTS" "GEN9" "skl/1/3/8")
      ADD_PRODUCT("TESTED" "SKL" "IGFX_SKYLAKE")
    endif()
  endif()

  if(SUPPORT_KBL)
    ADD_PRODUCT("SUPPORTED" "KBL" "IGFX_KABYLAKE")
    ADD_PLATFORM_FOR_GEN("SUPPORTED" "GEN9" "KBL" "CORE")
    ADD_PLATFORM_FOR_GEN("SUPPORTED_2_0" "GEN9" "KBL" "CORE")
    ADD_PLATFORM_FOR_GEN("SUPPORTED_VME" "GEN9" "KBL" "CORE")
    if(TESTS_KBL)
      ADD_ITEM_FOR_GEN("PLATFORMS" "TESTED" "GEN9" "KBL")
      ADD_PRODUCT("TESTED" "KBL" "IGFX_KABYLAKE")
    endif()
  endif()

  if(SUPPORT_GLK)
    ADD_PRODUCT("SUPPORTED" "GLK" "IGFX_GEMINILAKE")
    ADD_PLATFORM_FOR_GEN("SUPPORTED" "GEN9" "GLK" "LP")
    ADD_PLATFORM_FOR_GEN("SUPPORTED_VME" "GEN9" "GLK" "LP")
    if(TESTS_GLK)
      ADD_ITEM_FOR_GEN("PLATFORMS" "TESTED" "GEN9" "GLK")
      ADD_PRODUCT("TESTED" "GLK" "IGFX_GEMINILAKE")
    endif()
  endif()

  if(SUPPORT_CFL)
    ADD_PRODUCT("SUPPORTED" "CFL" "IGFX_COFFEELAKE")
    ADD_PLATFORM_FOR_GEN("SUPPORTED" "GEN9" "CFL" "CORE")
    ADD_ITEM_FOR_GEN("PLATFORMS" "SUPPORTED_2_0" "GEN9" "CFL")
    ADD_ITEM_FOR_GEN("PLATFORMS" "SUPPORTED_VME" "GEN9" "CFL")
    if(TESTS_CFL)
      ADD_ITEM_FOR_GEN("PLATFORMS" "TESTED" "GEN9" "CFL")
      ADD_PRODUCT("TESTED" "CFL" "IGFX_COFFEELAKE")
    endif()
  endif()

  if(SUPPORT_BXT)
    ADD_PRODUCT("SUPPORTED" "BXT" "IGFX_BROXTON")
    ADD_PLATFORM_FOR_GEN("SUPPORTED" "GEN9" "BXT" "LP")
    ADD_PLATFORM_FOR_GEN("SUPPORTED_VME" "GEN9" "BXT" "LP")
    if(TESTS_BXT)
      ADD_ITEM_FOR_GEN("PLATFORMS" "TESTED" "GEN9" "BXT")
      ADD_PRODUCT("TESTED" "BXT" "IGFX_BROXTON")
    endif()
  endif()
endif()

if(SUPPORT_GEN11)
  if(TESTS_GEN11)
    ADD_ITEM_FOR_GEN("FAMILY_NAME" "TESTED" "GEN11" "ICLFamily")
  endif()

  if(SUPPORT_ICLLP)
    ADD_PRODUCT("SUPPORTED" "ICLLP" "IGFX_ICELAKE_LP")
    ADD_PLATFORM_FOR_GEN("SUPPORTED" "GEN11" "ICLLP" "LP")
    ADD_PLATFORM_FOR_GEN("SUPPORTED_2_0" "GEN11" "ICLLP" "LP")
    ADD_PLATFORM_FOR_GEN("SUPPORTED_VME" "GEN11" "ICLLP" "LP")
    if(TESTS_ICLLP)
      ADD_ITEM_FOR_GEN("PLATFORMS" "TESTED" "GEN11" "ICLLP")
      ADD_ITEM_FOR_GEN("CONFIGURATIONS" "MT_TESTS" "GEN11" "icllp/1/8/8")
      ADD_PRODUCT("TESTED" "ICLLP" "IGFX_ICELAKE_LP")
    endif()
  endif()

  if(SUPPORT_LKF)
    ADD_PRODUCT("SUPPORTED" "LKF" "IGFX_LAKEFIELD")
    ADD_PLATFORM_FOR_GEN("SUPPORTED" "GEN11" "LKF" "LP")
    if(TESTS_LKF)
      ADD_ITEM_FOR_GEN("PLATFORMS" "TESTED" "GEN11" "LKF")
      ADD_PRODUCT("TESTED" "LKF" "IGFX_LAKEFIELD")
    endif()
  endif()

  if(SUPPORT_EHL)
    ADD_PRODUCT("SUPPORTED" "EHL" "IGFX_ELKHARTLAKE")
    ADD_PLATFORM_FOR_GEN("SUPPORTED" "GEN11" "EHL" "LP")
    if(TESTS_EHL)
      ADD_ITEM_FOR_GEN("PLATFORMS" "TESTED" "GEN11" "EHL")
      ADD_PRODUCT("TESTED" "EHL" "IGFX_ELKHARTLAKE")
    endif()
  endif()
endif()

if(SUPPORT_GEN12LP)
  if(TESTS_GEN12LP)
    ADD_ITEM_FOR_GEN("FAMILY_NAME" "TESTED" "GEN12LP" "TGLLPFamily")
  endif()
  if(SUPPORT_TGLLP)
    ADD_PRODUCT("SUPPORTED" "TGLLP" "IGFX_TIGERLAKE_LP")
    ADD_PLATFORM_FOR_GEN("SUPPORTED" "GEN12LP" "TGLLP" "LP")
    ADD_PLATFORM_FOR_GEN("SUPPORTED_2_0" "GEN12LP" "TGLLP" "LP")
    if(TESTS_TGLLP)
      ADD_ITEM_FOR_GEN("PLATFORMS" "TESTED" "GEN12LP" "TGLLP")
      ADD_ITEM_FOR_GEN("CONFIGURATIONS" "MT_TESTS" "GEN12LP" "tgllp/1/6/16")
      ADD_PRODUCT("TESTED" "TGLLP" "IGFX_TIGERLAKE_LP")
    endif()
  endif()
endif()

# Get platform lists, flag definition and set default platforms
GET_AVAILABLE_PLATFORMS("SUPPORTED" "SUPPORT" ALL_AVAILABLE_SUPPORTED_PLATFORMS)
GET_AVAILABLE_PLATFORMS("TESTED" "TESTS" ALL_AVAILABLE_TESTED_PLATFORMS)
GET_AVAILABLE_PRODUCTS("TESTED" ALL_PRODUCT_FAMILY_LIST DEFAULT_TESTED_PRODUCT_FAMILY)
GET_AVAILABLE_PRODUCTS("SUPPORTED" ALL_PRODUCT_FAMILY_LIST DEFAULT_SUPPORTED_PRODUCT_FAMILY)

message(STATUS "All supported platforms: ${ALL_AVAILABLE_SUPPORTED_PLATFORMS}")
message(STATUS "All tested platforms: ${ALL_AVAILABLE_TESTED_PLATFORMS}")

message(STATUS "Default supported platform: ${DEFAULT_SUPPORTED_PLATFORM}")

message(STATUS "All tested product families: ${ALL_TESTED_PRODUCT_FAMILY}")
message(STATUS "All supported product families: ${ALL_SUPPORTED_PRODUCT_FAMILY}")
message(STATUS "Default tested product family: ${DEFAULT_TESTED_PRODUCT_FAMILY}")

list(FIND SUPPORTED_PLATFORM_LIST ${DEFAULT_SUPPORTED_PLATFORM} VALID_DEFAULT_SUPPORTED_PLATFORM)
if(VALID_DEFAULT_SUPPORTED_PLATFORM LESS 0)
  message(FATAL_ERROR "Not a valid supported platform: ${DEFAULT_SUPPORTED_PLATFORM}")
endif()

message(STATUS "Default tested platform: ${DEFAULT_TESTED_PLATFORM}")

if(DEFAULT_TESTED_PLATFORM)
  list(FIND TESTED_PLATFORM_LIST ${DEFAULT_TESTED_PLATFORM} VALID_DEFAULT_TESTED_PLATFORM)
  if(VALID_DEFAULT_TESTED_PLATFORM LESS 0)
    message(FATAL_ERROR "Not a valid tested platform: ${DEFAULT_TESTED_PLATFORM}")
  endif()
endif()

if(NOT DEFAULT_TESTED_FAMILY_NAME)
  if(DEFINED PREFERRED_FAMILY_NAME)
    list(FIND ALL_TESTED_FAMILY_NAME ${PREFERRED_FAMILY_NAME} GEN_IDX)
    if(${GEN_IDX} GREATER -1)
      set(DEFAULT_TESTED_FAMILY_NAME ${PREFERRED_FAMILY_NAME})
    endif()
  endif()
  if(NOT DEFINED DEFAULT_TESTED_FAMILY_NAME)
    foreach(GEN_TYPE ${ALL_GEN_TYPES_REVERSED})
      FIND_IDX_FOR_GEN_TYPE(${GEN_TYPE} GEN_IDX)
      list(GET ALL_TESTED_FAMILY_NAME ${GEN_IDX} GEN_FAMILY_NAME)
      if(NOT GEN_FAMILY_NAME STREQUAL " ")
        set(DEFAULT_TESTED_FAMILY_NAME ${GEN_FAMILY_NAME})
        break()
      endif()
    endforeach()
  endif()
endif()
message(STATUS "Default tested family name: ${DEFAULT_TESTED_FAMILY_NAME}")
