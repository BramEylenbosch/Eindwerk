import SwiftUI

struct HomeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \AppLaunch.launchDate, ascending: true)],
        animation: .default)
    private var appLaunches: FetchedResults<AppLaunch>
    
    var body: some View {
        NavigationView {
            ZStack {
                // Voeg hier de achtergrondafbeelding toe
                Image("360_F_461232389_XCYvca9n9P437nm3FrCsEIapG4SrhufP")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all) // Zorg ervoor dat de afbeelding de volledige achtergrond bedekt
                
                VStack(spacing: 30) {
                    Spacer()
                    
                    VStack {
                        Image(systemName: "cloud.sun.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.yellow)
                        
                        Text("Weather App")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    Text("Get the latest weather updates and forecasts.")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    Spacer()
                    
                    NavigationLink(destination: DataView()) {
                        Text("View Weather")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.horizontal, 40)
                    }
                    
                    NavigationLink(destination: DatabaseView()) {
                        Text("View Database")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.horizontal, 40)
                    }
                    
                    Spacer()
                    
                    if let firstLaunch = appLaunches.first?.launchDate {
                        Text("First Launch: \(firstLaunch, formatter: DateFormatter.short)")
                            .font(.caption)
                            .foregroundColor(.black)
                    }
                }
                .padding()
                .cornerRadius(20)
                .padding()
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
