import SwiftUI
import CoreData

struct DatabaseView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \AppLaunch.launchDate, ascending: true)],
        animation: .default)
    private var appLaunches: FetchedResults<AppLaunch>
    
    var body: some View {
        VStack {
            Text("Database Entries")
                .font(.largeTitle)
                .padding()
            
            if let firstLaunch = appLaunches.first?.launchDate {
                Text("First Launch: \(firstLaunch, formatter: DateFormatter.short)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Text("No launch data available")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
}

struct DatabaseView_Previews: PreviewProvider {
    static var previews: some View {
        DatabaseView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
