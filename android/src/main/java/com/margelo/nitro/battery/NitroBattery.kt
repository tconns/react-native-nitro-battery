package com.margelo.nitro.battery

import android.annotation.SuppressLint
import com.facebook.proguard.annotations.DoNotStrip
import android.content.*
import android.os.BatteryManager
import android.os.PowerManager
import com.margelo.nitro.NitroModules

@DoNotStrip
class NitroBattery : HybridNitroBatterySpec() {
  private val applicationContext = NitroModules.applicationContext
    ?: throw IllegalStateException("NitroModules.applicationContext is null")

  private val listeners = mutableListOf<(String) -> Unit>()
  private val lowPowerListeners = mutableListOf<() -> Unit>()

  override fun getLevel(): Double {
    val bm = applicationContext.getSystemService(Context.BATTERY_SERVICE) as BatteryManager
    return bm.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY).toDouble()
  }

  override fun isCharging(): Boolean {
    val intent = applicationContext.registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
    val status = intent?.getIntExtra(BatteryManager.EXTRA_STATUS, -1) ?: -1
    return status == BatteryManager.BATTERY_STATUS_CHARGING || status == BatteryManager.BATTERY_STATUS_FULL
  }

  override fun addBatteryStateListener(listener: (String) -> Unit) {
    listeners.add(listener)
    val filter = IntentFilter()
    filter.addAction(Intent.ACTION_BATTERY_CHANGED)
    applicationContext.registerReceiver(batteryReceiver, filter)
  }

  override fun removeBatteryStateListener(listener: (String) -> Unit) {
    listeners.remove(listener)
    if (listeners.isEmpty()) applicationContext.unregisterReceiver(batteryReceiver)
  }

  override fun addLowPowerListener(listener: () -> Unit) {
    lowPowerListeners.add(listener)
    val filter = IntentFilter(PowerManager.ACTION_POWER_SAVE_MODE_CHANGED)
    applicationContext.registerReceiver(lowPowerReceiver, filter)
  }

  override fun removeLowPowerListener(listener: () -> Unit) {
    lowPowerListeners.remove(listener)
    if (lowPowerListeners.isEmpty()) applicationContext.unregisterReceiver(lowPowerReceiver)
  }

  private val batteryReceiver = object : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
      val status = intent?.getIntExtra(BatteryManager.EXTRA_STATUS, -1) ?: -1
      val state = when (status) {
        BatteryManager.BATTERY_STATUS_CHARGING -> "charging"
        BatteryManager.BATTERY_STATUS_FULL -> "full"
        BatteryManager.BATTERY_STATUS_DISCHARGING -> "discharging"
        else -> "unknown"
      }
      listeners.forEach { it(state) }
    }
  }

  private val lowPowerReceiver = object : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
      lowPowerListeners.forEach { it() }
    }
  }

  override fun getBatteryState(): String {
    val intent = applicationContext.registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
    val status = intent?.getIntExtra(BatteryManager.EXTRA_STATUS, -1) ?: -1
    return when (status) {
      BatteryManager.BATTERY_STATUS_CHARGING -> "charging"
      BatteryManager.BATTERY_STATUS_FULL -> "full"
      BatteryManager.BATTERY_STATUS_DISCHARGING -> "discharging"
      else -> "unknown"
    }
  }

  override fun isLowPowerModeEnabled(): Boolean {
    val pm = applicationContext.getSystemService(Context.POWER_SERVICE) as PowerManager
    return pm.isPowerSaveMode
  }
}
