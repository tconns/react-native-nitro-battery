import type { HybridObject } from 'react-native-nitro-modules'

export interface BatteryListener {
  (state: string): void
}

export interface LowPowerListener {
  (): void
}

export interface NitroBattery
  extends HybridObject<{ ios: 'swift'; android: 'kotlin' }> {
  getLevel(): number
  isCharging(): boolean
  getBatteryState(): string
  isLowPowerModeEnabled(): boolean
  addBatteryStateListener(listener: BatteryListener): void
  removeBatteryStateListener(listener: BatteryListener): void
  addLowPowerListener(listener: LowPowerListener): void
  removeLowPowerListener(listener: LowPowerListener): void
}
