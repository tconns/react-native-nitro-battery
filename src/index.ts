import { NitroModules } from 'react-native-nitro-modules'
import type {
  NitroBattery as NitroBatterySpec,
  BatteryListener,
  LowPowerListener,
} from './specs/NitroBattery.nitro'

export const NitroBattery =
  NitroModules.createHybridObject<NitroBatterySpec>('NitroBattery')

export const addBatteryStateListener = (listener: BatteryListener) => {
  return NitroBattery.addBatteryStateListener(listener)
}

export const removeBatteryStateListener = (listener: BatteryListener) => {
  return NitroBattery.removeBatteryStateListener(listener)
}

export const addLowPowerListener = (listener: LowPowerListener) => {
  return NitroBattery.addLowPowerListener(listener)
}

export const removeLowPowerListener = (listener: LowPowerListener) => {
  return NitroBattery.removeLowPowerListener(listener)
}

export const getLevel = () => {
  return NitroBattery.getLevel()
}

export const isCharging = () => {
  return NitroBattery.isCharging()
}

export const getBatteryState = () => {
  return NitroBattery.getBatteryState()
}

export const isLowPowerModeEnabled = () => {
  return NitroBattery.isLowPowerModeEnabled()
}
