/*
 * Copyright (C) 2018-2024 Intel Corporation
 *
 * SPDX-License-Identifier: MIT
 *
 */

#pragma once

#include "shared/source/memory_manager/residency_container.h"
#include "shared/source/os_interface/windows/windows_defs.h"
#include "shared/source/os_interface/windows/windows_wrapper.h"
#include "shared/source/utilities/spinlock.h"

#include <atomic>
#include <mutex>

struct _D3DKMT_TRIMNOTIFICATION;
typedef _D3DKMT_TRIMNOTIFICATION D3DKMT_TRIMNOTIFICATION;
struct D3DDDI_TRIMRESIDENCYSET_FLAGS;

namespace NEO {

class GraphicsAllocation;
class WddmAllocation;
class Wddm;
class CommandStreamReceiver;

class WddmResidencyController {
  public:
    WddmResidencyController(Wddm &wddm, uint32_t osContextId);
    MOCKABLE_VIRTUAL ~WddmResidencyController();

    static void APIENTRY trimCallback(_Inout_ D3DKMT_TRIMNOTIFICATION *trimNotification);

    [[nodiscard]] MOCKABLE_VIRTUAL std::unique_lock<SpinLock> acquireLock();
    [[nodiscard]] std::unique_lock<SpinLock> acquireTrimCallbackLock();

    bool wasAllocationUsedSinceLastTrim(uint64_t fenceValue) { return fenceValue > lastTrimFenceValue; }
    void updateLastTrimFenceValue() { lastTrimFenceValue = *this->getMonitoredFence().cpuAddress; }

    MonitoredFence &getMonitoredFence() { return monitoredFence; }
    void resetMonitoredFenceParams(D3DKMT_HANDLE &handle, uint64_t *cpuAddress, D3DGPU_VIRTUAL_ADDRESS &gpuAddress);

    void registerCallback();

    void trimResidency(const D3DDDI_TRIMRESIDENCYSET_FLAGS &flags, uint64_t bytes);
    bool trimResidencyToBudget(uint64_t bytes, std::unique_lock<std::mutex> &lock);

    bool isMemoryBudgetExhausted() const { return memoryBudgetExhausted; }
    void setMemoryBudgetExhausted() { memoryBudgetExhausted = true; }

    bool makeResidentResidencyAllocations(ResidencyContainer &allocationsForResidency, bool &requiresBlockingResidencyHandling);

    bool isInitialized() const;

    void setCommandStreamReceiver(CommandStreamReceiver *csr);

  protected:
    MonitoredFence monitoredFence = {};

    std::vector<D3DKMT_HANDLE> handlesToEvict;

    SpinLock lock;
    SpinLock trimCallbackLock;

    uint64_t lastTrimFenceValue = 0u;

    Wddm &wddm;
    VOID *trimCallbackHandle = nullptr;

    uint32_t osContextId;

    bool memoryBudgetExhausted = false;

    CommandStreamReceiver *csr;
};
} // namespace NEO
