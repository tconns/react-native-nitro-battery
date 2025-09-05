# react-native-nitro-battery

🔋 High-performance battery monitoring for React Native built with Nitro Modules.

## Overview

This module provides comprehensive battery monitoring functionality for React Native applications. Monitor battery level, charging state, and low power mode with real-time updates and listeners, all built with Nitro Modules for optimal native performance and zero-bridge overhead.

## Features

- ⚡ High-performance native implementation using Nitro Modules
- 🔋 Real-time battery level monitoring
- 🔌 Charging state detection (charging, discharging, full, unknown)
- � Low power mode detection and notifications
- 🎯 Event listeners for battery state changes
- 📱 Cross-platform support (iOS & Android)
- 🚀 Zero-bridge overhead with direct native calls
- 🛡️ Memory-safe with automatic cleanup and proper listener management

## Requirements

- React Native >= 0.76
- Node >= 18
- `react-native-nitro-modules` must be installed (Nitro runtime)

## Installation

```bash
npm install react-native-nitro-battery react-native-nitro-modules
# or
yarn add react-native-nitro-battery react-native-nitro-modules
```

## Platform Configuration

### iOS

No additional configuration required. The module automatically enables battery monitoring when initialized.

### Android

Add battery monitoring permission to your `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Optional: For more detailed battery information -->
    <uses-permission android:name="android.permission.BATTERY_STATS" />
    
    <application
        android:name=".MainApplication"
        android:allowBackup="false"
        android:theme="@style/AppTheme">
            
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:theme="@style/LaunchTheme">
            <!-- Your existing activity configuration -->
        </activity>
    </application>
</manifest>
```

## Quick Usage

```ts
import { 
  NitroBattery, 
  addBatteryStateListener, 
  addLowPowerListener,
  getLevel,
  isCharging 
} from 'react-native-nitro-battery'

// Get current battery level (0-100)
const batteryLevel = getLevel()
console.log(`Battery level: ${batteryLevel}%`)

// Check if device is charging
const charging = isCharging()
console.log(`Is charging: ${charging}`)

const subscription = state => {
  console.log('Battery state changed:', state);
};

// Listen to battery state changes
addBatteryStateListener(subscription);

// Listen to low power mode activation
removeBatteryStateListener(subscription);

// Don't forget to remove listeners when done
// removeBatteryStateListener
// removeLowPowerListener
```

## API Reference

### NitroBattery

The main battery monitoring module providing direct access to native functionality.

### Core Functions

#### `getLevel(): number`

Returns the current battery level as a percentage.

- **Returns**: Battery level from 0-100, or -1 if unavailable

```ts
const level = getLevel()
console.log(`Battery: ${level}%`)
```

#### `isCharging(): boolean`

Checks if the device is currently charging.

- **Returns**: `true` if charging or full, `false` otherwise

```ts
const charging = isCharging()
if (charging) {
  console.log('Device is charging')
}
```

#### `getBatteryState(): string`

Gets the current battery state.

- **Returns**: One of: `'charging'`, `'discharging'`, `'full'`, `'unknown'`

```ts
const state = NitroBattery.getBatteryState()
console.log(`Battery state: ${state}`)
```

#### `isLowPowerModeEnabled(): boolean`

Checks if low power mode is currently enabled.

- **Returns**: `true` if low power mode is active

```ts
const lowPower = NitroBattery.isLowPowerModeEnabled()
if (lowPower) {
  console.log('Device is in low power mode')
}
```

### Event Listeners

#### `addBatteryStateListener(listener: BatteryListener): void`

Adds a listener for battery state changes.

- **listener**: Callback function that receives the new battery state

```ts
const listenerId = addBatteryStateListener((state) => {
  console.log(`Battery state: ${state}`)
})
```

#### `removeBatteryStateListener(listener: BatteryListener): void`

Removes a battery state listener.

- **listener**: Callback function that receives the new battery state

```ts
removeBatteryStateListener(listenerId)
```

#### `addLowPowerListener(listener: LowPowerListener): void`

Adds a listener for low power mode activation.

- **listener**: Callback function called when low power mode is enabled

```ts
addLowPowerListener(() => {
  console.log('Low power mode activated!')
})
```

#### `removeLowPowerListener(listener: LowPowerListener): void`

Removes a low power mode listener.

- **listener**: Callback function called when low power mode is enabled

```ts
removeLowPowerListener(listenerId)
```

### Advanced API

#### `NitroBattery.removeAllListeners(): void`

Removes all registered listeners. Useful for cleanup.

```ts
NitroBattery.removeAllListeners()
```

## Real-world Examples

### Basic Battery Monitoring

