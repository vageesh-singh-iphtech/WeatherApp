//
//  AllLocationsVC.swift
//  WeatherApp
//
//  Created by iPHTech 35 on 27/03/25.
//

import UIKit

class AllLocationsVC: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var tblAllLocationData: UITableView!
    
    
    @IBOutlet weak var txtCitySrch: UITextField!
   
    
    // MARK: - Data Properties
       var weatherDataArray: [WeatherResponses] = []          // Filtered array for display.
       var weatherDataArrayAllVal: [WeatherResponses] = []      // Full list of loaded weather responses.
       
       // Default cities: 4 initial cities when this view loads.
       let defaultCities = ["London", "New York", "Tokyo", "Sydney"]
       
       // MARK: - View Lifecycle
       override func viewDidLoad() {
           super.viewDidLoad()
           
           tblAllLocationData.delegate = self
           tblAllLocationData.dataSource = self
           tblAllLocationData.register(UINib(nibName: "AllLocationCustomCell", bundle: nil),
                                       forCellReuseIdentifier: "AllLocationCustomCell")
           
           txtCitySrch.delegate = self
           txtCitySrch.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
           txtCitySrch.layer.cornerRadius = 20
           txtCitySrch.layer.borderWidth=1
           
           // Load default cities when view appears.
           loadDefaultCities()
       }
       
       // MARK: - Default Cities Loading
       private func loadDefaultCities() {
           weatherDataArray.removeAll()
           weatherDataArrayAllVal.removeAll()
           
           let group = DispatchGroup()
           for city in defaultCities {
               group.enter()
               fetchWeatherData(for: city) { [weak self] weatherResponse in
                   defer { group.leave() }
                   guard let self = self, let weatherResponse = weatherResponse else { return }
                   DispatchQueue.main.async {
                       self.weatherDataArray.append(weatherResponse)
                       self.weatherDataArrayAllVal.append(weatherResponse)
                       self.tblAllLocationData.reloadData()
                   }
               }
           }
           
           group.notify(queue: .main) {
               // All default cities loaded.
           }
       }
       
       // MARK: - Data Fetching
       func fetchWeatherData(for city: String, completion: @escaping (WeatherResponses?) -> Void) {
           let apiKey = "402b62629bb2473cb0b52917252503"
           let urlString = "https://api.weatherapi.com/v1/current.json?key=\(apiKey)&q=\(city)&aqi=no"
           guard let url = URL(string: urlString) else {
               print("Invalid URL for current weather")
               completion(nil)
               return
           }
           
           URLSession.shared.dataTask(with: url) { data, response, error in
               if let error = error {
                   print("Error fetching current weather: \(error)")
                   completion(nil)
                   return
               }
               guard let data = data else {
                   print("No data returned from current weather API")
                   completion(nil)
                   return
               }
               do {
                   let decoder = JSONDecoder()
                   let weatherResponse = try decoder.decode(WeatherResponses.self, from: data)
                   completion(weatherResponse)
               } catch {
                   print("Error decoding current weather JSON: \(error)")
                   completion(nil)
               }
           }.resume()
       }
       
       // MARK: - Search Handling
       @objc func textFieldDidChange(_ textField: UITextField) {
           // Filter the weatherDataArray based on the search text.
           if let searchText = textField.text, !searchText.isEmpty {
               weatherDataArray = weatherDataArrayAllVal.filter { $0.location.name.lowercased().contains(searchText.lowercased()) }
           } else {
               // No search text: restore the full list.
               weatherDataArray = weatherDataArrayAllVal
           }
           tblAllLocationData.reloadData()
       }
       
       // Remove textFieldShouldReturn if not needed.
       
       // MARK: - IBAction for Add Button
       @IBAction func addLocationTapped(_ sender: UIButton) {
           if let addLocationVC = storyboard?.instantiateViewController(withIdentifier: "AddNewLocation") as? AddNewLocation {
               addLocationVC.delegate = self
               addLocationVC.modalPresentationStyle = .pageSheet
               present(addLocationVC, animated: true)
           }
       }
   }

   // MARK: - Table View Data Source & Delegate
   extension AllLocationsVC: UITableViewDataSource, UITableViewDelegate {
       
       func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return weatherDataArray.count
       }
       
       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell = tableView.dequeueReusableCell(withIdentifier: "AllLocationCustomCell", for: indexPath) as! AllLocationCustomCell
           let weather = weatherDataArray[indexPath.row]
           
           cell.lblLocation.text = weather.location.name
           cell.lbltime.text = weather.location.localtime
           cell.lblDayType.text = weather.current.condition.text
           cell.lblTemperature.text = "\(weather.current.temp_c)°C"
           cell.lnlDayData.text = "Lat: \(weather.location.lat), Lon: \(weather.location.lon)"
           
           // Background image based on weather condition
           let condition = weather.current.condition.text.lowercased()
           var backgroundImageName: String
           
           if condition.contains("rain") || condition.contains("drizzle") {
               backgroundImageName = "rainImage"
           } else if condition.contains("cloud") {
               backgroundImageName = "cloudImage"
           } else if condition.contains("clear") || condition.contains("sunny") {
               backgroundImageName = "sunnyImage"
           } else if condition.contains("snow") {
               backgroundImageName = "snowImage"
           } else if condition.contains("thunder") {
               backgroundImageName = "thunderImage"
           } else if condition.contains("mist") {
               backgroundImageName = "mistImage"
           } else {
               backgroundImageName = "defaultImage"
           }
           
           cell.cellimgaeBG.image = UIImage(named: backgroundImageName)
           return cell
       }
       
       // MARK: - Swipe Actions (Pin & Delete)
       func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
           
           // 🔹 Delete Action
           let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
               self.weatherDataArray.remove(at: indexPath.row)
               self.weatherDataArrayAllVal.remove(at: indexPath.row)
               tableView.deleteRows(at: [indexPath], with: .fade)
               completionHandler(true)
           }
           deleteAction.backgroundColor = .red
           
           // 🔹 Pin Action
           let pinAction = UIContextualAction(style: .normal, title: "Pin") { (action, view, completionHandler) in
               let pinnedItem = self.weatherDataArray.remove(at: indexPath.row)
               self.weatherDataArray.insert(pinnedItem, at: 0) // Move it to the top
               tableView.reloadData()
               completionHandler(true)
           }
           pinAction.backgroundColor = .blue
           
           let configuration = UISwipeActionsConfiguration(actions: [deleteAction, pinAction])
           configuration.performsFirstActionWithFullSwipe = false
           return configuration
       }
       
       // MARK: - Cell Selection
       func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           let selectedWeather = self.weatherDataArray[indexPath.row]
           if let weatherVC = storyboard?.instantiateViewController(withIdentifier: "WeatherVC") as? WeatherVC {
               weatherVC.selectedWeather = selectedWeather
               navigationController?.pushViewController(weatherVC, animated: true)
           }
       }
   }

   // MARK: - AddNewLocationDelegate Conformance
   extension AllLocationsVC: AddNewLocationDelegate {
       func didSelectCity(_ city: String) {
           fetchWeatherData(for: city) { [weak self] weatherResponse in
               guard let self = self, let weatherResponse = weatherResponse else { return }
               DispatchQueue.main.async {
                   self.weatherDataArray.insert(weatherResponse, at: 0)
                   self.weatherDataArrayAllVal.insert(weatherResponse, at: 0)
                   self.tblAllLocationData.reloadData()
               }
           }
       }
   }

  
   /*

    // MARK: - Data Properties
        var weatherDataArray: [WeatherResponses] = []
        var weatherDataArrayAllVal: [WeatherResponses] = []
        
        // Default cities: 4 initial cities when this view loads.
        let defaultCities = ["London", "New York", "Tokyo", "Sydney"]
        
        // MARK: - View Lifecycle
        override func viewDidLoad() {
            super.viewDidLoad()
            
            tblAllLocationData.delegate = self
            tblAllLocationData.dataSource = self
            tblAllLocationData.register(UINib(nibName: "AllLocationCustomCell", bundle: nil),
                                         forCellReuseIdentifier: "AllLocationCustomCell")
            
            txtCitySrch.delegate = self
            txtCitySrch.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            
            // Load default cities when view appears.
            loadDefaultCities()
        }
        
        // MARK: - Default Cities Loading
        private func loadDefaultCities() {
            weatherDataArray.removeAll()
            weatherDataArrayAllVal.removeAll()
            
            let group = DispatchGroup()
            for city in defaultCities {
                group.enter()
                fetchWeatherData(for: city) { [weak self] weatherResponse in
                    defer { group.leave() }
                    guard let self = self, let weatherResponse = weatherResponse else { return }
                    DispatchQueue.main.async {
                        self.weatherDataArray.append(weatherResponse)
                        self.weatherDataArrayAllVal.append(weatherResponse)
                        self.tblAllLocationData.reloadData()
                    }
                }
            }
            
            group.notify(queue: .main) {
                // All default cities loaded.
            }
        }
        
        // MARK: - Data Fetching
        func fetchWeatherData(for city: String, completion: @escaping (WeatherResponses?) -> Void) {
            let apiKey = "402b62629bb2473cb0b52917252503"
            let urlString = "https://api.weatherapi.com/v1/current.json?key=\(apiKey)&q=\(city)&aqi=no"
            guard let url = URL(string: urlString) else {
                print("Invalid URL for current weather")
                completion(nil)
                return
            }
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("Error fetching current weather: \(error)")
                    completion(nil)
                    return
                }
                guard let data = data else {
                    print("No data returned from current weather API")
                    completion(nil)
                    return
                }
                do {
                    let decoder = JSONDecoder()
                    let weatherResponse = try decoder.decode(WeatherResponses.self, from: data)
                    completion(weatherResponse)
                } catch {
                    print("Error decoding current weather JSON: \(error)")
                    completion(nil)
                }
            }.resume()
        }
        
        // MARK: - Search Handling
        @objc func textFieldDidChange(_ textField: UITextField) {
            // Optional live filtering can be implemented here.
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            guard let searchText = textField.text, !searchText.isEmpty else {
                textField.resignFirstResponder()
                return true
            }
            
            fetchWeatherData(for: searchText) { [weak self] weatherResponse in
                guard let self = self, let weatherResponse = weatherResponse else { return }
                DispatchQueue.main.async {
                    self.weatherDataArray.append(weatherResponse)
                    self.weatherDataArrayAllVal.append(weatherResponse)
                    self.tblAllLocationData.reloadData()
                    textField.text = ""
                }
            }
            
            textField.resignFirstResponder()
            return true
        }
        
        // MARK: - IBAction for Add Button
        @IBAction func addLocationTapped(_ sender: UIButton) {
            if let addLocationVC = storyboard?.instantiateViewController(withIdentifier: "AddNewLocation") as? AddNewLocation {
                    addLocationVC.delegate = self
                    addLocationVC.modalPresentationStyle = .pageSheet
                    present(addLocationVC, animated: true)
                }
        }
    }

// MARK: - Table View Data Source & Delegate
extension AllLocationsVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherDataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AllLocationCustomCell", for: indexPath) as! AllLocationCustomCell
        let weather = weatherDataArray[indexPath.row]
        
        cell.lblLocation.text = weather.location.name
        cell.lbltime.text = weather.location.localtime
        cell.lblDayType.text = weather.current.condition.text
        cell.lblTemperature.text = "\(weather.current.temp_c)°C"
        cell.lnlDayData.text = "Lat: \(weather.location.lat), Lon: \(weather.location.lon)"
        
        // Background image based on weather condition
        let condition = weather.current.condition.text.lowercased()
        var backgroundImageName: String
        
        if condition.contains("rain") || condition.contains("drizzle") {
            backgroundImageName = "rainImage"
        } else if condition.contains("cloud") {
            backgroundImageName = "cloudImage"
        } else if condition.contains("clear") || condition.contains("sunny") {
            backgroundImageName = "sunnyImage"
        } else if condition.contains("snow") {
            backgroundImageName = "snowImage"
        } else if condition.contains("thunder") {
            backgroundImageName = "thunderImage"
        } else if condition.contains("mist") {
            backgroundImageName = "mistImage"
        } else {
            backgroundImageName = "defaultImage"
        }
        
        cell.cellimgaeBG.image = UIImage(named: backgroundImageName)
        return cell
    }
    
    // MARK: - Swipe Actions (Pin & Delete)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // 🔹 Delete Action
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            self.weatherDataArray.remove(at: indexPath.row)
            self.weatherDataArrayAllVal.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            completionHandler(true)
        }
        deleteAction.backgroundColor = .red
        
        // 🔹 Pin Action
        let pinAction = UIContextualAction(style: .normal, title: "Pin") { (action, view, completionHandler) in
            let pinnedItem = self.weatherDataArray.remove(at: indexPath.row)
            self.weatherDataArray.insert(pinnedItem, at: 0) // Move it to the top
            tableView.reloadData()
            completionHandler(true)
        }
        pinAction.backgroundColor = .blue
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, pinAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
    
    // MARK: - Cell Selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedWeather = self.weatherDataArray[indexPath.row]
        if let weatherVC = storyboard?.instantiateViewController(withIdentifier: "WeatherVC") as? WeatherVC {
            weatherVC.selectedWeather = selectedWeather
            navigationController?.pushViewController(weatherVC, animated: true)
        }
    }
}


    // MARK: - AddNewLocationDelegate Conformance
extension AllLocationsVC: AddNewLocationDelegate {
    func didSelectCity(_ city: String) {
        fetchWeatherData(for: city) { [weak self] weatherResponse in
            guard let self = self, let weatherResponse = weatherResponse else { return }
            DispatchQueue.main.async {
                self.weatherDataArray.insert(weatherResponse, at: 0)
                self.weatherDataArrayAllVal.insert(weatherResponse, at: 0)
                self.tblAllLocationData.reloadData()
            }
        }
    }
}
    
    
    */
    /*
    
    // MARK: - Data Properties
        // Display array and backup array for all cities.
        var weatherDataArray: [WeatherResponses] = []
        var weatherDataArrayAllVal: [WeatherResponses] = []
        
        // Default cities: 4 initial cities when this view loads.
        let defaultCities = ["London", "New York", "Tokyo", "Sydney"]
        
        // MARK: - View Lifecycle
        override func viewDidLoad() {
            super.viewDidLoad()
            
            tblAllLocationData.delegate = self
            tblAllLocationData.dataSource = self
            tblAllLocationData.register(UINib(nibName: "AllLocationCustomCell", bundle: nil),
                                         forCellReuseIdentifier: "AllLocationCustomCell")
            
            txtCitySrch.delegate = self
            txtCitySrch.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            
            // Load 4 default cities when view appears.
            loadDefaultCities()
            
        }
        
    override func viewDidLayoutSubviews() {
        
    }
        // MARK: - Default Cities Loading
        private func loadDefaultCities() {
            // Clear any existing data
            weatherDataArray.removeAll()
            weatherDataArrayAllVal.removeAll()
            
            let group = DispatchGroup()
            
            for city in defaultCities {
                group.enter()
                fetchWeatherData(for: city) { [weak self] weatherResponse in
                    defer { group.leave() }
                    guard let self = self, let weatherResponse = weatherResponse else { return }
                    DispatchQueue.main.async {
                        self.weatherDataArray.append(weatherResponse)
                        self.weatherDataArrayAllVal.append(weatherResponse)
                        self.tblAllLocationData.reloadData()
                    }
                }
            }
            
            group.notify(queue: .main) {
                // All default cities loaded.
            }
        }
        
        // MARK: - Data Fetching
        func fetchWeatherData(for city: String, completion: @escaping (WeatherResponses?) -> Void) {
            let apiKey = "402b62629bb2473cb0b52917252503"
            let urlString = "https://api.weatherapi.com/v1/current.json?key=\(apiKey)&q=\(city)&aqi=no"
            guard let url = URL(string: urlString) else {
                print("Invalid URL for current weather")
                completion(nil)
                return
            }
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("Error fetching current weather: \(error)")
                    completion(nil)
                    return
                }
                guard let data = data else {
                    print("No data returned from current weather API")
                    completion(nil)
                    return
                }
                do {
                    let decoder = JSONDecoder()
                    let weatherResponse = try decoder.decode(WeatherResponses.self, from: data)
                    completion(weatherResponse)
                } catch {
                    print("Error decoding current weather JSON: \(error)")
                    completion(nil)
                }
            }.resume()
        }
        
        // MARK: - Search Handling
        @objc func textFieldDidChange(_ textField: UITextField) {
            // You may provide live filtering here if desired.
        }
        
        // When user taps Return in search field, fetch and append the city's weather.
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            guard let searchText = textField.text, !searchText.isEmpty else {
                textField.resignFirstResponder()
                return true
            }
            
            fetchWeatherData(for: searchText) { [weak self] weatherResponse in
                guard let self = self, let weatherResponse = weatherResponse else { return }
                DispatchQueue.main.async {
                    // Append new search result to both arrays.
                    self.weatherDataArray.append(weatherResponse)
                    self.weatherDataArrayAllVal.append(weatherResponse)
                    self.tblAllLocationData.reloadData()
                    textField.text = "" // Clear search field
                }
            }
            
            textField.resignFirstResponder()
            return true
        }
    }

    // MARK: - Table View Data Source & Delegate
extension AllLocationsVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherDataArray.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AllLocationCustomCell", for: indexPath) as! AllLocationCustomCell
        let weather = weatherDataArray[indexPath.row]
        cell.lblLocation.text = weather.location.name
        cell.lbltime.text = weather.location.localtime
        cell.lblDayType.text = weather.current.condition.text
        cell.lblTemperature.text = "\(weather.current.temp_c)°C"
        cell.lnlDayData.text = "Lat: \(weather.location.lat), Lon: \(weather.location.lon)"
        
        let condition = weather.current.condition.text.lowercased()
        var backgroundImageName: String
        
        if condition.contains("rain") || condition.contains("drizzle"){
            backgroundImageName = "rainImage"
        }
        else if condition.contains("cloud"){
            backgroundImageName = "cloudImage"
        } else if condition.contains("clear") || condition.contains("sunny"){
            backgroundImageName = "sunnyImage"
        }else if condition.contains("snow"){
            backgroundImageName = "snowImage"
        }else if condition.contains("thunder"){
            backgroundImageName = "thunderImage"
        }else if condition.contains("mist"){
            backgroundImageName = "mistImage"
        }
        else {
            backgroundImageName = "defaultImage"
        }
        
        cell.cellimgaeBG.image = UIImage(named: backgroundImageName)
        return cell
    }
    
    // MARK: Swipe Actions for Pin & Delete
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // Delete action: remove the item from both arrays.
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, view, completionHandler) in
            guard let self = self else { return }
            let removedItem = self.weatherDataArray.remove(at: indexPath.row)
            if let index = self.weatherDataArrayAllVal.firstIndex(where: { $0.location.name == removedItem.location.name }) {
                self.weatherDataArrayAllVal.remove(at: index)
            }
            tableView.deleteRows(at: [indexPath], with: .automatic)
            completionHandler(true)
        }
        
        // Pin action: move the selected cell to the top.
        let pinAction = UIContextualAction(style: .normal, title: "Pin") { [weak self] (action, view, completionHandler) in
            guard let self = self else { return }
            // Remove the item and insert at index 0.
            let pinnedItem = self.weatherDataArray.remove(at: indexPath.row)
            self.weatherDataArray.insert(pinnedItem, at: 0)
            
            if let originalIndex = self.weatherDataArrayAllVal.firstIndex(where: { $0.location.name == pinnedItem.location.name }) {
                let item = self.weatherDataArrayAllVal.remove(at: originalIndex)
                self.weatherDataArrayAllVal.insert(item, at: 0)
            }
            tableView.reloadData()
            completionHandler(true)
        }
        pinAction.backgroundColor = .systemBlue
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, pinAction])
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }
    
    // MARK: Cell Selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let selectedWeather = self.weatherDataArray[indexPath.row]
            if let weatherVC = self.storyboard?.instantiateViewController(withIdentifier: "WeatherVC") as? WeatherVC {
                weatherVC.selectedWeather = selectedWeather
                self.navigationController?.pushViewController(weatherVC, animated: true)
            }
        
    }
}

//........................................................................
    
*/
    
    /*
    
 // Data arrays for the displayed weather and to preserve all searched cities.
       var weatherDataArray: [WeatherResponses] = []
       var weatherDataArrayAllVal: [WeatherResponses] = []
       
       override func viewDidLoad() {
           super.viewDidLoad()
           
           // Set up table view
           tblAllLocationData.delegate = self
           tblAllLocationData.dataSource = self
           
           // Register the nib file for custom cell
           tblAllLocationData.register(UINib(nibName: "AllLocationCustomCell", bundle: nil), forCellReuseIdentifier: "AllLocationCustomCell")
           
           // Set up search text field
           txtCitySrch.delegate = self
           txtCitySrch.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
       }
       
       // MARK: - Data Fetching Methods
       
       // Fetch weather data for a specific city using WeatherAPI.
       func fetchWeatherData(for city: String, completion: @escaping (WeatherResponses?) -> Void) {
           let apiKey = "402b62629bb2473cb0b52917252503"
           let urlString = "https://api.weatherapi.com/v1/current.json?key=\(apiKey)&q=\(city)&aqi=no"
           guard let url = URL(string: urlString) else {
               print("Invalid URL for current weather")
               completion(nil)
               return
           }
                 
           URLSession.shared.dataTask(with: url) { data, response, error in
               if let error = error {
                   print("Error fetching current weather: \(error)")
                   completion(nil)
                   return
               }
               guard let data = data else {
                   print("No data returned from current weather API")
                   completion(nil)
                   return
               }
               do {
                   let decoder = JSONDecoder()
                   let weatherResponse = try decoder.decode(WeatherResponses.self, from: data)
                   completion(weatherResponse)
               } catch {
                   print("Error decoding current weather JSON: \(error)")
                   completion(nil)
               }
           }.resume()
       }
       
       // MARK: - Search Handling
       
       // Called when the text in the search field changes.
       // (In this version, we don't clear the list when the field is empty.)
       @objc func textFieldDidChange(_ textField: UITextField) {
           // Optional: You can add behavior here if needed when text is cleared.
       }
       
       // When the user taps Return in the search text field, fetch and append the city's weather data.
       func textFieldShouldReturn(_ textField: UITextField) -> Bool {
           guard let searchText = textField.text, !searchText.isEmpty else {
               textField.resignFirstResponder()
               return true
           }
           
           fetchWeatherData(for: searchText) { [weak self] weatherResponse in
               guard let self = self, let weatherResponse = weatherResponse else { return }
               DispatchQueue.main.async {
                   // Append the new search result to both arrays.
                   self.weatherDataArray.append(weatherResponse)
                   self.weatherDataArrayAllVal.append(weatherResponse)
                   self.tblAllLocationData.reloadData()
                   textField.text = ""  // Clear the search field
               }
           }
           
           textField.resignFirstResponder()
           return true
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
                 
           // Configure the cell with weather data.
           cell.lblLocation.text = weather.location.name
           cell.lbltime.text = weather.location.localtime
           cell.lblDayType.text = weather.current.condition.text
           cell.lblTemperature.text = "\(weather.current.temp_c)°C"
           cell.lnlDayData.text = "Lat: \(weather.location.lat), Lon: \(weather.location.lon)"
                 
           return cell
       }
       
       // MARK: Swipe Actions for Pin & Delete
       
       func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
           
           // Delete Action: remove the cell from both arrays.
           let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, view, completionHandler) in
               guard let self = self else { return }
               let removedItem = self.weatherDataArray.remove(at: indexPath.row)
               if let index = self.weatherDataArrayAllVal.firstIndex(where: { $0.location.name == removedItem.location.name }) {
                   self.weatherDataArrayAllVal.remove(at: index)
               }
               tableView.deleteRows(at: [indexPath], with: .automatic)
               completionHandler(true)
           }
           
           // Pin Action: move the selected cell to the top.
           let pinAction = UIContextualAction(style: .normal, title: "Pin") { [weak self] (action, view, completionHandler) in
               guard let self = self else { return }
               let pinnedItem = self.weatherDataArray.remove(at: indexPath.row)
               self.weatherDataArray.insert(pinnedItem, at: 0)
               if let originalIndex = self.weatherDataArrayAllVal.firstIndex(where: { $0.location.name == pinnedItem.location.name }) {
                   let item = self.weatherDataArrayAllVal.remove(at: originalIndex)
                   self.weatherDataArrayAllVal.insert(item, at: 0)
               }
               tableView.reloadData()
               completionHandler(true)
           }
           pinAction.backgroundColor = .systemBlue
           
           let configuration = UISwipeActionsConfiguration(actions: [deleteAction, pinAction])
           configuration.performsFirstActionWithFullSwipe = true
           return configuration
       }
   }
    

  */
   /*
    var weatherDataArray: [WeatherResponses] = []
    
    var weatherDataArrayAllVal: [WeatherResponses] = []
    
    let cities = ["Sydney", "London", "Paris", "Tokyo", "Delhi", "Kolkata", "Columbia", "Sitapur", "Lucknow"]
   
    override func viewDidLoad() {
            super.viewDidLoad()
            
            // Set up table view
            tblAllLocationData.delegate = self
            tblAllLocationData.dataSource = self
            
            // Register the nib file for custom cell
            tblAllLocationData.register(UINib(nibName: "AllLocationCustomCell", bundle: nil), forCellReuseIdentifier: "AllLocationCustomCell")
            
            // Set up search text field
            txtCitySrch.delegate = self
            txtCitySrch.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            
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
                    let weatherResponse = try decoder.decode(WeatherResponses.self, from: data)
                    DispatchQueue.main.async {
                        self?.weatherDataArray.append(weatherResponse)
                        self?.weatherDataArrayAllVal.append(weatherResponse) // Save the original data
                        self?.tblAllLocationData.reloadData()
                    }
                } catch {
                    print("Error decoding current weather JSON: \(error)")
                }
            }.resume()
        }
        
        // Called when the text in the search field changes
        @objc func textFieldDidChange(_ textField: UITextField) {
            if let text = textField.text, text.isEmpty {
                // Restore original data if search is cleared
                weatherDataArray = weatherDataArrayAllVal
            } else {
                filterDataWithTxtInput(inputTxt: textField.text ?? "")
            }
            DispatchQueue.main.async {
                self.tblAllLocationData.reloadData()
            }
        }
        
        // Filter weather data based on search text
        func filterDataWithTxtInput(inputTxt: String) {
            let filteredArray = weatherDataArrayAllVal.filter { weatherResponse in
                return weatherResponse.location.name.lowercased().hasPrefix(inputTxt.lowercased())
            }
            weatherDataArray = filteredArray
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
    
    */
    
 /*     override func viewDidLoad() {
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

*/
