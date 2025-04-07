import UIKit

// Define the delegate protocol
protocol AddNewLocationDelegate: AnyObject {
    func didSelectCity(_ city: String)
}

class AddNewLocation: UIViewController {
    
    @IBOutlet weak var tblCityList: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
       weak var delegate: AddNewLocationDelegate?
       
       // Local dataset of famous cities
    var cities: [String] = [
       "Abu Dhabi",
       "Abidjan",
       "Accra",
       "Addis Ababa",
       "Adelaide",
       "Ahmedabad",
       "Algiers",
       "Alexandria",
       "Amman",
       "Amsterdam",
       "Ankara", // Added
       "Antananarivo", // Added
       "Antwerp", // Added
       "Asuncion", // Added
       "Athens",
       "Atlanta", // Added
       "Auckland", // Added
       "Austin", // Added
       "Baghdad", // Added
       "Bangalore", // Bengaluru
       "Bangkok",
       "Barcelona",
       "Beijing",
       "Beirut", // Added
       "Belgrade", // Added
       "Belo Horizonte", // Added
       "Berlin",
       "Bern", // Added
       "Birmingham", // Added (UK)
       "Bishkek", // Added
       "Bogotá",
       "Bordeaux",
       "Boston",
       "Brasília", // Added
       "Bratislava", // Added
       "Brisbane", // Added
       "Brussels",
       "Bucharest", // Added
       "Budapest",
       "Buenos Aires",
       "Cairo",
       "Calgary", // Added
       "Cali", // Added
       "Canberra", // Added
       "Cape Town",
       "Caracas",
       "Casablanca", // Added
       "Chennai",
       "Chengdu",
       "Chicago",
       "Chongqing", // Added
       "Christchurch", // Added
       "Colombo", // Added
       "Copenhagen",
       "Curitiba", // Added
       "Daegu", // Added
       "Dakar", // Added
       "Dallas", // Added
       "Damascus", // Added
       "Dar es Salaam", // Added
       "Delhi",
       "Denver", // Added
       "Dhaka", // Added
       "Doha", // Added
       "Dubai",
       "Dublin",
       "Durban", // Added
       "Dushanbe", // Added
       "Düsseldorf",
       "Edinburgh",
       "Edmonton", // Added
       "Florence",
       "Fortaleza", // Added
       "Frankfurt",
       "Fukuoka",
       "Geneva",
       "George Town", // Added (Penang)
       "Glasgow",
       "Guadalajara", // Added
       "Guangzhou",
       "Guatemala City", // Added
       "Guayaquil", // Added
       "Hamburg",
       "Hangzhou",
       "Hanoi",
       "Harare", // Added
       "Havana", // Added
       "Helsinki",
       "Hiroshima",
       "Ho Chi Minh City",
       "Hong Kong",
       "Honolulu", // Added
       "Houston",
       "Hyderabad",
       "Incheon", // Added
       "Islamabad", // Added
       "Istanbul",
       "Izmir", // Added
       "Jakarta",
       "Jeddah", // Added
       "Jerusalem", // Added
       "Johannesburg",
       "Kabul", // Added
       "Kampala", // Added
       "Kano", // Added
       "Karachi", // Added
       "Kathmandu", // Added
       "Khartoum", // Added
       "Kiev", // Kyiv - Added
       "Kingston", // Added (Jamaica)
       "Kinshasa", // Added
       "Kobe",
       "Kolkata",
       "Krakow", // Added
       "Kuala Lumpur",
       "Kuwait City", // Added
       "Kyiv", // Added (preferred spelling)
       "Kyoto",
       "Lagos", // Added
       "Lahore", // Added
       "La Paz", // Added
       "Las Vegas",
       "Leeds", // Added
       "Lima",
       "Lisbon",
       "Liverpool", // Added
       "Ljubljana", // Added
       "London",
       "Los Angeles",
       "Luanda", // Added
       "Lusaka", // Added
       "Luxembourg City", // Added
       "Lyon",
       "Madrid",
       "Malé", // Added
       "Managua", // Added
       "Manama", // Added
       "Manchester", // Added (UK)
       "Manila",
       "Maputo", // Added
       "Maracaibo", // Added
       "Marseille",
       "Mashhad", // Added
       "Mecca", // Added
       "Medan", // Added
       "Medellín", // Added
       "Melbourne", // Added
       "Mexico City",
       "Miami",
       "Milan",
       "Minsk", // Added
       "Mogadishu", // Added
       "Monaco", // Added
       "Monterrey", // Added
       "Montevideo",
       "Montreal", // Added
       "Moscow",
       "Mumbai",
       "Munich",
       "Muscat", // Added
       "Nairobi", // Added
       "Nagoya",
       "Nanjing",
       "Naples",
       "Nashville", // Added
       "Nassau", // Added
       "New Delhi", // Added (often distinct from Delhi)
       "New Orleans", // Added
       "New York",
       "Nice",
       "Nicosia", // Added
       "Novosibirsk", // Added
       "Nur-Sultan", // Astana - Added
       "Osaka",
       "Oslo",
       "Ottawa", // Added
       "Ouagadougou", // Added
       "Panama City", // Added
       "Paris",
       "Perth", // Added
       "Philadelphia", // Added
       "Phnom Penh", // Added
       "Phoenix", // Added
       "Pjöngjang", // Pyongyang - Added
       "Port Louis", // Added
       "Port Moresby", // Added
       "Port-au-Prince", // Added
       "Porto", // Added
       "Porto Alegre", // Added
       "Prague",
       "Pretoria", // Added
       "Puebla", // Added
       "Pune", // Added
       "Pyongyang", // Added
       "Quebec City", // Added
       "Quito", // Added
       "Rabat", // Added
       "Rangoon", // Yangon - Added
       "Rawalpindi", // Added
       "Recife", // Added
       "Reykjavik", // Added
       "Riga", // Added
       "Rio de Janeiro",
       "Riyadh", // Added
       "Rome",
       "Rotterdam", // Added
       "Saint Petersburg", // Added
       "Salvador", // Added (Brazil)
       "San Antonio", // Added
       "San Diego", // Added
       "San Francisco",
       "San Jose", // Added (USA)
       "San José", // Added (Costa Rica)
       "San Juan", // Added
       "San Salvador", // Added
       "Sana'a", // Added
       "Santiago",
       "Santo Domingo", // Added
       "São Paulo",
       "Sapporo", // Added
       "Seattle", // Added
       "Sendai",
       "Seoul",
       "Seville",
       "Shanghai",
       "Sharjah", // Added
       "Shenzhen",
       "Singapore",
       "Sofia", // Added
       "Stockholm",
       "Surabaya", // Added
       "Suva", // Added
       "Sydney",
       "Taipei",
       "Tallinn", // Added
       "Tashkent", // Added
       "Tbilisi", // Added
       "Tegucigalpa", // Added
       "Tehran", // Added
       "Tel Aviv", // Added
       "The Hague", // Added
       "Thessaloniki", // Added
       "Tianjin",
       "Tijuana", // Added
       "Tirana", // Added
       "Tokyo",
       "Toronto",
       "Tripoli", // Added
       "Tunis", // Added
       "Turin", // Added
       "Ulaanbaatar", // Added
       "Valencia",
       "Valletta", // Added
       "Vancouver", // Added
       "Vatican City", // Added
       "Venice",
       "Vienna",
       "Vientiane", // Added
       "Vilnius", // Added
       "Warsaw",
       "Washington, D.C.", // Added
       "Wellington", // Added
       "Wuhan",
       "Xi'an",
       "Yangon", // Added
       "Yaoundé", // Added
       "Yekaterinburg", // Added
       "Yerevan", // Added
       "Yokohama", // Added
       "Zagreb", // Added
       "Zurich"
   ]
    
