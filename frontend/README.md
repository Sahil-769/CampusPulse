# Campus Pulse

The Flutter app uses the generated Serverpod client from the backend workspace.

Start the backend from `campuse-pulse-backend\campus_pulse\campus_pulse_server`:

```powershell
serverpod start
```

Then run this app with `flutter run`. It connects to
`http://localhost:8080/` by default. For an Android emulator use
`--dart-define=CAMPUS_PULSE_SERVER_URL=http://10.0.2.2:8080/`; for a physical
device, use the computer's LAN IP instead of `localhost`.

A new Flutter project.
