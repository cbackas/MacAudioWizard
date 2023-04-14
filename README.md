# MacAudioWizard

MacAudioWizard is a simple command-line application for macOS that helps you manage your default audio input devices. When you connect a new audio output device, such as AirPods, it automatically selects the highest-priority microphone from a predefined list, ultimately aiming to disable the use of the AirPods' microphone.

## Features

- Listens for changes in the default audio output device
- Automatically selects the highest-priority microphone from a predefined list when connecting a new device
- Runs in the background with minimal resource usage

## Installation

1. Download the latest release from the [Releases](https://github.com/username/MacAudioWizard/releases) page.
2. Extract the downloaded archive.
3. Move the `MacAudioWizard` executable to a directory of your choice.
4. Run the `MacAudioWizard` executable from the command line (or schedule a background job with launchd definition.)

## Usage

To use MacAudioWizard, simply run the executable from the command line: `./MacAudioWizard`

## Development Commands:
`build`: `swift build`

`run`: `swift run`

`build release`: `swift build -c release`

## License

MacAudioWizard is released under the [MIT License](LICENSE).
