//
//  HybridNitroBattery.swift
//  Pods
//
//  Created by tconns94 on 22/09/2025.
//

import UIKit

class NitroBattery: HybridNitroBatterySpec {
  private var batteryStateListeners: [String: (String) -> Void] = [:]
  private var lowPowerListeners: [String: () -> Void] = [:]
  private var listenerIdCounter: Int = 0
  private let listenerQueue = DispatchQueue(label: "com.nitrobattery.listeners", attributes: .concurrent)

  override init() {
    super.init()
    setupBatteryMonitoring()
    setupNotificationObservers()
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
    UIDevice.current.isBatteryMonitoringEnabled = false
  }
  
  // MARK: - Setup Methods
  
  private func setupBatteryMonitoring() {
    UIDevice.current.isBatteryMonitoringEnabled = true
  }
  
  private func setupNotificationObservers() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(batteryStateDidChange),
      name: UIDevice.batteryStateDidChangeNotification,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(batteryLevelDidChange),
      name: UIDevice.batteryLevelDidChangeNotification,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(lowPowerModeChanged),
      name: Notification.Name.NSProcessInfoPowerStateDidChange,
      object: nil
    )
  }

  // MARK: - Public API
  
  func getLevel() -> Double {
    let level = UIDevice.current.batteryLevel
    // Return -1 if battery level is unavailable
    return level < 0 ? -1 : Double(level * 100)
  }

  func isCharging() -> Bool {
    let state = UIDevice.current.batteryState
    return state == .charging || state == .full
  }
  
  func getBatteryState() -> String {
    return getCurrentBatteryState()
  }
  
  func isLowPowerModeEnabled() -> Bool {
    return ProcessInfo.processInfo.isLowPowerModeEnabled
  }

  func addBatteryStateListener(listener: @escaping (String) -> Void) -> String {
    return listenerQueue.sync(flags: .barrier) {
      listenerIdCounter += 1
      let listenerId = "battery_\(listenerIdCounter)"
      batteryStateListeners[listenerId] = listener
      return listenerId
    }
  }

  func removeBatteryStateListener(listenerId: String) {
    listenerQueue.async(flags: .barrier) {
      self.batteryStateListeners.removeValue(forKey: listenerId)
    }
  }

  func addLowPowerListener(listener: @escaping () -> Void) -> String {
    return listenerQueue.sync(flags: .barrier) {
      listenerIdCounter += 1
      let listenerId = "lowpower_\(listenerIdCounter)"
      lowPowerListeners[listenerId] = listener
      return listenerId
    }
  }

  func removeLowPowerListener(listenerId: String) {
    listenerQueue.async(flags: .barrier) {
      self.lowPowerListeners.removeValue(forKey: listenerId)
    }
  }
  
  func removeAllListeners() {
    listenerQueue.async(flags: .barrier) {
      self.batteryStateListeners.removeAll()
      self.lowPowerListeners.removeAll()
    }
  }
  
  // MARK: - Private Helper Methods
  
  private func getCurrentBatteryState() -> String {
    switch UIDevice.current.batteryState {
    case .charging:
      return "charging"
    case .full:
      return "full"
    case .unplugged:
      return "discharging"
    case .unknown:
      return "unknown"
    @unknown default:
      return "unknown"
    }
  }
  
  private func notifyBatteryStateListeners(state: String) {
    listenerQueue.async {
      let listeners = self.batteryStateListeners.values
      DispatchQueue.main.async {
        listeners.forEach { $0(state) }
      }
    }
  }
  
  private func notifyLowPowerListeners() {
    listenerQueue.async {
      let listeners = self.lowPowerListeners.values
      DispatchQueue.main.async {
        listeners.forEach { $0() }
      }
    }
  }

  // MARK: - Notification Handlers
  
  @objc private func batteryStateDidChange() {
    let state = getCurrentBatteryState()
    notifyBatteryStateListeners(state: state)
  }

  @objc private func batteryLevelDidChange() {
    // Optionally notify about level changes
    let state = getCurrentBatteryState()
    notifyBatteryStateListeners(state: state)
  }

  @objc private func lowPowerModeChanged() {
    if ProcessInfo.processInfo.isLowPowerModeEnabled {
      notifyLowPowerListeners()
    }
  }

  func getBatteryState() -> String {
    switch UIDevice.current.batteryState {
      case .charging: return "charging"
      case .full: return "full"
      case .unplugged: return "discharging"
      default: return "unknown"
    }
  }

  func isLowPowerModeEnabled() -> Bool {
    return ProcessInfo.processInfo.isLowPowerModeEnabled
  }
}
