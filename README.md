# iOS WeatherApp 🌦️

A simple weather application built using **UIKit** and **CoreLocation** that fetches weather data from the OpenWeatherMap API. The app displays current weather conditions and a 5-day forecast for a chosen location. It also includes dynamic background animations that change based on the weather (e.g., sunny, rainy, cloudy).

# ✨ Features

- 🌍 Current Weather Details
   - City name, temperature, humidity, and more.
- 🔄 Search & Add Cities
    - Search from a predefined list of cities.
    - Instantly pin a city to view its weather.
- 🗓️ 5-Day Forecast
    - Displays future temperature and condition icons.
- 🎨 Dynamic Backgrounds
- ☀️ Sunny: Gradient backgrounds.
- 🌧️ Rainy: Rain animations.
- ☁️ Cloudy: Floating cloud animations.
- 🌡️ Temperature in Celsius
- 📊 Weather icons for each forecast (sunny, rainy, cloudy).
    - Auto-converted from API-provided temperature.
- 🗑️ Swipe Actions
   - Swipe left to Pin any city to the top, and delete too.

# 📸 Visual Overview 
https://github.com/user-attachments/assets/1ef1a7ff-ff4a-4fb5-bd05-843571602ce5


# 🚀 Getting Started
-  ✅ Requirements
     - iOS 14.0+

     - Xcode 12+

     - Swift 5+

- WeatherAPI Key (https://www.openweatherapi.com/)

# 📥 Installation
 1. Clone the Repo
  bash
  git clone https://github.com/vageesh-singh-iphtech/WeatherApp.git
 2. Open the Project
   bash
   Open `WeatherApp.xcodeproj` in Xcode
 3. Add Your API Key
   Go to    (https://openweathermap.org/api)  and sign up.

# Get your free API key. #

   Open AllLocationsVC.swift and replace:

- ▶️ Run the App
Select your device/simulator in Xcode.

Press Cmd + R or click Run.

- 📱 How to Use the App
     First you get to see your current location Weather.
- And then
  - 🔍 Searching & Adding Cities
  - Tap the Add button.
    View a searchable list of predefined cities.
    Tap on any city to fetch and pin its weather data to your main list.

- 🌤️ Viewing Weather
   - Each cell shows:
- 📍 City name
- 🕒 Local time
- 🌡️ Temperature
- ☁️ Condition
- 🌍 Coordinates  
- ⬅️➡️ Swipe Actions
Pin: Move a location to the top.

Delete: Remove it from the list.



# 🧠 Under the Hood
- UIKit for UI layout.

- CoreLocation to access user's location (can be expanded).

- URLSession for networking.

- WeatherAPI for real-time weather data.

Custom TableView & CollectionView Cells for UI presentation.


- 🛠️ Project Structure
   - AllLocationsVC.swift → Main screen showing current weather for multiple cities.

   - AddNewLocation.swift → Bottom sheet view for selecting/searching cities.

   - WeatherVC.swift → Detailed view (optional future expansion).

# 💡 Future Improvements
 - ⛅ Full-screen Weather Detail Page.

 - 📍 Auto-detect user location on launch.

 - 🔔 Notifications for severe weather alerts.

 - 🧩 More tiles.

# 👨‍💻 Author
You! Feel free to fork and customize this project.

## Made with ❤️ By Vageesh 

# ------------------------------------------>
