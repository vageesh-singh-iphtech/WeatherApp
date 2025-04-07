//
//  WeatherVC.swift
//  WeatherApp
//
//  Created by iPHTech 35 on 25/03/25.
//

import UIKit
import CoreLocation
import AVFoundation


class WeatherVC: UIViewController  {
    
    @IBOutlet weak var lblmyLocation: UILabel!
    
    @IBOutlet weak var lblCityName: UILabel!
    
    @IBOutlet weak var lblCityTemp: UILabel!
    
    @IBOutlet weak var lblDayType: UILabel!
    
    @IBOutlet weak var lblCelcius: UILabel!
    
    @IBOutlet weak var temperatureCollectionViewCell: UICollectionView!
    
    @IBOutlet weak var lblStackViewRawData: UILabel!
    
    @IBOutlet weak var temperatureTableViewCell: UITableView!
    
    
    
    
    // MARK: - Data Properties
        /// This property is set when navigating from AllLocationsVC.
        var selectedWeather: WeatherResponses?
        
        // These properties are used for fetching current weather & forecast.
        private var currentWeather: WeatherResponse?
        private var forecast: [ForecastItem] = []
        private var dailyForecasts: [DailyForecast] = []
        
        // MARK: - Video Background Properties
        private var player: AVQueuePlayer?
        private var playerLayer: AVPlayerLayer?
        private var playerLooper: AVPlayerLooper?
        
        // MARK: - Core Location Manager (optional fallback)
        private let locationManager = CLLocationManager()
        
        // MARK: - View Lifecycle
        override func viewDidLoad() {
            super.viewDidLoad()
            
            // Set up collection and table view
            temperatureCollectionViewCell.dataSource = self
            temperatureCollectionViewCell.delegate = self
            temperatureTableViewCell.dataSource = self
            temperatureTableViewCell.delegate = self
            
            temperatureCollectionViewCell.register(UINib(nibName: "WeatherCollectionCell", bundle: nil),
                                                    forCellWithReuseIdentifier: "WeatherCollectionCell")
            temperatureTableViewCell.register(UINib(nibName: "WeatherCell2", bundle: nil),
                                              forCellReuseIdentifier: "WeatherCell2")
            
       //     temperatureTableViewCell.backgroundColor = UIColor.clear
       //     temperatureCollectionViewCell.backgroundColor = UIColor.clear

            
            temperatureTableViewCell.layer.cornerRadius = 15
            temperatureCollectionViewCell.layer.cornerRadius = 15

            
//            let appearance = UINavigationBarAppearance()
//                appearance.configureWithOpaqueBackground()
//                appearance.titleTextAttributes = [.foregroundColor: UIColor.orange]
            
            // Use passed data to update UI; if not, you could optionally use current location.
            if let weather = selectedWeather {
                updateUI(with: weather)
                
                // Fetch forecast data using the selected city's name.
                        fetchForecastData(for: weather.location.name) { [weak self] forecastResponse in
                            guard let self = self, let forecastResponse = forecastResponse else { return }
                            self.forecast = forecastResponse.list
                            self.dailyForecasts = self.getDailyForecasts(from: self.forecast)
                            DispatchQueue.main.async {
                                self.temperatureCollectionViewCell.reloadData()
                                self.temperatureTableViewCell.reloadData()
                            }
                        }
            } else {
                configureLocationManager() // Fallback if no selection was passed.
            }
        }
    
     func updateCurrentWeatherUI() {
        guard let weather = currentWeather else { return }
        lblCityName.text = weather.name
        let temperature = weather.main.temp - 273.15
        lblCityTemp.text = String(format: "%.1f", temperature)
        lblCelcius.text = "°C"
         
        if let weatherCondition = weather.weather.first {
            lblDayType.text = weatherCondition.description.capitalized
            lblStackViewRawData.text = "Humidity: \(weather.main.humidity)%"
            addVideoBackground(for: weatherCondition.main)
        }
         
         
         
    }

        
    private func configureLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

