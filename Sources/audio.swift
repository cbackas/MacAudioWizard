import CoreAudio
import Foundation

// adds a listener to the given property
// mSelector: the property to listen to
// callback: the function to call when the property changes
func addAudioPropertyListener(mSelector: AudioObjectPropertySelector, _ callback: @escaping AudioObjectPropertyListenerProc) {
  var propertyAddress = AudioObjectPropertyAddress(
    mSelector: mSelector,
    mScope: kAudioObjectPropertyScopeGlobal,
    mElement: kAudioObjectPropertyElementMain
  )
  AudioObjectAddPropertyListener(
    AudioObjectID(kAudioObjectSystemObject),
    &propertyAddress,
    callback,
    nil
  )
}

// set the default device for the given device type
// deviceType: kAudioHardwarePropertyDefaultInputDevice or kAudioHardwarePropertyDefaultOutputDevice
// deviceUID: the UID of the device to set as the default
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

// get the UIDs of the current default devices
// returns a tuple of (input: String, output: String)
func getCurrentDefaultDevices() -> (input: String, output: String) {
  let (inputDeviceId, outputDeviceId) = getDefaultDeviceIDs()

  let inputDeviceUID = getDeviceUID(deviceId: inputDeviceId)
  let outputDeviceUID = getDeviceUID(deviceId: outputDeviceId)

  return (input: inputDeviceUID, output: outputDeviceUID)
}

// get the IDs of the current default devices
// returns a tuple of (input: AudioDeviceID, output: AudioDeviceID)
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

// get the UID of the given device
// deviceId: the ID of the device to get the UID of
// returns the UID of the device
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

// get all connected audio devices
// returns a dictionary of device names and UIDs
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