    var filteredCities: [String] = []

       
       override func viewDidLoad() {
           super.viewDidLoad()
           tblCityList.delegate = self
           tblCityList.dataSource = self
           searchBar.delegate = self
           
           // Register a basic UITableViewCell
           tblCityList.register(UITableViewCell.self, forCellReuseIdentifier: "CityCell")
           
           // Fetch city list from API (fallback to local data)
           filteredCities = cities
           tblCityList.reloadData()
           fetchCityList()
       }
       
       // Fetch city list from API
       func fetchCityList() {
           let apiKey = "402b62629bb2473cb0b52917252503"
           let urlString = "https://api.weatherapi.com/v1/search.json?key=\(apiKey)&q=no"
           guard let url = URL(string: urlString) else { return }
           
           URLSession.shared.dataTask(with: url) { data, response, error in
               if let error = error {
                   print("API request error: \(error.localizedDescription)")
                   return
               }
               guard let data = data else {
                   print("No data received from API.")
                   return
               }
               
               // Debugging: Print raw JSON response
               if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) {
                   print("Raw JSON Response: \(jsonObject)")
               }
               
               do {
                   let cityResults = try JSONDecoder().decode([City].self, from: data)
                   DispatchQueue.main.async {
                       if cityResults.isEmpty {
                           print("No cities found, using local dataset.")
                       } else {
                           self.cities = cityResults.map { $0.name }
                           print("Fetched Cities: \(self.cities)")
                       }
                       self.tblCityList.reloadData()
                   }
               } catch {
                   print("Error decoding city list: \(error)")
               }
           }.resume()
       }
   }

