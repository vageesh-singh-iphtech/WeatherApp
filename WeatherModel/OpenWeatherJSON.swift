//
//  OpenWeatherJSON.swift
//  WeatherApp
//
//  Created by iPHTech 35 on 28/03/25.
//

import Foundation

// Model for current weather data
struct WeatherResponse: Codable {
    let coord: Coord
    let weather: [Weather]
    let main: Main
    let visibility: Int
    let wind: Wind
    let clouds: Clouds
    let dt: Int
    let sys: Sys
    let timezone: Int
    let id: Int
    let name: String
    let cod: Int
}

struct Coord: Codable {
    let lon: Double
    let lat: Double
}

struct Weather: Codable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

struct Main: Codable {
    let temp: Double
    let feels_like: Double
    let temp_min: Double
    let temp_max: Double
    let pressure: Int
    let humidity: Int
    let sea_level: Int?
    let grnd_level: Int?
}

struct Wind: Codable {
    let speed: Double
    let deg: Int
    let gust: Double?
}

struct Clouds: Codable {
    let all: Int
}

struct Sys: Codable {
    let country: String
    let sunrise: Int
    let sunset: Int
}

// Model for forecast data
struct ForecastResponse: Codable {
    let list: [ForecastItem]
}

struct ForecastItem: Codable {
    let dt: Int
    let main: Main
    let weather: [Weather]
    let clouds: Clouds
    let wind: Wind
    let visibility: Int
    let pop: Double
    let sys: SysForecast
    let dt_txt: String
}

struct SysForecast: Codable {
    let pod: String
}

// Model for daily forecast summary
struct DailyForecast {
    let date: Date
    let minTemp: Double
    let maxTemp: Double
    let weather: Weather
}
