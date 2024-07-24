import SwiftUI

struct DataView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \AppLaunch.launchDate, ascending: true)],
        animation: .default)
    private var appLaunches: FetchedResults<AppLaunch>
    
    @StateObject private var locationManager = LocationManager()
    @State private var data: String = "Loading..."
    @State private var lastUpdated: Date?
    @State private var chartURL: URL?
    @State private var timer: Timer?
    
    var body: some View {
        VStack(spacing: 20) {
            Text(data)
                .font(.headline)
                .padding()
            
            if let location = locationManager.location {
                Text("Location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                if let address = locationManager.address {
                    Text(address)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            
            if let lastUpdated = lastUpdated {
                Text("Last updated: \(lastUpdated, formatter: DateFormatter.short)")
                    .font(.caption)
                    .foregroundColor(.secondary)
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
            
            if let chartURL = chartURL {
                AsyncImage(url: chartURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 200)
                        .padding()
                } placeholder: {
                    ProgressView()
                }
            } else {
                Text("No data available")
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(UIColor.systemGroupedBackground))
        .onAppear {
            loadData()
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    func fetchData() {
        let randomData = (1...10).map { _ in CGFloat.random(in: 1...10) }
        self.data = "Fetched Data"
        self.lastUpdated = Date()
        saveData(data: self.data, lastUpdated: self.lastUpdated!, chartData: randomData)
        self.chartURL = generateChartURL(with: randomData)
    }
    
    func loadData() {
        if let savedData = UserDefaults.standard.string(forKey: "savedData"),
           let savedLastUpdated = UserDefaults.standard.object(forKey: "lastUpdated") as? Date {
            self.data = savedData
            self.lastUpdated = savedLastUpdated
            if let savedChartData = UserDefaults.standard.array(forKey: "chartData") as? [CGFloat] {
                self.chartURL = generateChartURL(with: savedChartData)
            }
        } else {
            fetchData()
        }
    }
    
    func saveData(data: String, lastUpdated: Date, chartData: [CGFloat]) {
        UserDefaults.standard.set(data, forKey: "savedData")
        UserDefaults.standard.set(lastUpdated, forKey: "lastUpdated")
        UserDefaults.standard.set(chartData, forKey: "chartData")
        
        if let appLaunch = appLaunches.first {
            appLaunch.lastRefreshed = lastUpdated
        } else {
            let newAppLaunch = AppLaunch(context: viewContext)
            newAppLaunch.launchDate = Date()
            newAppLaunch.lastRefreshed = lastUpdated
        }
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    func generateChartURL(with data: [CGFloat]) -> URL? {
        let labels = data.enumerated().map { "\($0.offset + 1)" }
        let chartData = data.map { "\($0)" }
        let chartConfig = [
            "type": "bar",
            "data": [
                "labels": labels,
                "datasets": [
                    ["label": "Random Data",
                     "data": chartData]
                ]
            ]
        ] as [String : Any]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: chartConfig),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            let urlString = "https://quickchart.io/chart?c=\(jsonString)"
            return URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        }
        return nil
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
}

struct DataView_Previews: PreviewProvider {
    static var previews: some View {
        DataView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
