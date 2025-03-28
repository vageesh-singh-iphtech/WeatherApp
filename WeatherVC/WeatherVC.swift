//
//  WeatherVC.swift
//  WeatherApp
//
//  Created by iPHTech 35 on 25/03/25.
//

import UIKit
import CoreLocation


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

    override func viewDidLoad() {
    super.viewDidLoad()
       

    temperatureCollectionViewCell.dataSource = self
    temperatureCollectionViewCell.delegate = self
    temperatureTableViewCell.dataSource = self
    temperatureTableViewCell.delegate = self
        
        temperatureCollectionViewCell.register(UINib(nibName: "WeatherCollectionCell" , bundle: nil), forCellWithReuseIdentifier: "WeatherCollectionCell")
        
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
        lblStackViewRawData.text = "Humidity:\(weather.main.humidity)"
        
        // Add weather background animation
                addWeatherBackgroundAnimation(for: weatherCondition.main)
       
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

    // Collection View Extension
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
    cell.ccImg.image = UIImage(named: weather.icon)
    }
    let temp = forecastItem.main.temp - 273.15
    cell.cclbl2.text = String(format: "%.1f°", temp)
    return cell
    }
    }

    // Table View Extension
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

extension WeatherVC {
    
    func addWeatherBackgroundAnimation(for weather: String) {
        
        switch weather.lowercased() {
        case "rain", "drizzle":
            addRainAnimation()
        case "clouds":
            addCloudAnimation()
        case "clear":
            addSunnyBackground()
        default:
            removeWeatherAnimations() // Clears the background if no weather matches
        }
    }
    
    private func addRainAnimation() {
        removeWeatherAnimations() // Clear existing animations
        let rainEmitter = CAEmitterLayer()
        rainEmitter.emitterShape = .line
        rainEmitter.emitterPosition = CGPoint(x: view.bounds.midX, y: -50)
        rainEmitter.emitterSize = CGSize(width: view.bounds.size.width, height: 1)
        
        let rainCell = CAEmitterCell()
        rainCell.birthRate = 25
        rainCell.lifetime = 5.0
        rainCell.velocity = 300
        rainCell.velocityRange = 100
        rainCell.emissionLongitude = .pi
        rainCell.scale = 0.2
        rainCell.contents = UIImage(named: "raindrop")?.cgImage
        rainEmitter.emitterCells = [rainCell]
        
        view.layer.insertSublayer(rainEmitter, at: 0)
    }
    
    private func addCloudAnimation() {
        removeWeatherAnimations() // Clear existing animations
        let cloudImage = UIImage(named: "cloud")
        let cloudView = UIImageView(image: cloudImage)
        cloudView.frame = CGRect(x: -100, y: 100, width: 200, height: 150)
        
        view.addSubview(cloudView)
        
        UIView.animate(withDuration: 20.0, delay: 0, options: [.repeat, .curveLinear], animations: {
            cloudView.frame = CGRect(x: self.view.bounds.width, y: 100, width: 200, height: 100)
        }, completion: nil)
    }
    
    private func addSunnyBackground() {
        removeWeatherAnimations() // Clear existing animations
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [UIColor.systemYellow.cgColor, UIColor.systemOrange.cgColor]
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func removeWeatherAnimations() {
        view.layer.sublayers?.forEach { sublayer in
            if sublayer is CAEmitterLayer || sublayer is CAGradientLayer {
                sublayer.removeFromSuperlayer()
            }
        }
        view.subviews.forEach { subview in
            if subview is UIImageView {
                subview.removeFromSuperview()
            }
        }
    }
}

