# Product Requirement Document (PRD)

## Product Name
Smart Class Check-in & Learning Reflection App

## 1. Problem Statement
Lecturers need a simple way to verify that students are present in class and engaged in learning activities. Traditional attendance methods cannot confirm physical presence or participation quality. This app solves that by combining GPS validation, QR code scan, and short learning reflections before and after class.

## 2. Target Users
- Primary: University students attending class sessions
- Secondary: Lecturers/TAs who monitor attendance and class reflections

## 3. Product Goals (MVP)
- Verify attendance with time + location + class QR scan
- Collect short reflections to indicate class participation
- Store records reliably for later review

## 4. Scope
### In Scope (MVP)
- Home screen with navigation
- Before-class Check-in form
- After-class Finish Class form
- GPS capture
- QR code scanning (with manual fallback)
- Local data persistence (SQLite)

### Out of Scope (Future)
- Authentication and role management
- Cloud sync and analytics dashboard
- Attendance fraud detection rules

## 5. Feature List
1. Home Screen
- Entry point for all actions
- Quick access to Check-in and Finish Class
- List of saved records

2. Check-in (Before Class)
- Capture GPS location and timestamp
- Scan class QR code
- Input:
  - Previous class topic
  - Expected topic for today
  - Mood before class (1 to 5)

3. Finish Class (After Class)
- Capture GPS location and timestamp
- Scan class QR code again
- Input:
  - What student learned today
  - Feedback on class/instructor

4. Data Storage
- Save each event as a local SQLite record
- Support retrieval and listing on Home screen

## 6. User Flow
1. Student opens app -> Home screen
2. Student taps Check-in
3. App requests location permission (if needed)
4. Student captures GPS and scans QR
5. Student fills required fields and submits
6. App saves check-in record locally
7. At end of class, student taps Finish Class
8. Student repeats GPS + QR and submits reflection
9. App saves finish-class record locally

## 7. Data Fields
Each record stores:
- id (auto increment)
- type (`checkIn` or `finishClass`)
- timestamp (ISO datetime)
- latitude (double)
- longitude (double)
- qr_code (string)
- previous_topic (string, check-in only)
- expected_topic (string, check-in only)
- mood (int 1-5, check-in only)
- learned_today (string, finish only)
- feedback (string, finish only)

## 8. Non-Functional Requirements
- Easy-to-use form flow with simple validation
- Fast local persistence without internet dependency
- Works on Android device for MVP demo
- Clear permission handling feedback

## 9. Tech Stack
- Frontend: Flutter (Dart)
- GPS: geolocator package
- QR Scanner: mobile_scanner package
- Local Storage: SQLite via sqflite
- Deployment component: Firebase Hosting (Flutter web build or landing page)

## 10. Success Criteria (MVP)
- User can complete full check-in and finish-class flow
- Records are stored and visible in app
- GPS + QR + reflection fields are captured per requirement
- One component is deployable via Firebase Hosting
