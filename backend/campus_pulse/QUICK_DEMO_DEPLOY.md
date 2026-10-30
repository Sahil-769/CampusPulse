# Campus Pulse Quick Demo Deployment

Use this checklist for a judge demo. The backend is Serverpod 4.0.4 and currently uses seeded in-memory data. Events, sample registrations, and buddy profiles are returned by the API, but changes reset when the backend process restarts. Demo login is not real authentication.

## 1. Start Serverpod Locally

Open a PowerShell terminal:

```powershell
Set-Location "D:\coding_zone\Campus Pulse\campuse-pulse-backend\campus_pulse\campus_pulse_server"
serverpod start
```

Leave this terminal running. The API listens on port `8080` in development mode.

## 2. Run Flutter on the Same Computer

In a second terminal:

```powershell
Set-Location "D:\coding_zone\Campus Pulse\campus_pulse_frontend"
flutter pub get
flutter run --dart-define=CAMPUS_PULSE_SERVER_URL=http://localhost:8080/
```

For an Android emulator, use its host alias:

```powershell
flutter run -d <emulator-id> --dart-define=CAMPUS_PULSE_SERVER_URL=http://10.0.2.2:8080/
```

For a physical Android phone, connect the phone and computer to the same Wi-Fi, find the computer's IPv4 address with `ipconfig`, and use that address instead of `localhost`:

```powershell
flutter run -d <phone-device-id> --dart-define=CAMPUS_PULSE_SERVER_URL=http://192.168.1.25:8080/
```

Replace the example address with the computer's actual IPv4 address. Allow inbound TCP port `8080` through Windows Defender Firewall for the demo network. Do not use the phone's own `localhost` address.

## 3. Confirm the Live Demo Flow

1. Sign in with the built-in demo account shown on the login screen.
2. Confirm the backend status indicator reports connected and the Explore tab shows the backend event catalog.
3. Open an event and register with the demo student account. The frontend sends the registration to Serverpod.
4. Open Study Buddies. The recommendations and scores are returned by the backend matching endpoint.
5. Sign in as the organizer demo account and create an event. It is returned by the backend API until the server restarts.

The presenter account starts without registrations so the registration flow can be demonstrated. Other sample IDs have seeded registrations for API/demo testing.

## 4. Build an Android APK

The frontend depends on the generated client at `../campuse-pulse-backend/campus_pulse/campus_pulse_client`, so keep both workspace folders checked out in their current relative locations while building.

```powershell
Set-Location "D:\coding_zone\Campus Pulse\campus_pulse_frontend"
flutter pub get
flutter build apk --release --dart-define=CAMPUS_PULSE_SERVER_URL=https://YOUR_PUBLIC_SERVER_HOST/
```

Find the APK at `build\app\outputs\flutter-apk\app-release.apk`. Install it on the phone and ensure the backend URL is publicly reachable over HTTPS. A local `192.168.x.x` address works only on the same network and is not suitable for a judge's separate network.

## 5. Deploy the Backend Container

The checked-in Dockerfile builds from the backend workspace root. First set the API host in `campus_pulse_server/config/production.yaml` to the real public API domain and keep the public port/scheme set to `443`/`https`. Do not deploy the example `api.examplepod.com` hostname unchanged.

Build the image:

```powershell
Set-Location "D:\coding_zone\Campus Pulse\campuse-pulse-backend\campus_pulse"
docker build -f campus_pulse_server/Dockerfile -t campus-pulse-server:demo .
```

Push `campus-pulse-server:demo` to a container registry, then deploy it on a container host. Configure the host to route HTTPS requests to container port `8080`, keep the service running as a single instance for this in-memory demo, and configure its health check/logs. Do not expose ports `8081` or `8082` unless the deployment specifically uses Insights or the web server. The local database compose file is not needed for this prototype.

After deployment, rebuild the Flutter APK using the public HTTPS URL in `CAMPUS_PULSE_SERVER_URL`. For Flutter Web, use:

```powershell
Set-Location "D:\coding_zone\Campus Pulse\campus_pulse_frontend"
flutter build web --release --dart-define=CAMPUS_PULSE_SERVER_URL=https://YOUR_PUBLIC_SERVER_HOST/
```

Deploy `build\web` to a static web host with SPA route fallback. Browser access may need the deployed web origin added to Serverpod's allowed-origin configuration.

## Demo Limitations

- All backend state is in memory; a restart resets created events and registrations.
- Login and organizer roles are frontend demo behavior, not secure identity or authorization.
- Do not use real student data or present this deployment as production-ready. Add PostgreSQL persistence, authentication, authorization, HTTPS, and secret management before a public production release.
