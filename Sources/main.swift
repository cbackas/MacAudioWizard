import Foundation

setenv("OS_ACTIVITY_MODE", "disable", 1)

import CoreAudio

func setDefaultDevice(deviceType: AudioObjectPropertySelector, deviceUID: String) {
  let propertySize = UInt32(MemoryLayout<AudioDeviceID>.size)
  var deviceList: [AudioDeviceID] = []
  var devicesDataSize: UInt32 = 0

  var getInputDevicesProperty = AudioObjectPropertyAddress(
    mSelector: kAudioHardwarePropertyDevices,
    mScope: kAudioObjectPropertyScopeGlobal,
    mElement: kAudioObjectPropertyElementMain
  )

  AudioObjectGetPropertyDataSize(AudioObjectID(kAudioObjectSystemObject), &getInputDevicesProperty, 0, nil, &devicesDataSize)

  let deviceCount = Int(devicesDataSize / propertySize)
  deviceList = Array(repeating: AudioDeviceID(), count: deviceCount)

  AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &getInputDevicesProperty, 0, nil, &devicesDataSize, &deviceList)

  for var deviceId in deviceList {
    var deviceUIDString: CFString = "" as CFString
    var deviceUIDSize = UInt32(MemoryLayout.size(ofValue: deviceUIDString))
    var getDeviceUIDProperty = AudioObjectPropertyAddress(
      mSelector: kAudioDevicePropertyDeviceUID,
      mScope: kAudioObjectPropertyScopeGlobal,
      mElement: kAudioObjectPropertyElementMain
    )
    AudioObjectGetPropertyData(deviceId, &getDeviceUIDProperty, 0, nil, &deviceUIDSize, &deviceUIDString)

    if deviceUIDString as String == deviceUID {
      var setDefaultDeviceProperty = AudioObjectPropertyAddress(
        mSelector: deviceType,
        mScope: kAudioObjectPropertyScopeGlobal,
        mElement: kAudioObjectPropertyElementMain
      )
      AudioObjectSetPropertyData(AudioObjectID(kAudioObjectSystemObject), &setDefaultDeviceProperty, 0, nil, UInt32(MemoryLayout.size(ofValue: deviceId)), &deviceId)
      break
    }
  }
}

func getCurrentDefaultDevices() -> (input: String, output: String) {
  let (inputDeviceId, outputDeviceId) = getDefaultDeviceIDs()

  let inputDeviceUID = getDeviceUID(deviceId: inputDeviceId)
  let outputDeviceUID = getDeviceUID(deviceId: outputDeviceId)

  return (input: inputDeviceUID, output: outputDeviceUID)
}

func getDefaultDeviceIDs() -> (input: AudioDeviceID, output: AudioDeviceID) {
  var inputDeviceId = AudioDeviceID(0)
  var outputDeviceId = AudioDeviceID(0)
  var deviceIdSize = UInt32(MemoryLayout.size(ofValue: inputDeviceId))

  var getDefaultInputDeviceProperty = AudioObjectPropertyAddress(
    mSelector: kAudioHardwarePropertyDefaultInputDevice,
    mScope: kAudioObjectPropertyScopeGlobal,
    mElement: kAudioObjectPropertyElementMain
  )

  var getDefaultOutputDeviceProperty = AudioObjectPropertyAddress(
    mSelector: kAudioHardwarePropertyDefaultOutputDevice,
    mScope: kAudioObjectPropertyScopeGlobal,
    mElement: kAudioObjectPropertyElementMain
  )

  AudioObjectGetPropertyData(
    AudioObjectID(kAudioObjectSystemObject),
    &getDefaultInputDeviceProperty,
    0,
    nil,
    &deviceIdSize,
    &inputDeviceId
  )

  AudioObjectGetPropertyData(
    AudioObjectID(kAudioObjectSystemObject),
    &getDefaultOutputDeviceProperty,
    0,
    nil,
    &deviceIdSize,
    &outputDeviceId
  )

  return (input: inputDeviceId, output: outputDeviceId)
}

func getDeviceUID(deviceId: AudioDeviceID) -> String {
  var deviceUIDString: CFString = "" as CFString
  var deviceUIDSize = UInt32(MemoryLayout.size(ofValue: deviceUIDString))
  var getDeviceUIDProperty = AudioObjectPropertyAddress(
    mSelector: kAudioDevicePropertyDeviceUID,
    mScope: kAudioObjectPropertyScopeGlobal,
    mElement: kAudioObjectPropertyElementMain
  )
  AudioObjectGetPropertyData(deviceId, &getDeviceUIDProperty, 0, nil, &deviceUIDSize, &deviceUIDString)

  return deviceUIDString as String
}

