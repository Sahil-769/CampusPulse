# Campus Pulse: Run on Android

Run the backend and Flutter app in separate PowerShell terminals. PostgreSQL is not required for this prototype.

## 1. Start the Serverpod Backend

In the first terminal:

```powershell
Set-Location "d:\coding_zone\Campus Pulse\campuse-pulse-backend\campus_pulse\campus_pulse_server"
serverpod start
```

Leave this terminal running. The Serverpod API listens on port `8080`.

## 2. Connect a Physical Android Phone

Enable Developer options and USB debugging on the phone, connect it to the computer with USB, and accept the debugging prompt. Connect both the phone and computer to the same Wi-Fi network.

In a second PowerShell terminal, check that Flutter can see the phone:

```powershell
Set-Location "d:\coding_zone\Campus Pulse\campus_pulse_frontend"
flutter pub get
flutter devices
```

Run the app, replacing `YOUR_DEVICE_ID` with the ID reported by `flutter devices`:

```powershell
flutter run -d CPH2127 --dart-define=CAMPUS_PULSE_SERVER_URL=http://192.168.2.111:8080/
```

`192.168.2.111` is the development computer's current Wi-Fi IPv4 address. If the computer's address changes, find its current Wi-Fi address with:

```powershell
ipconfig
```

Use the IPv4 address shown under the active Wi-Fi adapter in the `CAMPUS_PULSE_SERVER_URL` value. Do not use `localhost` for a physical phone: on the phone, `localhost` refers to the phone itself. Windows Firewall must allow connections to port `8080`.

## Android Emulator

For the Android emulator, the app defaults to the emulator's host alias `10.0.2.2` and port `8080`. In the second terminal:

```powershell
Set-Location "d:\coding_zone\Campus Pulse\campus_pulse_frontend"
flutter pub get
flutter run
```

If more than one device is available, list devices with `flutter devices` and specify one using `flutter run -d DEVICE_ID`.

## Prototype Data Notes

The backend uses in-memory data only. Registrations and organizer-created events reset when the Serverpod process restarts. The Flutter demo login and prototype student ID are not backend authentication or secure identity.
