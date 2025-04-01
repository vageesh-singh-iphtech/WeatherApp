//
//  WeatherVC.swift
//  WeatherApp
//
//  Created by iPHTech 35 on 25/03/25.
//

import UIKit
import CoreLocation
import AVFoundation


class WeatherVC: UIViewController {
    
    
    @IBOutlet weak var lblCityName: UILabel!
    
    @IBOutlet weak var lblCityTemp: UILabel!
    
    @IBOutlet weak var lblDayType: UILabel!
    
    @IBOutlet weak var lblCelcius: UILabel!
    
    @IBOutlet weak var temperatureCollectionViewCell: UICollectionView!
    
    @IBOutlet weak var lblStackViewRawData: UILabel!
    
    @IBOutlet weak var temperatureTableViewCell: UITableView!
    
    
    private var currentWeather: WeatherResponse?
        private var forecast: [ForecastItem] = []
        private var dailyForecasts: [DailyForecast] = []
        
        // Video Background Properties
        private var player: AVQueuePlayer?
        private var playerLayer: AVPlayerLayer?
        private var playerLooper: AVPlayerLooper?
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            temperatureCollectionViewCell.dataSource = self
            temperatureCollectionViewCell.delegate = self
            temperatureTableViewCell.dataSource = self
            temperatureTableViewCell.delegate = self
            
            temperatureCollectionViewCell.register(UINib(nibName: "WeatherCollectionCell", bundle: nil), forCellWithReuseIdentifier: "WeatherCollectionCell")
            temperatureTableViewCell.register(UINib(nibName: "WeatherCell2", bundle: nil), forCellReuseIdentifier: "WeatherCell2")
            
            fetchWeatherData(for: "London,uk") { [weak self] weatherResponse in
                guard let self = self, let weatherResponse = weatherResponse else {
                    print("Failed to fetch current weather data")
                    return
                }
                self.currentWeather = weatherResponse
                DispatchQueue.main.async {
                    self.updateCurrentWeatherUI()
                }
            }
            
