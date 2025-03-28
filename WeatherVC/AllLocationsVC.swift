//
//  AllLocationsVC.swift
//  WeatherApp
//
//  Created by iPHTech 35 on 27/03/25.
//

import UIKit

class AllLocationsVC: UIViewController {
    
    
    @IBOutlet weak var tblAllLocationData: UITableView!
    
    var weatherDataArray: [WeatherResponses] = []
    let cities = ["Sydney", "London", "Paris", "Tokyo", "New Delhi", "Kolkata", "Columbia", "Sitapur", "Lucknow"]
      
      override func viewDidLoad() {
          super.viewDidLoad()
          
          // Set up table view
          tblAllLocationData.delegate = self
          tblAllLocationData.dataSource = self
          
          // Register the nib file for custom cell
          tblAllLocationData.register(UINib(nibName: "AllLocationCustomCell", bundle: nil), forCellReuseIdentifier: "AllLocationCustomCell")
          
          // Fetch weather data for multiple cities
          fetchAllData()
      }
      
      // Fetch weather data for multiple locations
      func fetchAllData() {
          for city in cities {
              fetchWeatherData(for: city)
          }
      }
      
      // Fetch current weather data for a city
      func fetchWeatherData(for city: String) {
          let apiKey = "402b62629bb2473cb0b52917252503"
          let urlString = "https://api.weatherapi.com/v1/current.json?key=\(apiKey)&q=\(city)&aqi=no"
          
          guard let url = URL(string: urlString) else {
              print("Invalid URL for current weather")
              return
          }
          
          URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
              if let error = error {
                  print("Error fetching current weather: \(error)")
                  return
              }
              guard let data = data else {
                  print("No data returned from current weather API")
                  return
              }
              do {
                  let decoder = JSONDecoder()
                  let weatherResponses = try decoder.decode(WeatherResponses.self, from: data)
                  DispatchQueue.main.async {
                      self?.weatherDataArray.append(weatherResponses)
                      self?.tblAllLocationData.reloadData() // Reload table view with new data
                  }
              } catch {
                  print("Error decoding current weather JSON: \(error)")
              }
          }.resume()
      }
  }

  // MARK: - UITableView Data Source & Delegate

  extension AllLocationsVC: UITableViewDataSource, UITableViewDelegate {
      
      func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          return weatherDataArray.count
      }
      
      func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          let cell = tableView.dequeueReusableCell(withIdentifier: "AllLocationCustomCell", for: indexPath) as! AllLocationCustomCell
          let weather = weatherDataArray[indexPath.row]
          
          // Configure the cell with weather data
          cell.lblLocation.text = weather.location.name
          cell.lbltime.text = weather.location.localtime
          cell.lblDayType.text = weather.current.condition.text
          cell.lblTemperature.text = "\(weather.current.temp_c)°C"
          cell.lnlDayData.text = "Lat: \(weather.location.lat), Lon: \(weather.location.lon)"
          
          return cell
      }
  }
