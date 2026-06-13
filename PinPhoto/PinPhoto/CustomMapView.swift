import SwiftUI
import MapKit

struct CustomMapView: UIViewRepresentable {
    
    @ObservedObject var viewModel: PinPhotoViewModel
    @Binding var searchedCoordinate: CLLocationCoordinate2D?
    @Binding var centerCoordinate: CLLocationCoordinate2D
    
    // 저장된 추억들을 날짜 오름차순으로 정렬하여 동선 좌표 배열 추출
    var sortedCoordinates: [CLLocationCoordinate2D] {
        return viewModel.records
            .sorted(by: { $0.date < $1.date }) // 과거순 정렬
            .map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        
        mapView.showsUserLocation = true
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        
        // 기존의 오버레이(선), 핀 제거
        uiView.removeOverlays(uiView.overlays)
        uiView.removeAnnotations(uiView.annotations)
        
        // 좌표가 2개 이상일 때만 타임라인 그리기
        let coords = sortedCoordinates
        if coords.count >= 2 {
            let polyline = MKPolyline(coordinates: coords, count: coords.count)
            uiView.addOverlay(polyline)
        }
        
        // 검색 기능 디버깅 파이프라인
        if let searchTarget = searchedCoordinate {
            
            // 장소 검색 성공 시 해당 좌표로 이동
            let customSpan = MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
            let region = MKCoordinateRegion(center: searchTarget, span: customSpan)
            uiView.setRegion(region, animated: true)
            
            DispatchQueue.main.async {
                self.searchedCoordinate = nil
            }
        }
    }
    
    // MapKit의 렌더링 파이프라인
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: CustomMapView
        
        private var hasInitialZoomed = false
        
        init(_ parent: CustomMapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            DispatchQueue.main.async {
                self.parent.centerCoordinate = mapView.centerCoordinate
            }
        }
        
        func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
            if !hasInitialZoomed {
                let userSpan = MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
                let region = MKCoordinateRegion(center: userLocation.coordinate, span: userSpan)
                mapView.setRegion(region, animated: true)
                
                hasInitialZoomed = true
            }
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                
                renderer.strokeColor = UIColor(red: 23/255, green: 111/255, blue: 247/255, alpha: 0.85)
                renderer.lineWidth = 4.0
                renderer.lineCap = .round
                renderer.lineJoin = .round
                return renderer
            }
            return MKOverlayRenderer()
        }
    }
}
