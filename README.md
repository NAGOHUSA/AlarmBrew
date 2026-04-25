# AlarmBrew ☕

An iOS alarm clock app that won't let you snooze — you have to **take a photo of your coffee maker** to dismiss it.

## Features

- **Alarm management** — create, edit, delete, and toggle alarms
- **Repeating alarms** — set alarms to repeat on any combination of days of the week
- **Coffee Maker Challenge** — when the alarm fires, you must photograph your coffee maker (validated by Apple's on-device Vision framework) to dismiss it
- **Loud alarm sound** — plays a bundled audio file (or a system fallback) even when the app is in the foreground
- **Camera fallback** — uses the photo library when running in the Simulator (no camera hardware required for development)

## Project Structure

```
AlarmBrew/
├── AlarmBrew.xcodeproj/           Xcode project
├── AlarmBrew/
│   ├── AlarmBrewApp.swift         App entry point (@main)
│   ├── AppDelegate.swift          Notification delegate & audio session setup
│   ├── ContentView.swift          Root view — shows alarm list / active alarm
│   ├── Models/
│   │   └── Alarm.swift            Codable Alarm model
│   ├── Views/
│   │   ├── AlarmListView.swift    Alarm list + row
│   │   ├── AddAlarmView.swift     Add / edit alarm sheet
│   │   ├── ActiveAlarmView.swift  Full-screen active alarm + photo challenge
│   │   └── CameraPickerView.swift UIImagePickerController SwiftUI wrapper
│   ├── ViewModels/
│   │   └── AlarmViewModel.swift   CRUD, persistence (UserDefaults), audio
│   └── Services/
│       ├── AlarmScheduler.swift   UNUserNotification scheduling / cancellation
│       └── ImageRecognitionService.swift  Vision-based coffee-maker detection
├── AlarmBrewTests/
│   └── AlarmBrewTests.swift       Unit tests for Alarm model
└── AlarmBrewUITests/
    └── AlarmBrewUITests.swift     Basic UI smoke tests
```

## Requirements

| Requirement | Value |
|---|---|
| iOS deployment target | **iOS 16.0** |
| Swift | **5.9+** |
| Xcode | **14.2+** |
| Frameworks | SwiftUI · UIKit · Vision · AVFoundation · UserNotifications · AudioToolbox |

## How to Open in Xcode

1. Clone or download this repository.
2. Open **`AlarmBrew.xcodeproj`** in Xcode.
3. Select a Simulator or your physical device as the run target.
4. Press **⌘R** to build and run.

> **Note:** On a physical device you may need to set a Development Team under  
> *Signing & Capabilities → Team* for the `AlarmBrew`, `AlarmBrewTests`, and  
> `AlarmBrewUITests` targets.

## Optional: Alarm Sound

Place an audio file named **`alarm.mp3`** (or `alarm.caf`) in the `AlarmBrew/` folder and add it to the **Resources** build phase. If no file is found, the app falls back to a system sound.

## Optional: Critical Alerts

To allow the alarm to fire with maximum volume even when the device is in Silent mode, apply for Apple's **Critical Alerts** entitlement at  
<https://developer.apple.com/contact/request/notifications-critical-alerts-entitlement/>.  
Once approved, add the entitlement to the app target and change `AlarmScheduler.schedule(_:)` to use `UNNotificationSound.defaultCritical`.

## How the Coffee-Maker Challenge Works

1. The alarm fires (via `UNCalendarNotificationTrigger`).
2. The app presents `ActiveAlarmView` full-screen, plays the alarm sound, and shows a **Take Photo** button.
3. The user points their camera at the coffee maker and takes a photo.
4. `ImageRecognitionService` runs `VNClassifyImageRequest` **on-device** (no network required) and checks the top-20 classification labels for coffee-related terms.
5. If a match is found, the alarm sound stops and the view dismisses.  
   If no match, the user can try again.

## Privacy

All image analysis is performed **entirely on-device** using Apple's Vision framework. No images are ever sent to a server or stored persistently.

## Permissions Required

| Permission | Purpose |
|---|---|
| `NSCameraUsageDescription` | Take a photo of your coffee maker to dismiss the alarm |
| `NSPhotoLibraryUsageDescription` | Simulator fallback (photo library) |
| Notification permission | Scheduling and delivering alarms |