// MARK: - UITableViewDataSource & UITableViewDelegate
extension AddNewLocation: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredCities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CityCell", for: indexPath)
        cell.textLabel?.text = filteredCities[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCity = filteredCities[indexPath.row]
        delegate?.didSelectCity(selectedCity)
        dismiss(animated: true)
    }
}

   // Helper structure to decode the city search API response.
   struct City: Codable {
       let name: String
   }


// MARK: - UISearchBarDelegate
extension AddNewLocation: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            // If search text is empty, show the full list.
            filteredCities = cities
        } else {
            // Otherwise, filter cities based on search text (case-insensitive)
            filteredCities = cities.filter { $0.lowercased().contains(searchText.lowercased()) }
        }
        tblCityList.reloadData()
    }
}



//----------------------------------------------
    
    /*
    weak var delegate: AddNewLocationDelegate?
    
    // This array will hold the list of city names fetched from the API.
    var cities: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tblCityList.delegate = self
        tblCityList.dataSource = self
        fetchCityList()
        
        tblCityList.register(UITableViewCell.self, forCellReuseIdentifier: "CityCell")

    }
    
    // Fetch a list of cities using the search endpoint.
    func fetchCityList() {
        let apiKey = "402b62629bb2473cb0b52917252503"  // Replace with your actual API key.
        // For demonstration, we use a generic query (e.g., "a") to return a list of cities.
        let urlString = "https://api.weatherapi.com/v1/search.json?key=\(apiKey)&q=london"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                // Try to decode error first
                if let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let errorDict = jsonObject["error"] as? [String: Any],
                   let message = errorDict["message"] as? String {
                    print("API error: \(message)")
                    return
                }
                
                do {
                    let cityResults = try JSONDecoder().decode([City].self, from: data)
                    self.cities = cityResults.map { $0.name }
                    print("Fetched Cities: \(self.cities)")
                    DispatchQueue.main.async {
                        self.tblCityList.reloadData()
                    }

                } catch {
                    print("Error decoding city list: \(error)")
                }
            }
            
        }.resume()

    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension AddNewLocation: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CityCell", for: indexPath)
        cell.textLabel?.text = cities[indexPath.row]
        return cell
    }
    
    // When a city is selected, pass it back via the delegate.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCity = cities[indexPath.row]
        delegate?.didSelectCity(selectedCity)
        dismiss(animated: true)
    }
}

// Helper structure to decode the city search API response.
struct City: Codable {
    let name: String
}

*/
