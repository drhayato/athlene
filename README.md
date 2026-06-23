# 🏃 Athlene

**Athlene** is a privacy-focused fitness tracking application built with Flutter that provides accurate step counting, distance tracking, and calorie estimation without requiring an internet connection or subscription.

Unlike many fitness applications, Athlene stores all user data locally, ensuring complete privacy while remaining fully functional in remote areas with limited or no network connectivity.

---

## 📥 Download

> **Latest APK:**
> **[⬇️ Download Athlene v1.0.0](https://github.com/drhayato/athlene/releases/latest)**

> **Note:** Android may ask you to enable **Install from Unknown Sources** before installing the APK.

---

## ✨ Features

* 🚶 Accurate step tracking using device sensors
* 📍 GPS-based distance tracking
* 🔥 MET-based calorie estimation
* 🗺️ Interactive map integration
* 📈 Circular daily progress visualization
* 🌙 Automatic midnight reset for daily statistics
* 🔒 100% local data storage
* 📶 Works without an internet connection

---

## 📸 Screenshots

> *(Add screenshots here once available.)*

| Home       | Activity   | Statistics |
| ---------- | ---------- | ---------- |
| Screenshot | Screenshot | Screenshot |

---

## 🛠 Tech Stack

| Category      | Technology           |
| ------------- | -------------------- |
| Framework     | Flutter              |
| Language      | Dart                 |
| Step Tracking | pedometer            |
| Location      | geolocator           |
| Maps          | flutter_map          |
| Coordinates   | latlong2             |
| Storage       | Local Device Storage |

---

## 🧠 Core Algorithms

Athlene performs all calculations directly on the user's device without relying on cloud processing.

### Distance Calculation

* Haversine Formula
* Great-circle distance computation using GPS coordinates

### Calorie Estimation

* Metabolic Equivalent of Task (MET)
* Activity-based calorie estimation

### Tracking Logic

* Custom interval-based location recording
* Automatic daily statistics reset
* Singleton Location Service for efficient GPS management

---

## 📍 Designed for Offline Use

Athlene is intended for users who exercise in environments where internet connectivity is unreliable.

Examples include:

* Hiking
* Trekking
* Nature trails
* Hill stations
* Rural environments

Since every calculation is performed locally, the application remains fully functional even without cellular data or Wi-Fi.

---

## 🚀 Running the Project

Clone the repository

```bash
git clone https://github.com/drhayato/athlene.git
```

Install dependencies

```bash
flutter pub get
```

Run the application

```bash
flutter run
```

---

## 🔑 Required Permissions

Android

* ACTIVITY_RECOGNITION
* ACCESS_FINE_LOCATION
* ACCESS_COARSE_LOCATION

iOS

* Motion Usage
* Location Services

---

## 📄 License

This project is intended for educational and portfolio purposes.

---

### ❤️ Made by Hayato
