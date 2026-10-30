# Campus Pulse Deployment Guide

This guide covers the current Flutter + Serverpod prototype and what must be completed before a persistent public deployment. The backend currently uses in-memory repositories. **There is no PostgreSQL connection or persistence configured.** Registrations and organizer-created events reset when the Serverpod process restarts.

## Deployment Choices

| Part | Options | What gets deployed |
| --- | --- | --- |
| Flutter Android | Install a release APK directly, or publish an AAB through Google Play | Flutter application package |
| Flutter Web | Firebase Hosting, Cloudflare Pages, Netlify, Vercel static hosting, or another static host | Files from `campus_pulse_frontend/build/web` |
| Serverpod | Serverpod Cloud (where supported for the chosen Serverpod version), or a Linux/container service such as a VM, AWS ECS, Google Cloud Run, Azure Container Apps, or Kubernetes | Serverpod API container |
| PostgreSQL, later phase | Managed PostgreSQL such as AWS RDS, Cloud SQL, Azure Database for PostgreSQL, or another managed provider | Database service, private to the backend where possible |

For a first phone demo, install the Android release APK and keep the backend running on a reachable server or development computer. For a public demo, host the backend on a public HTTPS endpoint and point the Flutter build at that endpoint. A static Flutter web deployment still needs the Serverpod API to be reachable from the browser.

## Before Public Deployment

The current setup is a prototype, not a production-ready public service:

- The Serverpod models and repository are not connected to PostgreSQL; data is in memory only.
- The Flutter demo login and `prototypeStudentId` are not authentication or secure user identity. Do not expose registration or organizer operations publicly as though they are protected.
- `config/production.yaml` contains example hostnames that must be replaced with real domains and correct TLS/load-balancer settings.
- Review `campuse-pulse-backend/campus_pulse/campus_pulse_server/docker-compose.yaml` before using it. It contains hard-coded development database passwords. Do not deploy or reuse those values; rotate/remove them and use secret management before any real database deployment.
- Do not commit credentials, private keys, or production secrets.

## Flutter Android

Build an APK for direct installation on a test phone:

```powershell
Set-Location "d:\coding_zone\Campus Pulse\campus_pulse_frontend"
flutter pub get
flutter build apk --release --dart-define=CAMPUS_PULSE_SERVER_URL=https://api.example.com/
```

The APK is written under `build/app/outputs/flutter-apk/`. Replace `https://api.example.com/` with the deployed Serverpod API URL. For a real release, configure Android signing and protect the signing key; do not commit it.

Build an Android App Bundle for Google Play:

```powershell
flutter build appbundle --release --dart-define=CAMPUS_PULSE_SERVER_URL=https://api.example.com/
```

The AAB is written under `build/app/outputs/bundle/release/`. Upload it through the Google Play Console and follow its current signing, privacy, and store listing requirements.

## Flutter Web

Build the static web app from the Flutter project:

```powershell
Set-Location "d:\coding_zone\Campus Pulse\campus_pulse_frontend"
flutter pub get
flutter build web --release --dart-define=CAMPUS_PULSE_SERVER_URL=https://api.example.com/
```

Deploy the contents of `build/web` to a static hosting provider. Configure that host to serve `index.html` for app routes (SPA fallback). Use the HTTPS URL of the backend in `CAMPUS_PULSE_SERVER_URL`. Browser access may also require the backend's allowed-origin/CORS configuration to include the deployed frontend origin, especially when enabling cookie authentication later.

The generated Serverpod client is a local path dependency at `../campuse-pulse-backend/campus_pulse/campus_pulse_client`. Build from this workspace with both folders present; do not try to build the frontend from a checkout that omits the generated client package.

## Serverpod Backend: Docker

The Serverpod project already has a multi-stage `Dockerfile`. Build it from the workspace package root (`campuse-pulse-backend/campus_pulse`), because the Dockerfile copies the workspace lockfile and the server directory:

```powershell
Set-Location "d:\coding_zone\Campus Pulse\campuse-pulse-backend\campus_pulse"
docker build -f campus_pulse_server/Dockerfile -t campus-pulse-server:prototype .
```

For a local container smoke test, publish the API port:

```powershell
docker run --rm -p 8080:8080 campus-pulse-server:prototype
```

For a real host, push the image to a private container registry and deploy it using the provider's container service. Configure the service to route external HTTPS traffic to the container API port `8080`, set the correct production run mode and server host values, and configure health checks, logs, restart policy, resource limits, and TLS at the provider or reverse proxy. Do not expose database ports publicly.

The local `docker-compose.yaml` is for database services and is not required by the current in-memory backend. Do not run that compose file as a production deployment recipe.

To deploy without Docker, use the provider's supported Serverpod deployment workflow or package the Serverpod server for the target Linux host. Keep Serverpod, Dart, the generated client, and deployment tooling on compatible versions; this project is pinned to Serverpod `4.0.4`.

## PostgreSQL: Later Phase

PostgreSQL is the relational database Serverpod can use to persist events, registrations, profiles, and related records. Adding a database service alone will **not** make this app persistent: the current `InMemoryCampusPulseRepository` must be replaced by a PostgreSQL-backed implementation.

When you are ready to add it:

1. Choose a managed PostgreSQL provider and provision a database in a private network accessible to the Serverpod service. Restrict inbound database access to the backend, use TLS where supported, and create a least-privilege application user.
2. Keep the existing `CampusPulseRepository` API boundary. Implement a database-backed repository and wire it into the Serverpod endpoint setup. Avoid putting SQL/database access directly in Flutter or endpoint presentation logic.
3. Decide the persistent schema for events, event registrations, student profiles, study-buddy profiles, and any organizer ownership or match-request data. Add Serverpod table definitions and relationships to the appropriate model definitions (or separate database row models from public API DTOs).
4. Enforce uniqueness for an event/student registration pair, plus foreign keys and other integrity rules. Keep duplicate handling in the repository so the endpoint can return a clear duplicate error.
5. Add the database connection block to the appropriate environment config only when the database exists. Supply passwords and other secrets through Serverpod's supported secret/password mechanism or the hosting provider's secret manager, never as committed YAML values.
6. Generate and review Serverpod migrations, back up the database, and apply migrations to development/staging before production. Add integration tests that use the configured test database.
7. Deploy the server and database changes together, verify connection/health checks, and update backup, restore, monitoring, and data-retention procedures.
8. Add real Serverpod authentication and authorize student/organizer operations. Replace the client-provided prototype student ID with identity derived from an authenticated server session; a client-supplied ID is not secure.

Only after these changes should deployment documentation claim database persistence. Until then, the current in-memory implementation is suitable for local/prototype demonstrations only.

## Local Development Reminder

Start the backend from `campuse-pulse-backend/campus_pulse/campus_pulse_server` with `serverpod start`. Run Flutter from `campus_pulse_frontend`, using `--dart-define=CAMPUS_PULSE_SERVER_URL=...` when the backend is not at the platform default. For physical Android devices, use a reachable computer/server IP or HTTPS domain, never the phone's `localhost`.
