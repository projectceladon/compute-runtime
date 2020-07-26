/*
 * Copyright (C) 2019-2020 Intel Corporation
 *
 * SPDX-License-Identifier: MIT
 *
 */

#pragma once
#include "shared/source/helpers/non_copyable_or_moveable.h"
#include "shared/source/os_interface/windows/os_interface.h"
#include "shared/source/os_interface/windows/wddm/wddm.h"

#include "level_zero/tools/source/sysman/sysman_imp.h"
#include "level_zero/tools/source/sysman/windows/kmd_sys.h"
#include "level_zero/tools/source/sysman/windows/kmd_sys_manager.h"

namespace L0 {

class WddmSysmanImp : public OsSysman, NEO::NonCopyableOrMovableClass {
  public:
    WddmSysmanImp() = default;
    WddmSysmanImp(SysmanImp *pParentSysmanImp) : pParentSysmanImp(pParentSysmanImp){};
    WddmSysmanImp(SysmanDeviceImp *pParentSysmanDeviceImp) : pParentSysmanDeviceImp(pParentSysmanDeviceImp){};
    ~WddmSysmanImp() override;

    ze_result_t init() override;

    KmdSysManager &getKmdSysManager();
    NEO::Wddm &getWddm();

  protected:
    KmdSysManager *pKmdSysManager = nullptr;

  private:
    SysmanImp *pParentSysmanImp = nullptr;
    SysmanDeviceImp *pParentSysmanDeviceImp = nullptr;
    NEO::Wddm *pWddm = nullptr;
};

} // namespace L0
