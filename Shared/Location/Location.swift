//  Location.swift

import WatchKit

class Location: NSObject, CLLocationManagerDelegate {
    
    static let shared = Location()
    
    let locationMgr = CLLocationManager()
    var locationNow: CLLocation?
    
    override init() {
        super.init()
        locationMgr.delegate = self
    }
    
    // MARK: - CLLocationManagerDelegate -------------------------
    
     func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            locationNow = location
            Log("📍 update: \(location)")
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Log("📍 error: \(error)")
    }
    func requestApproval() {
        DispatchQueue.main.async {
             self.locationMgr.requestWhenInUseAuthorization()
        }
    }
    func requestLocation(_ completion: @escaping CallVoid) {
        
        switch  CLLocationManager.authorizationStatus() {
        case .notDetermined:        requestApproval()
        case .authorizedWhenInUse:  locationMgr.requestLocation()
        case .denied: return
        default: return
        }
        completion()
    }
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        DispatchQueue.main.async() {
            switch status {
            case .authorizedWhenInUse:  self.locationMgr.requestLocation()
            case .denied:               return
            default:                    return
            }
        }
    }
    func stopLocation() {
        locationMgr.stopUpdatingLocation()
    }
    
    func getLocation() -> CLLocationCoordinate2D {
     
        stopLocation()
    
        let coord = locationNow != nil
            ? locationNow!.coordinate
            : CLLocationCoordinate2DMake(0, 0)
        return coord
    }

}
