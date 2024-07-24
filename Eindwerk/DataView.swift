import SwiftUI
import CoreLocation

struct WeatherData: Codable {
    struct Main: Codable {
        let temp: Double?
        let humidity: Int?
    }
    struct Weather: Codable {
        let description: String?
    }
    let main: Main?
    let weather: [Weather]?
}

struct DataView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \AppLaunch.launchDate, ascending: true)],
        animation: .default)
    private var appLaunches: FetchedResults<AppLaunch>
    
    @StateObject private var locationManager = LocationManager()
    @State private var lastUpdated: Date?
    @State private var weatherData: WeatherData?
    @State private var timer: Timer?
    
    var body: some View {
        ZStack {
            // Voeg hier de achtergrondafbeelding toe
            Image("360_F_461232389_XCYvca9n9P437nm3FrCsEIapG4SrhufP")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all) // Zorg ervoor dat de afbeelding de volledige achtergrond bedekt
            
            VStack(spacing: 20) {
                Spacer()
                
                if let weatherData = weatherData, let main = weatherData.main, let weather = weatherData.weather?.first {
                    VStack {
                        Image(systemName: weatherIcon(for: weather.description))
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.yellow)
                        
                        Text("Temperature: \(main.temp ?? 0.0, specifier: "%.1f")°C")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                        
                        Text("Humidity: \(main.humidity ?? 0)%")
                            .font(.subheadline)
                            .foregroundColor(.white)
                        
                        Text("Condition: \(weather.description?.capitalized ?? "N/A")")
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .cornerRadius(20)
                } else {
                    Text("No weather data available")
                        .foregroundColor(.gray)
                        .cornerRadius(10)
                }
                
                if let location = locationManager.location {
                    Text("Location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
                        .font(.subheadline)
                        .foregroundColor(.black)
                        .cornerRadius(10)
                    
                    if let address = locationManager.address {
                        Text(address)
                            .font(.subheadline)
                            .foregroundColor(.black)
                            .cornerRadius(10)
                    }
                } else {
                    Text("Fetching location...")
                        .foregroundColor(.gray)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    fetchData()
                }) {
                    Text("Refresh Data")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Spacer()
                if let lastUpdated = lastUpdated {
                    Text("Last updated: \(lastUpdated, formatter: DateFormatter.short)")
                        .font(.caption)
                        .foregroundColor(.black)
                        .cornerRadius(10)
                }
                
                Spacer()
            }
            .padding()
        }
        .onAppear {
            loadData()
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    func fetchData() {
        guard let location = locationManager.location else {
            print("Location not available")
            return
        }
        
        let apiKey = "eb7a9979f66bf3da659cae552e1f2596"
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&units=metric&appid=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching weather data: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                let weatherData = try JSONDecoder().decode(WeatherData.self, from: data)
                DispatchQueue.main.async {
                    self.weatherData = weatherData
                    self.lastUpdated = Date()
                    saveData(lastUpdated: self.lastUpdated!, weatherData: weatherData)
                }
            } catch {
                print("Failed to decode weather data: \(error)")
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Received JSON: \(jsonString)")
                }
            }
        }
        
        task.resume()
    }
    
    func loadData() {
        if let savedLastUpdated = UserDefaults.standard.object(forKey: "lastUpdated") as? Date,
           let savedWeatherData = UserDefaults.standard.data(forKey: "savedWeatherData") {
            self.lastUpdated = savedLastUpdated
            do {
                let weatherData = try JSONDecoder().decode(WeatherData.self, from: savedWeatherData)
                self.weatherData = weatherData
            } catch {
                print("Failed to decode saved weather data: \(error)")
            }
        } else {
            fetchData()
        }
    }
    
    func saveData(lastUpdated: Date, weatherData: WeatherData) {
        do {
            let encodedWeatherData = try JSONEncoder().encode(weatherData)
            UserDefaults.standard.set(lastUpdated, forKey: "lastUpdated")
            UserDefaults.standard.set(encodedWeatherData, forKey: "savedWeatherData")
            
            if let appLaunch = appLaunches.first {
                appLaunch.lastRefreshed = lastUpdated
            } else {
                let newAppLaunch = AppLaunch(context: viewContext)
                newAppLaunch.launchDate = Date()
                newAppLaunch.lastRefreshed = lastUpdated
            }
            
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { _ in
            fetchData()
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func weatherIcon(for description: String?) -> String {
        switch description?.lowercased() {
        case "clear sky":
            return "sun.max.fill"
        case "few clouds":
            return "cloud.sun.fill"
        case "scattered clouds", "broken clouds":
            return "cloud.fill"
        case "shower rain", "rain":
            return "cloud.rain.fill"
        case "thunderstorm":
            return "cloud.bolt.fill"
        case "snow":
            return "snow"
        case "mist":
            return "cloud.fog.fill"
        default:
            return "cloud.fill"
        }
    }
}

struct DataView_Previews: PreviewProvider {
    static var previews: some View {
        DataView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
