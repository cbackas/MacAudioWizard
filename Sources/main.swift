import Foundation

setenv("OS_ACTIVITY_MODE", "disable", 1)

import CoreAudio

func defaultDeviceChanged(deviceId _: AudioObjectID, _: UInt32, _: UnsafePointer<AudioObjectPropertyAddress>, _: UnsafeMutableRawPointer?) -> OSStatus {
  // add a delay to allow the device defaults to fully settle before we change them
  DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
    let connectedDevices = getConnectedDevices()
    let currentDefaults = getCurrentDefaultDevices()

    // handle microphone  precedence
    setPreferredInputDevices(connectedDevices: connectedDevices, currentDefaults: currentDefaults)
    // setPreferredOutputoDevices(connectedDevices: connectedDevices, currentDefaults: currentDefaults)
  }
  return noErr
}

// we want to listen for changes to the default devices and the connected devices
addAudioPropertyListener(mSelector: kAudioHardwarePropertyDefaultOutputDevice, defaultDeviceChanged)
addAudioPropertyListener(mSelector: kAudioHardwarePropertyDevices, defaultDeviceChanged)
addAudioPropertyListener(mSelector: kAudioDevicePropertyStreamConfiguration, defaultDeviceChanged)

// Run the run loop to receive property change notifications
RunLoop.current.run()
