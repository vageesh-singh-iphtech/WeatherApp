# WeatherApp 🌦️

A simple weather application built using **UIKit** and **CoreLocation** that fetches weather data from the OpenWeatherMap API. The app displays current weather conditions and a 5-day forecast for a chosen location. It also includes dynamic background animations that change based on the weather (e.g., sunny, rainy, cloudy).

## Features

- 🌍 Display current weather and location (city name, temperature, humidity, etc.).
- 🔮 Show a 5-day weather forecast.
- ☀️ Dynamic background animations:
  - Rain animation for rainy weather.
  - Cloud animation for cloudy weather.
  - Gradient background for sunny weather.
- 🌡️ Temperature conversion from Kelvin to Celsius.
- 📊 Weather icons for each forecast (sunny, rainy, cloudy).

## Screenshots
https://github.com/user-attachments/assets/e29e3bc0-5ef0-45ff-a635-d0d20510ae08

## Requirements

- iOS 14.0+
- Xcode 12+
- Swift 5.0+
- OpenWeatherMap API Key

## Installation

### 1. Clone the Repository


### Steps:
1. **Clone** the repository to get the project.
2. **Add your OpenWeatherMap API key**.
3. **Run the app** in Xcode to test it.

### Key Sections:
- **Features**: Briefly describes the app's functionality.
- **Installation**: Step-by-step guide on how to set up the project.
- **Usage**: Instructions on using the app.

###2. Open the Project in Xcode
      Open the .xcworkspace file in Xcode:
### 3. Add Your OpenWeatherMap API Key
      Go to OpenWeatherMap and sign up for a free account.

Obtain your API key.

Open WeatherVC.swift and replace the apiKey with your OpenWeatherMap API key:

### 4. Run the App
Select your target device or simulator in Xcode.

Hit the Run button (or press Cmd + R) to build and run the app.

###Usage

On launch, the app fetches weather information for the default city (London, UK).

The home screen shows the current temperature, weather conditions, and additional details (humidity, etc.).

The weather animation changes according to the current weather:

Rainy: Rain animation with falling raindrops.

Cloudy: Clouds moving across the screen.

Sunny: A bright sunny gradient background.

Swipe through the forecast section to view upcoming weather conditions.

Tap on different cities (this feature can be expanded in future versions).