```ts
import React, { useEffect, useState } from 'react'
import { View, Text, Alert } from 'react-native'
import { 
  getLevel, 
  isCharging, 
  addBatteryStateListener, 
  addLowPowerListener,
  removeBatteryStateListener,
  removeLowPowerListener 
} from 'react-native-nitro-battery'

const BatteryMonitor = () => {
  const [batteryLevel, setBatteryLevel] = useState(0)
  const [charging, setCharging] = useState(false)
  const [batteryState, setBatteryState] = useState('unknown')

  useEffect(() => {
    // Get initial values
    setBatteryLevel(getLevel())
    setCharging(isCharging())
  }, [])

  useEffect(() => {
    const subscription = state => {
      console.log('Battery state changed:', state);
    };
    addBatteryStateListener(subscription);
    return () => {
      removeBatteryStateListener(subscription);
    };
  }, []);

  const getBatteryColor = () => {
    if (charging) return '#4CAF50' // Green when charging
    if (batteryLevel < 20) return '#F44336' // Red when low
    if (batteryLevel < 50) return '#FF9800' // Orange when medium
    return '#4CAF50' // Green when good
  }

  const getBatteryIcon = () => {
    if (charging) return '🔌'
    if (batteryLevel < 20) return '🪫'
    return '🔋'
  }

  return (
    <View style={{ padding: 20, alignItems: 'center' }}>
      <Text style={{ fontSize: 48 }}>{getBatteryIcon()}</Text>
      <Text style={{ 
        fontSize: 32, 
        fontWeight: 'bold', 
        color: getBatteryColor() 
      }}>
        {batteryLevel}%
      </Text>
      <Text style={{ fontSize: 18, marginTop: 10 }}>
        Status: {charging ? 'Charging' : 'Not Charging'}
      </Text>
      <Text style={{ fontSize: 16, marginTop: 5, color: '#666' }}>
        State: {batteryState}
      </Text>
    </View>
  )
}
```

### Power Management Hook

```ts
import { useState, useEffect, useCallback } from 'react'
import { 
  getLevel, 
  isCharging, 
  addBatteryStateListener, 
  addLowPowerListener,
  removeBatteryStateListener,
  removeLowPowerListener,
  NitroBattery 
} from 'react-native-nitro-battery'

export interface BatteryInfo {
  level: number
  isCharging: boolean
  state: string
  isLowPowerMode: boolean
}

export const useBattery = () => {
  const [batteryInfo, setBatteryInfo] = useState<BatteryInfo>({
    level: getLevel(),
    isCharging: isCharging(),
    state: NitroBattery.getBatteryState(),
    isLowPowerMode: NitroBattery.isLowPowerModeEnabled(),
  })

  const updateBatteryInfo = useCallback(() => {
    setBatteryInfo({
      level: getLevel(),
      isCharging: isCharging(),
      state: NitroBattery.getBatteryState(),
      isLowPowerMode: NitroBattery.isLowPowerModeEnabled(),
    })
  }, [])

  useEffect(() => {
    const batteryListener = addBatteryStateListener((state) => {
      updateBatteryInfo()
    })

    const lowPowerListener = addLowPowerListener(() => {
      updateBatteryInfo()
    })

    return () => {
      removeBatteryStateListener(batteryListener)
      removeLowPowerListener(lowPowerListener)
    }
  }, [updateBatteryInfo])

  return {
    ...batteryInfo,
    refresh: updateBatteryInfo,
    isLowBattery: batteryInfo.level < 20,
    isCriticalBattery: batteryInfo.level < 10,
    batteryHealth: batteryInfo.level > 80 ? 'excellent' : 
                   batteryInfo.level > 50 ? 'good' : 
                   batteryInfo.level > 20 ? 'fair' : 'poor'
  }
}

// Usage in component
const BatteryStatus = () => {
  const {
    level,
    isCharging,
    state,
    isLowPowerMode,
    isLowBattery,
    isCriticalBattery,
    batteryHealth
  } = useBattery()

  return (
    <View>
      <Text>Battery: {level}%</Text>
      <Text>Charging: {isCharging ? 'Yes' : 'No'}</Text>
      <Text>State: {state}</Text>
      <Text>Low Power Mode: {isLowPowerMode ? 'On' : 'Off'}</Text>
      <Text>Health: {batteryHealth}</Text>
      {isLowBattery && <Text style={{color: 'red'}}>⚠️ Low Battery</Text>}
      {isCriticalBattery && <Text style={{color: 'red'}}>🚨 Critical Battery</Text>}
    </View>
  )
}
```

## Best Practices

### Memory Management

Always clean up listeners to prevent memory leaks:

```ts
useEffect(() => {
    const subscription = state => {
      console.log('Battery state changed:', state);
    };
    addBatteryStateListener(subscription);
    return () => {
      removeBatteryStateListener(subscription);
    };
  }, []);
```

