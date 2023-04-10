import CoreAudio

func setPreferredInputDevices(connectedDevices: [String: String], currentDefaults: (input: String, output: String)) {
  let audioCodecInput = "AppleUSBAudioEngine:Burr-Brown from TI              :USB Audio CODEC :5111000:2"
  let builtInInput = "BuiltInMicrophoneDevice"

  // handle microphone precedence
  if connectedDevices[audioCodecInput] != nil {
    if currentDefaults.input != audioCodecInput {
      print("Using USB Codec as input device")
      setDefaultDevice(deviceType: kAudioHardwarePropertyDefaultInputDevice, deviceUID: audioCodecInput)
    }
  } else {
    if currentDefaults.input != builtInInput {
      print("Using built-in microphone as input device")
      setDefaultDevice(deviceType: kAudioHardwarePropertyDefaultInputDevice, deviceUID: builtInInput)
    }
  }
}

// func setPreferredOutputoDevices(connectedDevices _: [String: String], currentDefaults _: (input: String, output: String)) {
//  trying to mange outputs sux
//  let audioCodecOutput = "AppleUSBAudioEngine:Burr-Brown from TI              :USB Audio CODEC :5111000:1"
//  let builtInOutput = "BuiltInSpeakerDevice"

//  let airpodProOutput = "5C-52-30-E6-64-48:output"
//  let airpodMaxOutput = "14-C8-8B-E6-71-BD:output"
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
// }