func getConnectedDevices() -> [String: String] {
  let propertySize = UInt32(MemoryLayout<AudioDeviceID>.size)
  var deviceList: [AudioDeviceID] = []
  var devicesDataSize: UInt32 = 0
  var deviceInfo: [String: String] = [:]

  var getInputDevicesProperty = AudioObjectPropertyAddress(
    mSelector: kAudioHardwarePropertyDevices,
    mScope: kAudioObjectPropertyScopeGlobal,
    mElement: kAudioObjectPropertyElementMain
  )

  AudioObjectGetPropertyDataSize(AudioObjectID(kAudioObjectSystemObject), &getInputDevicesProperty, 0, nil, &devicesDataSize)

  let deviceCount = Int(devicesDataSize / propertySize)
  deviceList = Array(repeating: AudioDeviceID(), count: deviceCount)

  AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &getInputDevicesProperty, 0, nil, &devicesDataSize, &deviceList)

  for deviceId in deviceList {
    var deviceUIDString: CFString = "" as CFString
    var deviceUIDSize = UInt32(MemoryLayout.size(ofValue: deviceUIDString))
    var getDeviceUIDProperty = AudioObjectPropertyAddress(
      mSelector: kAudioDevicePropertyDeviceUID,
      mScope: kAudioObjectPropertyScopeGlobal,
      mElement: kAudioObjectPropertyElementMain
    )
    AudioObjectGetPropertyData(deviceId, &getDeviceUIDProperty, 0, nil, &deviceUIDSize, &deviceUIDString)

    var deviceName: CFString = "" as CFString
    var deviceNameSize = UInt32(MemoryLayout.size(ofValue: deviceName))
    var getDeviceNameProperty = AudioObjectPropertyAddress(
      mSelector: kAudioDevicePropertyDeviceNameCFString,
      mScope: kAudioObjectPropertyScopeGlobal,
      mElement: kAudioObjectPropertyElementMain
    )
    AudioObjectGetPropertyData(deviceId, &getDeviceNameProperty, 0, nil, &deviceNameSize, &deviceName)

    deviceInfo[deviceUIDString as String] = deviceName as String
  }

  return deviceInfo
}

func setPreferredAudioDevices() {
  let audioCodecInput = "AppleUSBAudioEngine:Burr-Brown from TI              :USB Audio CODEC :5111000:2"
//  let audioCodecOutput = "AppleUSBAudioEngine:Burr-Brown from TI              :USB Audio CODEC :5111000:1"

  let builtInInput = "BuiltInMicrophoneDevice"
//  let builtInOutput = "BuiltInSpeakerDevice"

//  let airpodProOutput = "5C-52-30-E6-64-48:output"
//  let airpodMaxOutput = "14-C8-8B-E6-71-BD:output"

  let connectedDevices = getConnectedDevices()
//  let currentDefaults = getCurrentDefaultDevices()

  // handle microphone precedence
  if connectedDevices[audioCodecInput] != nil {
    print("Using USB Codec as input device")
    setDefaultDevice(deviceType: kAudioHardwarePropertyDefaultInputDevice, deviceUID: audioCodecInput)
  } else {
    print("Using built-in microphone as input device")
    setDefaultDevice(deviceType: kAudioHardwarePropertyDefaultInputDevice, deviceUID: builtInInput)
  }

// trying to mange outputs sux
//  // handle output precedence
//  if connectedDevices[airpodMaxOutput] != nil || connectedDevices[airpodProOutput] != nil {
//    // check if one of the airpods are already being used, then just keep using them, else use Max then Pro
//    if currentDefaults.output == airpodMaxOutput || currentDefaults.output == airpodProOutput {
//      print("Already using AirPods as output device")
//    } else if connectedDevices[airpodMaxOutput] != nil {
//      print("Using AirPod Max as output device")
//      setDefaultDevice(deviceType: kAudioHardwarePropertyDefaultOutputDevice, deviceUID: airpodMaxOutput)
//    } else {
//      print("Using AirPod Pro as output device")
//      setDefaultDevice(deviceType: kAudioHardwarePropertyDefaultOutputDevice, deviceUID: airpodProOutput)
//    }
//    // fall back to the desk headphones if possible
//  } else if connectedDevices[audioCodecOutput] != nil {
//    print("Using USB Codec as output device")
//    setDefaultDevice(deviceType: kAudioHardwarePropertyDefaultOutputDevice, deviceUID: audioCodecOutput)
//    // finally fall back to the built in speakers
//  } else {
//    print("Using built-in speakers as output device")
//    setDefaultDevice(deviceType: kAudioHardwarePropertyDefaultOutputDevice, deviceUID: builtInOutput)
//  }
}

func defaultDeviceChanged(deviceId: AudioObjectID, _: UInt32, _: UnsafePointer<AudioObjectPropertyAddress>, _: UnsafeMutableRawPointer?) -> OSStatus {
  DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
    setPreferredAudioDevices()
  }
  return noErr
}

// Add a property listener for the kAudioHardwarePropertyDefaultOutputDevice property
var addListenerPropertyConnected = AudioObjectPropertyAddress(
  mSelector: kAudioHardwarePropertyDevices,
  mScope: kAudioObjectPropertyScopeGlobal,
  mElement: kAudioObjectPropertyElementMain
)
AudioObjectAddPropertyListener(
  AudioObjectID(kAudioObjectSystemObject),
  &addListenerPropertyConnected,
  defaultDeviceChanged,
  nil
)

var addListenerPropertyDefaults = AudioObjectPropertyAddress(
  mSelector: kAudioHardwarePropertyDefaultOutputDevice,
  mScope: kAudioObjectPropertyScopeGlobal,
  mElement: kAudioObjectPropertyElementMain
)
AudioObjectAddPropertyListener(
  AudioObjectID(kAudioObjectSystemObject),
  &addListenerPropertyDefaults,
  defaultDeviceChanged,
  nil
)

// Run the run loop to receive property change notifications
RunLoop.current.run()