### Performance Considerations

- Battery monitoring has minimal performance impact
- Listeners are called on the main thread for UI updates
- Use throttling for frequent UI updates if needed

```ts
// Good: Throttled battery level updates
let lastUpdate = 0
const THROTTLE_MS = 1000 // Update UI max once per second

addBatteryStateListener((state) => {
  const now = Date.now()
  if (now - lastUpdate > THROTTLE_MS) {
    updateUI(getLevel(), state)
    lastUpdate = now
  }
})
```

### Error Handling

```ts
try {
  const level = getLevel()
  if (level === -1) {
    console.warn('Battery level unavailable')
    // Handle unavailable battery info
  } else {
    // Use battery level normally
    console.log(`Battery: ${level}%`)
  }
} catch (error) {
  console.error('Battery monitoring error:', error)
}
```

### Battery Optimization Tips

Based on battery state, you can optimize your app's behavior:

```ts
addBatteryStateListener((state) => {
  switch (state) {
    case 'charging':
      // Device is charging, safe to perform intensive tasks
      enableHighPerformanceMode()
      break
    case 'discharging':
      // On battery power, optimize for efficiency
      enablePowerSavingMode()
      break
    case 'full':
      // Battery full, can perform maintenance tasks
      performMaintenanceTasks()
      break
  }
})

addLowPowerListener(() => {
  // User enabled low power mode, reduce app functionality
  enableMinimalMode()
  pauseNonEssentialServices()
})
```

## Platform Support

### Android Implementation Details

- ✅ Full battery monitoring support
- ✅ Real-time battery state changes
- ✅ Low power mode detection (Android 5.0+)
- ✅ Battery level accuracy within 1%
- ✅ Works with all Android versions

### iOS Implementation Details

- ✅ Full battery monitoring support
- ✅ Real-time battery state changes  
- ✅ Low power mode detection (iOS 9.0+)
- ✅ Battery level accuracy within 1%
- ✅ Automatic battery monitoring management

## Troubleshooting

### Common Issues

#### Battery level returns -1 (iOS)

- This is normal on iOS Simulator (no battery)
- On real devices, ensure battery monitoring is enabled (handled automatically)

#### Battery state listeners not firing

- Verify listeners are properly added and stored
- Check that listeners are removed in cleanup functions
- Ensure the app has proper permissions (Android)

#### Memory leaks with listeners

- Always store listener IDs returned from add functions
- Remove listeners in component cleanup/unmount

## Migration Guide

### From other battery libraries

```ts
// Before (react-native-battery)
import { getBatteryLevel, isCharging } from 'react-native-battery'

// After (react-native-nitro-battery)
import { getLevel, isCharging } from 'react-native-nitro-battery'

// Most APIs are similar or improved
const level = getLevel() // Instead of getBatteryLevel()
const charging = isCharging() // Same API
```

### Adding event listeners

```ts
// Before (typical pattern with other libraries)
import { BatteryManager } from 'some-battery-library'

BatteryManager.addEventListener('batteryLevelChange', callback)

// After (react-native-nitro-battery)
import { addBatteryStateListener, removeBatteryStateListener } from 'react-native-nitro-battery'

 useEffect(() => {
  const subscription = state => {
    console.log('Battery state changed:', state);
  };
  addBatteryStateListener(subscription);
  return () => {
    removeBatteryStateListener(subscription);
  };
}, []);
```

## Type Definitions

```ts

// Listener function types
type BatteryListener = (state: string) => void
type LowPowerListener = () => void

// Main API interface
interface NitroBatterySpec {
  getLevel(): number
  isCharging(): boolean
  getBatteryState(): string
  isLowPowerModeEnabled(): boolean
  addBatteryStateListener(listener: BatteryListener): string
  removeBatteryStateListener(listener: BatteryListener): void
  addLowPowerListener(listener: LowPowerListener): string
  removeLowPowerListener(listener: LowPowerListener): void
}
```

## Contributing

See `CONTRIBUTING.md` for contribution workflow.

When updating spec files in `src/specs/*.nitro.ts`, regenerate Nitro artifacts:

```bash
yarn nitrogen
```

## Project Structure

- `android/` — Native Android implementation (Kotlin/Java)
- `ios/` — Native iOS implementation (Swift)
- `src/` — TypeScript source code and exports
- `nitrogen/` — Generated Nitro artifacts (auto-generated)
- `lib/` — Compiled JavaScript output

## Acknowledgements

Special thanks to the following projects that inspired this library:

- [mrousavy/nitro](https://github.com/mrousavy/nitro) – Nitro Modules architecture

## License

MIT © [Thành Công](https://github.com/tconns)
          
<a href="https://www.buymeacoffee.com/tconns94" target="_blank">
  <img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" width="200"/>
</a>
