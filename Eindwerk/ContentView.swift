import SwiftUI
import CoreLocation

extension DateFormatter {
    static var short: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }
}

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var data: String = "Loading..."
    @State private var lastUpdated: Date?
    @State private var firstLaunchDate: Date?
    @State private var chartURL: URL?

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundColor(.accentColor)
                    .padding(.top, 20)

                Text(data)
                    .font(.headline)
                    .padding(.horizontal)
                
                if let location = locationManager.location {
                    Text("Location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.bottom, 5)
                }
                
                Text(locationManager.address)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.bottom, 5)

                if let firstLaunchDate = firstLaunchDate {
                    Text("First launched: \(firstLaunchDate, formatter: DateFormatter.short)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 5)
                }

                if let lastUpdated = lastUpdated {
                    Text("Last updated: \(lastUpdated, formatter: DateFormatter.short)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 20)
                }

                Button(action: {
                    fetchData()
                }) {
                    Text("Refresh Data")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                if let chartURL = chartURL {
                    AsyncImage(url: chartURL) { image in
                        image
                            .resizable()
                            .scaledToFit()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(height: 300)
                    .padding(.horizontal)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)
                    .shadow(radius: 5)
                } else {
                    Text("No data available")
                        .foregroundColor(.gray)
                }
            }
            .padding()
        }
        .onAppear {
            loadData()
        }
    }

    func fetchData() {
        // Generate random data for the chart
        let randomData = (1...6).map { _ in CGFloat.random(in: 0...100) }
        self.chartURL = generateChartURL(with: randomData)
        self.data = "Fetched Random Data"
        self.lastUpdated = Date()
        saveData(data: self.data, lastUpdated: self.lastUpdated, chartData: randomData)
    }

    func generateChartURL(with data: [CGFloat]) -> URL? {
        let labels = data.enumerated().map { "\($0.offset + 1)" }
        let chartData = data.map { "\($0)" }
        let chartConfig = [
            "type": "bar",
            "data": [
                "labels": labels,
                "datasets": [
                    ["label": "Random Data", "data": chartData]
                ]
            ]
        ] as [String : Any]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: chartConfig),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            let urlString = "https://quickchart.io/chart?c=\(jsonString)"
                .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            return URL(string: urlString)
        }
        return nil
    }

    func loadData() {
        if let savedData = UserDefaults.standard.string(forKey: "savedData") {
            self.data = savedData
        }
        if let lastUpdated = UserDefaults.standard.object(forKey: "lastUpdated") as? Date {
            self.lastUpdated = lastUpdated
        }
        if let firstLaunchDate = UserDefaults.standard.object(forKey: "firstLaunchDate") as? Date {
            self.firstLaunchDate = firstLaunchDate
        } else {
            self.firstLaunchDate = Date()
            UserDefaults.standard.set(self.firstLaunchDate, forKey: "firstLaunchDate")
        }
        if let savedEntries = UserDefaults.standard.array(forKey: "chartData") as? [CGFloat] {
            self.chartURL = generateChartURL(with: savedEntries)
        } else {
            fetchData()
        }
    }

    func saveData(data: String, lastUpdated: Date?, chartData: [CGFloat]) {
        UserDefaults.standard.set(data, forKey: "savedData")
        if let lastUpdated = lastUpdated {
            UserDefaults.standard.set(lastUpdated, forKey: "lastUpdated")
        }
        UserDefaults.standard.set(chartData, forKey: "chartData")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
