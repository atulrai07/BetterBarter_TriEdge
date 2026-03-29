import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    
    @Published var locationString: String = ""
    @Published var isRequestingLocation: Bool = false
    @Published var coordinate: CLLocationCoordinate2D?
    @Published var location: CLLocation?
    
    override init() {
        super.init()
        manager.delegate = self
        // Set slightly lower accuracy for speed since we just need the city/neighborhood
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }
    
    func requestLocation() {
        isRequestingLocation = true
        manager.requestWhenInUseAuthorization()
        // requestLocation() will fetch a single ping of data and immediately turn off the GPS antenna!
        manager.requestLocation()
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            DispatchQueue.main.async {
                self.isRequestingLocation = false
            }
            return
        }
        
        // Convert the raw tracking coordinates into human-readable city strings
        let geocoder = CLGeocoder()
        let safeCoordinate = location.coordinate
        
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            DispatchQueue.main.async {
                self?.isRequestingLocation = false
                self?.coordinate = safeCoordinate
                self?.location = location
                
                if let error = error {
                    print("DEBUG: Geocoding error \(error.localizedDescription)")
                    self?.locationString = "Location Found"
                    return
                }
                
                if let placemark = placemarks?.first {
                    var locationParts: [String] = []
                    
                    if let locality = placemark.locality {
                        locationParts.append(locality)          // "San Francisco"
                    } else if let subLocality = placemark.subLocality {
                        locationParts.append(subLocality)       // "Mission District"
                    }
                    
                    if let administrativeArea = placemark.administrativeArea {
                        locationParts.append(administrativeArea) // "CA"
                    }
                    
                    let finalString = locationParts.isEmpty ? "Unknown Location" : locationParts.joined(separator: ", ")
                    self?.locationString = finalString
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("DEBUG: Location manager error \(error.localizedDescription)")
        DispatchQueue.main.async {
            self.isRequestingLocation = false
            self.locationString = "Location Failed"
        }
    }
}