            fetchForecastData(for: "London,uk") { [weak self] forecastResponse in
                guard let self = self, let forecastResponse = forecastResponse else {
                    print("Failed to fetch forecast data")
                    return
                }
                self.forecast = forecastResponse.list
                self.dailyForecasts = self.getDailyForecasts(from: self.forecast)
                DispatchQueue.main.async {
                    self.temperatureCollectionViewCell.reloadData()
                    self.temperatureTableViewCell.reloadData()
                }
            }
        }
        
        private func updateCurrentWeatherUI() {
            guard let weather = currentWeather else { return }
            lblCityName.text = weather.name
            let temperature = weather.main.temp - 273.15
            lblCityTemp.text = String(format: "%.1f", temperature)
            lblCelcius.text = "°C"
            if let weatherCondition = weather.weather.first {
                lblDayType.text = weatherCondition.description.capitalized
                lblStackViewRawData.text = "Humidity: \(weather.main.humidity)"
                
                // Add video background based on the weather condition
                addVideoBackground(for: weatherCondition.main)
            }
        }
        
        private func fetchWeatherData(for city: String, completion: @escaping (WeatherResponse?) -> Void) {
            let apiKey = "f551c29acc297624e75e5edfd5efc8ef"
            let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=\(apiKey)"
            guard let url = URL(string: urlString) else {
                completion(nil)
                return
            }
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("Error fetching weather data: \(error)")
                    completion(nil)
                    return
                }
                guard let data = data else {
                    completion(nil)
                    return
                }
                do {
                    let decoder = JSONDecoder()
                    let weatherResponse = try decoder.decode(WeatherResponse.self, from: data)
                    completion(weatherResponse)
                } catch {
                    print("Error decoding weather data: \(error)")
                    completion(nil)
                }
            }.resume()
        }
        
        private func fetchForecastData(for city: String, completion: @escaping (ForecastResponse?) -> Void) {
            let apiKey = "f551c29acc297624e75e5edfd5efc8ef"
            let urlString = "https://api.openweathermap.org/data/2.5/forecast?q=\(city)&appid=\(apiKey)"
            guard let url = URL(string: urlString) else {
                completion(nil)
                return
            }
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("Error fetching forecast data: \(error)")
                    completion(nil)
                    return
                }
                guard let data = data else {
                    completion(nil)
                    return
                }
                do {
                    let decoder = JSONDecoder()
                    let forecastResponse = try decoder.decode(ForecastResponse.self, from: data)
                    completion(forecastResponse)
                } catch {
                    print("Error decoding forecast data: \(error)")
                    completion(nil)
                }
            }.resume()
        }
        
        private func getDailyForecasts(from forecastItems: [ForecastItem]) -> [DailyForecast] {
            var dailyForecasts: [Date: [ForecastItem]] = [:]
            let calendar = Calendar.current
            for item in forecastItems {
                let date = Date(timeIntervalSince1970: TimeInterval(item.dt))
                let startOfDay = calendar.startOfDay(for: date)
                if dailyForecasts[startOfDay] == nil {
                    dailyForecasts[startOfDay] = []
                }
                dailyForecasts[startOfDay]?.append(item)
            }
            var result: [DailyForecast] = []
            for (date, items) in dailyForecasts {
                let temperatures = items.map { $0.main.temp }
                let minTemp = temperatures.min() ?? 0
                let maxTemp = temperatures.max() ?? 0
                if let weather = items.first?.weather.first {
                    result.append(DailyForecast(date: date, minTemp: minTemp, maxTemp: maxTemp, weather: weather))
                }
            }
            return result.sorted { $0.date < $1.date }
        }
    }

    // MARK: - Collection View Extension
    extension WeatherVC: UICollectionViewDataSource, UICollectionViewDelegate {
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return min(8, forecast.count)
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WeatherCollectionCell", for: indexPath) as! WeatherCollectionCell
            let forecastItem = forecast[indexPath.item]
            let date = Date(timeIntervalSince1970: TimeInterval(forecastItem.dt))
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            cell.cclbl1.text = formatter.string(from: date)
            if let weather = forecastItem.weather.first {
                // Set an icon if needed or handle differently
                cell.ccImg.image = UIImage(named: weather.icon)
            }
            let temp = forecastItem.main.temp - 273.15
            cell.cclbl2.text = String(format: "%.1f°", temp)
            return cell
        }
    }

    // MARK: - Table View Extension
    extension WeatherVC: UITableViewDataSource, UITableViewDelegate {
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return dailyForecasts.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherCell2", for: indexPath) as! WeatherCell2
            let dailyForecast = dailyForecasts[indexPath.row]
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            cell.Day.text = formatter.string(from: dailyForecast.date)
            cell.lblImage.image = UIImage(named: dailyForecast.weather.icon)
            let minTemp = dailyForecast.minTemp - 273.15
            let maxTemp = dailyForecast.maxTemp - 273.15
            cell.lblTempCell.text = String(format: "%.1f°", minTemp)
            cell.lnlTempCell2.text = String(format: "%.1f°", maxTemp)
            return cell
        }
    }

    // MARK: - Video Background Extension
    extension WeatherVC {
        
        /// This method selects a video based on the weather condition and plays it in the background.
        func addVideoBackground(for weather: String) {
          //  removeBackgroundVideo() // Remove any existing video background

            var videoName: String
            switch weather.lowercased() {
            case "rain", "drizzle":
                videoName = "rain"
            case "clouds":
                videoName = "cloud"
            case "clear":
                videoName = "sunny"
            default:
                return // If weather does not match, do not add a video background
            }
            
            // Use Bundle.main.url to get the video URL
            guard let videoURL = Bundle.main.url(forResource: videoName, withExtension: "mp4") else {
                print("Video file \(videoName).mp4 not found")
                return
            }
            
            let asset = AVAsset(url: videoURL)
            let item = AVPlayerItem(asset: asset)
            
            // Create an AVQueuePlayer to support looping
            player = AVQueuePlayer()
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.frame = view.bounds
            playerLayer?.videoGravity = .resizeAspectFill
            
            // Insert the video layer at the back so that all labels and UI elements remain on top
            if let playerLayer = playerLayer {
                view.layer.insertSublayer(playerLayer, at: 0)
            }
            
            // Use AVPlayerLooper to loop the video indefinitely
            if let player = player {
                playerLooper = AVPlayerLooper(player: player, templateItem: item)
                player.play()
            }
        }

    }


