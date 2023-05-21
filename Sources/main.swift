import Foundation
import CoreAudio
import SwiftyBeaver

// setenv("OS_ACTIVITY_MODE", "disable", 1)

let log = SwiftyBeaver.self

let console = ConsoleDestination()  // log to Xcode Console in color

let file = FileDestination()  // log to default swiftybeaver.log file
let logFilePath = (NSHomeDirectory() as NSString).appendingPathComponent("logs/macaudiowizard.log")
file.logFileURL = URL(fileURLWithPath: logFilePath)

log.addDestination(console)
log.addDestination(file)

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


log.info("Creating audio device listeners...")
// we want to listen for changes to the default devices and the connected devices
addAudioPropertyListener(mSelector: kAudioHardwarePropertyDefaultOutputDevice, defaultDeviceChanged)
addAudioPropertyListener(mSelector: kAudioHardwarePropertyDevices, defaultDeviceChanged)
addAudioPropertyListener(mSelector: kAudioDevicePropertyStreamConfiguration, defaultDeviceChanged)
log.info("Listeners created!")

// Run the run loop to receive property change notifications
RunLoop.current.run()
