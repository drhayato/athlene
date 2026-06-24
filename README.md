# 🏃 Athlene

**Athlene** is a privacy-focused fitness tracking application built with Flutter that provides accurate step counting, distance tracking, and calorie estimation without requiring an internet connection or subscription.

Unlike many fitness applications, Athlene stores all user data locally, ensuring complete privacy while remaining fully functional in remote areas with limited or no network connectivity.

---

## 📥 Download

<p align="center">
  <a href="https://github.com/drhayato/athlene/releases/latest">
    <img src="https://img.shields.io/badge/⬇️%20Download-Latest%20APK-success?style=for-the-badge" />
  </a>
</p>

Athlene is a privacy-focused fitness tracking application built with Flutter that provides accurate step counting...  

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

> Analytics UI :
 <img width="1080" height="2400" alt="e1110e5c-4c57-45ba-961b-83229038296a" src="https://github.com/user-attachments/assets/bba6f80f-0a04-4bf1-8db6-156b6a7e54e6" />

> Map :
<img width="720" height="1600" alt="37eea5ee-35df-4e45-9865-d4e49043a5f2" src="https://github.com/user-attachments/assets/4d762ec0-b894-4e76-80e2-a84b26e000cd" />

> Login Interface :
<img width="1080" height="2400" alt="d39b6d86-d1a3-4403-8d50-d14fd5916171" src="https://github.com/user-attachments/assets/82907029-4c85-4071-a2a5-2f6a32e6b1f9" />


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

## 🚀 Running the Project (for developers)

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
