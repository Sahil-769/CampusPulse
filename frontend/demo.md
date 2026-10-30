# Campus Pulse – Demo Guide

This is the MVP demo build for the Campus Pulse prototype. It focuses on the product vision described in the brief: campus event discovery, study buddy matching, and organizer tooling in a polished mobile-first interface.

## Included MVP Features

- Splash screen + branded onboarding flow
- Demo login and organizer role switch
- Student home dashboard with featured event and announcement cards
- Event discovery, filters, and event detail view
- Searchable event feed with category filters and saved-event bookmarks
- Event registration with capacity updates and a shared activity list
- Study buddy recommendations scored from subjects/skills (50%), goals (30%), and availability (20%)
- Explainable match detail screen with weighted score breakdown and shared-fit reasons
- Match requests tracked in activity and protected against duplicate sends
- My Activity screen with registered events and match requests
- Profile and settings screens
- Organizer workspace with event publishing, attendee registration management, and check-in
- Demo-only data flow for phone testing and product validation

## Demo Flow

1. Launch the app.
2. You will see the splash screen and then the auth screen.
3. Use one of the demo logins:
   - Student: student@campuspulse.edu / campus123
   - Organizer: organizer@campuspulse.edu / campus123
4. Explore the bottom navigation:
   - Home
   - Explore Events
   - Study Buddies
   - My Activity
   - Profile
5. Open a featured event and register from the details screen.
6. Search and filter the event feed, bookmark an event, then switch to saved events.
7. Visit Study Buddies to inspect the weighted compatibility breakdown and send a match request.
8. Use the Profile screen to edit account details and toggle visibility.
9. Log in as the organizer account to publish an event, review registrations, and check in an attendee.

## Test Checklist

- App launches without crashing
- Splash animation transitions properly
- Login works with demo credentials
- Bottom navigation switches screens correctly
- Events load and can be opened
- Search, category filters, and bookmarks update the feed
- Event registration updates capacity, event status, and activity
- Match score breakdown is mathematically consistent and requests are deduplicated
- Organizer publishing and attendee check-in update workspace metrics
- Profile editing is responsive
- Organizer workspace displays metrics and event cards
- Mobile layout remains readable on a phone-sized screen

## Run on Device

From the project root:

```bash
flutter pub get
flutter run
```

If using a physical Android phone:

```bash
flutter devices
flutter run -d <device-id>
```

## Notes

- This is a demo prototype, not a production auth or backend implementation.
- Shared Riverpod state uses seeded in-memory data and resets when the app process restarts.
- The architecture diagram's Serverpod/PostgreSQL deployment is proposed only; no backend service is wired into this app yet.
- The experience is designed to reflect the requested Campus Pulse MVP rather than a generic college dashboard.
- The app follows the product spec closely, while keeping the implementation focused on rapid demo validation.
