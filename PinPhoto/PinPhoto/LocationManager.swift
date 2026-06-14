import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    private let manager = CLLocationManager()
    
    @Published var location: CLLocation?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        
        
        // 앱 실행 시 위치 권한 요청
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    // 위치가 업데이트될 때 호출되는 델리게이트 메서드
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let targetLocation = locations.last else { return }
        DispatchQueue.main.async {
            self.location = targetLocation
        }
    }
    
    // 권한 상태가 변경될 때 호출되는 메서드
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        case .denied, .restricted:
            print("위치 권한 거부됨")
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        @unknown default:
            break
        }
    }
}
