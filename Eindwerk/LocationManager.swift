import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    
    @Published var location: CLLocation?
    @Published var address: String = ""

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        self.location = location
        fetchAddress(from: location)
    }
    
    func fetchAddress(from location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            guard error == nil else {
                print("Failed to reverse geocode location: \(String(describing: error))")
                return
            }
            self.address = placemarks?.first?.compactAddress ?? "Unknown address"
        }
    }
}

extension CLPlacemark {
    var compactAddress: String? {
        if let name = name {
            var result = name
            if let street = thoroughfare {
                result += ", \(street)"
            }
            if let city = locality {
                result += ", \(city)"
            }
            if let country = country {
                result += ", \(country)"
            }
            return result
        }
        return nil
    }
}
