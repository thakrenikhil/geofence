# Geofence Attendance App — Project Specification with Commit Checkpoints

**Goal:** Create a cross-platform, multilingual, responsive **Flutter** application (mobile, web, desktop) that implements geofence-based attendance tracking for employees and an admin portal to manage offices, track attendance, and export reports (Excel/CSV). Use **Firebase**, **GCP**, and **Google Maps API**.

---

## Step 1: Project Initialization ✅
- Create Flutter project
- Add dependencies: `firebase_core`, `firebase_auth`, `cloud_firestore`, `cloud_functions`, `firebase_messaging`, `google_maps_flutter`, `geolocator`, `geofence_service`, `intl`, `flutter_localizations`, `excel`
- Initialize Firebase with `flutterfire configure`
- Commit message: **"chore: initialize Flutter project with dependencies"**

---

## Step 2: Authentication Module 🔑
- Implement login/signup using Firebase Auth
- Role-based access (admin/employee) using custom claims or Firestore roles
- Commit message: **"feat: add authentication with role-based access"**

---

## Step 3: Geofence Service 🌐
- Integrate Google Maps API & geofencing package
- Implement background location handling & permissions
- Commit message: **"feat: add geofencing and Google Maps integration"**

---

## Step 4: Employee Attendance Flow 🕒
- Clock-in/out detection via geofence triggers
- Manual fallback check-in/out
- Store records in Firestore
- Commit message: **"feat: implement attendance tracking and manual fallback"**

---

## Step 5: Admin Portal 📊
- Create/edit offices with geofences
- Assign employees to offices
- Live attendance dashboard
- Commit message: **"feat: add admin portal with office management"**

---

## Step 6: Reporting & Export 📄
- Generate Excel/CSV reports (client or Cloud Functions)
- Commit message: **"feat: implement report generation and export"**

---

## Step 7: Localization 🌍
- Add `intl` and ARB files for English + other languages. In this scaffold, a simple localization service is provided with English and Hindi and can be swapped to ARB-based `flutter gen-l10n` later.
- Commit message: **"feat: add multilingual support"**

---

## Step 8: Responsive Design 📱💻
- Use `LayoutBuilder`, `MediaQuery`, and adaptive widgets
- Commit message: **"style: implement responsive UI for all platforms"**

---

## Step 9: CI/CD Setup ⚙️
- GitHub Actions / Codemagic for automated builds
- Commit message: **"chore: setup CI/CD for multi-platform deployment"**

---

## Step 10: Testing 🧪
- Unit tests for logic
- Integration tests for flows
- Commit message: **"test: add unit and integration tests"**

