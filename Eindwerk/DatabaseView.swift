import SwiftUI

struct DatabaseView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \AppLaunch.launchDate, ascending: true)],
        animation: .default)
    private var appLaunches: FetchedResults<AppLaunch>
    
    var body: some View {
        List {
            Section(header: Text("Database Entries")) {
                ForEach(appLaunches) { appLaunch in
                    VStack(alignment: .leading) {
                        Text("Launch Date: \(appLaunch.launchDate!, formatter: DateFormatter.short)")
                        if let lastRefreshed = appLaunch.lastRefreshed {
                            Text("Last Refreshed: \(lastRefreshed, formatter: DateFormatter.short)")
                        }
                    }
                }
            }
        }
        .navigationTitle("Database Entries")
    }
}

struct DatabaseView_Previews: PreviewProvider {
    static var previews: some View {
        DatabaseView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