        // MARK: - UI Update
        private func updateUI(with weather: WeatherResponses) {
            lblmyLocation.text = ""
            lblCityName.text = weather.location.name
            lblCityTemp.text = "\(weather.current.temp_c)"
            lblCelcius.text = "°C"
            lblDayType.text = weather.current.condition.text
            lblStackViewRawData.text = "Humidity: \(weather.current.humidity)%"
            
            // Set video background based on weather condition.
            addVideoBackground(for: weather.current.condition.text)
        }
        
        // MARK: - Video Background
    func addVideoBackground(for weather: String) {
        let lowerWeather = weather.lowercased()
        var videoName: String?
        
        if lowerWeather.contains("rain") || lowerWeather.contains("drizzle") {
            videoName = "rain"
        }else if lowerWeather.contains("mist") || lowerWeather.contains("fog"){
            videoName = "mist"
        }else if lowerWeather.contains("snow") || lowerWeather.contains("cold"){
            videoName =  "snow"
        }
        else if lowerWeather.contains("cloud") {
            videoName = "cloud"
        } else if lowerWeather.contains("clear") || lowerWeather.contains("sunny") {
            videoName = "sunny"
        }
        
        guard let videoName = videoName,
              let videoURL = Bundle.main.url(forResource: videoName, withExtension: "mp4") else {
            print("Video file not found for weather: \(weather)")
            return
        }
        
        let asset = AVAsset(url: videoURL)
        let item = AVPlayerItem(asset: asset)
        
        player = AVQueuePlayer()
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = view.bounds
        playerLayer?.videoGravity = .resizeAspectFill
        
        if let playerLayer = playerLayer {
            view.layer.insertSublayer(playerLayer, at: 0)
        }
        
        if let player = player {
            playerLooper = AVPlayerLooper(player: player, templateItem: item)
            player.play()
        }
    }

        
        // Optional: Remove video background
        private func removeBackgroundVideo() {
            player?.pause()
            playerLayer?.removeFromSuperlayer()
            player = nil
            playerLayer = nil
            playerLooper = nil
        }
    }



    // MARK: - Collection View Data Source & Delegate
    extension WeatherVC: UICollectionViewDataSource, UICollectionViewDelegate {
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return min(8, forecast.count)
        }
        
        func collectionView(_ collectionView: UICollectionView,
                            cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WeatherCollectionCell", for: indexPath) as! WeatherCollectionCell
            let forecastItem = forecast[indexPath.item]
            let date = Date(timeIntervalSince1970: TimeInterval(forecastItem.dt))
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            cell.cclbl1.text = formatter.string(from: date)
            if let weather = forecastItem.weather.first {
                cell.ccImg.image = UIImage(named: weather.icon)
            }
            let temp = forecastItem.main.temp - 273.15
            cell.cclbl2.text = String(format: "%.1f°", temp)
            return cell
        }
    }

    // MARK: - Table View Data Source & Delegate
    extension WeatherVC: UITableViewDataSource, UITableViewDelegate {
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return dailyForecasts.count
        }
        
        func tableView(_ tableView: UITableView,
                       cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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

    // MARK: - (Optional) Core Location Delegate
    extension WeatherVC: CLLocationManagerDelegate {
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            // Fallback if no selectedWeather was provided.
            if let location = locations.last {
                locationManager.stopUpdatingLocation()
                let lat = location.coordinate.latitude
                let lon = location.coordinate.longitude
                
                fetchWeatherData(forLatitude: lat, longitude: lon) { [weak self] weatherResponse in
                    guard let self = self, let weatherResponse = weatherResponse else { return }
                    self.currentWeather = weatherResponse
                    DispatchQueue.main.async {
                        self.updateCurrentWeatherUI()
                    }
                    
                    self.fetchForecastData(for: weatherResponse.name) { [weak self] forecastResponse in
                        guard let self = self, let forecastResponse = forecastResponse else { return }
                        self.forecast = forecastResponse.list
                        self.dailyForecasts = self.getDailyForecasts(from: self.forecast)
                        DispatchQueue.main.async {
                            self.temperatureCollectionViewCell.reloadData()
                            self.temperatureTableViewCell.reloadData()
                        }
                    }
                }
            }
        }
        
        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print("Location manager error: \(error)")
        }
        
        private func fetchWeatherData(forLatitude lat: Double, longitude lon: Double,
                                        completion: @escaping (WeatherResponse?) -> Void) {
            let apiKey = "f551c29acc297624e75e5edfd5efc8ef"
            let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=\(apiKey)"
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
        
        private func fetchForecastData(for city: String,
                                       completion: @escaping (ForecastResponse?) -> Void) {
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
    
   
  /*
    private var currentWeather: WeatherResponse?
        private var forecast: [ForecastItem] = []
        private var dailyForecasts: [DailyForecast] = []
        
        // Video Background Properties
        private var player: AVQueuePlayer?
        private var playerLayer: AVPlayerLayer?
        private var playerLooper: AVPlayerLooper?
    
    // Core Location Manager
        private let locationManager = CLLocationManager()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            temperatureCollectionViewCell.dataSource = self
            temperatureCollectionViewCell.delegate = self
            temperatureTableViewCell.dataSource = self
            temperatureTableViewCell.delegate = self
            
            if let layout = temperatureCollectionViewCell.collectionViewLayout as? UICollectionViewFlowLayout {
                // Adjust spacing
                layout.minimumInteritemSpacing = 5 // Space between items horizontally (if vertical scroll)
                layout.minimumLineSpacing = 5
            }
            
            temperatureCollectionViewCell.register(UINib(nibName: "WeatherCollectionCell", bundle: nil), forCellWithReuseIdentifier: "WeatherCollectionCell")
            temperatureTableViewCell.register(UINib(nibName: "WeatherCell2", bundle: nil), forCellReuseIdentifier: "WeatherCell2")
            
            // Configure Core Location
            configureLocationManager()
        }
    

    
        
        // MARK: - Core Location Methods
        private func configureLocationManager() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            
            // Request location permission
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
        
        // MARK: - Update UI & Fetch Data Methods
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
        
        // Fetch weather data based on coordinates
        private func fetchWeatherData(forLatitude lat: Double, longitude lon: Double, completion: @escaping (WeatherResponse?) -> Void) {
            let apiKey = "f551c29acc297624e75e5edfd5efc8ef"
            let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=\(apiKey)"
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
        
        // For forecast, you may want to use city-based fetching or coordinate-based if supported
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

    // MARK: - CLLocationManagerDelegate
    extension WeatherVC: CLLocationManagerDelegate {
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            // Use the most recent location
            if let location = locations.last {
                // Stop updating location to avoid multiple calls
                locationManager.stopUpdatingLocation()
                let lat = location.coordinate.latitude
                let lon = location.coordinate.longitude
                
                // Fetch weather data for the current location
                fetchWeatherData(forLatitude: lat, longitude: lon) { [weak self] weatherResponse in
                    guard let self = self, let weatherResponse = weatherResponse else {
                        print("Failed to fetch weather data using location")
                        return
                    }
                    self.currentWeather = weatherResponse
                    DispatchQueue.main.async {
                        self.updateCurrentWeatherUI()
                    }
                    
                    // Optionally, fetch forecast data using the city name from the response
                    self.fetchForecastData(for: weatherResponse.name) { [weak self] forecastResponse in
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
            }
        }
        
        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print("Location manager error: \(error)")
        }
    }

    // MARK: - Collection View Extension
    extension WeatherVC: UICollectionViewDataSource, UICollectionViewDelegate{
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return min(8, forecast.count)
        }
    /*    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let itemsPerRow: CGFloat = 4
            let spacing: CGFloat = 10
            let totalSpacing = spacing * (itemsPerRow - 1)  // Total spacing between cells
            let availableWidth = collectionView.bounds.width - totalSpacing  // Remaining width
            let cellWidth = availableWidth / itemsPerRow  // Width for each cell

            return CGSize(width: cellWidth, height: cellWidth) // Keeping cells square
        } */



        
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
            // Uncomment removeBackgroundVideo() if you want to clear previous video
            // removeBackgroundVideo()
            
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
        
        /// Optionally remove previous video background
        private func removeBackgroundVideo() {
            player?.pause()
            playerLayer?.removeFromSuperlayer()
            player = nil
            playerLayer = nil
            playerLooper = nil
        }
    }
   
   */

// MARK: - Old Code
        
     /*   override func viewDidLoad() {
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

    }        */
  
