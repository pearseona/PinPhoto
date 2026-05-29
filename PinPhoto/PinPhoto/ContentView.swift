import SwiftUI
import MapKit

struct ContentView: View {
    
    @StateObject private var locationManager = LocationManager()
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780),
        span: MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)
    )
    
    var body: some View {
        
        Map(coordinateRegion: $region, showsUserLocation: true)
            .onReceive(locationManager.$location) { newLocation in
                if let coordinate = newLocation?.coordinate {
                    withAnimation {
                        region.center = coordinate
                    }
                }
            }
            .edgesIgnoringSafeArea(.bottom)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


