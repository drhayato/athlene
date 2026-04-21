Athlene 🏃‍♂️
Athlene is a high-performance, privacy-focused fitness tracking application built with Flutter. Unlike mainstream fitness apps, Athlene is designed to be completely free of "Premium" paywalls and functions entirely offline.

By leveraging local hardware sensors and efficient mathematical algorithms, Athlene provides accurate step counting, distance tracking, and calorie estimation even in the most remote areas—like hill stations—where internet connectivity is unavailable.

🌟 Key Features
Zero-Internet Dependency: Works perfectly in remote areas with no cellular data or Wi-Fi.

Precision Tracking: Uses a custom dot-drop system every 3-5 meters with manual displacement override.

Privacy First: All health and location data is stored locally on your device.

Visual Progress: Features a custom circular progress algorithm for real-time goal visualization.

Smart Resets: Implements a Midnight Reset Algorithm to ensure your daily stats start fresh every 24 hours.

🛠 Tech Stack
Frontend: Flutter

Sensors: pedometer for step counting, geolocator for GPS coordinates.

Mapping: flutter_maps with latlong2 for handling geographical data.

Local Data: Entirely local storage architecture (No Cloud required).

🧮 Core Algorithms & Logic
Athlene relies on industry-standard mathematical formulas to ensure accuracy without server-side processing:

Distance Calculation: Implements the Haversine Formula to calculate the great-circle distance between latitude and longitude points.

Calorie Counting: Uses the Metabolic Equivalent of Task (MET) values to estimate energy expenditure based on activity intensity and user displacement.

Interval Recording: A custom Time-Based Interval Algorithm captures distance data at specific time steps to provide detailed performance breakdown.

Architecture: Built using a Singleton Location Service to manage a single, consistent stream of location data throughout the app lifecycle.

🚀 Installation & Setup
Clone the repository

Bash
git clone https://github.com/drhayato/athlene.git
Install dependencies

Bash
flutter pub get
Configure Permissions
Ensure you have the following permissions in your AndroidManifest.xml and Info.plist:

ACTIVITY_RECOGNITION / Motion Usage

ACCESS_FINE_LOCATION

ACCESS_COARSE_LOCATION

Run the app

Bash
flutter run
📍 Use Case: The Hill Station Advantage
Most modern trackers fail or lose data when the GPS signal is weak or the internet drops. Athlene’s "dot-drop" tracking (every 3-5 meters) and local Haversine calculations make it the ideal companion for trekkers and hikers in remote terrains where connectivity is non-existent.

Created with ❤️ for the fitness community.