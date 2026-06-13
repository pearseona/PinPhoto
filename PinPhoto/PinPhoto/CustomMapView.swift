import SwiftUI
import MapKit

struct CustomMapView: UIViewRepresentable {
    
    @ObservedObject var viewModel: PinPhotoViewModel
    
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
        
        // 날짜순으로 정렬된 핀(Annotation) 매핑 및 등록
        let annotations = viewModel.records.map { record -> MKPointAnnotation in
            let anno = MKPointAnnotation()
            anno.coordinate = CLLocationCoordinate2D(latitude: record.latitude, longitude: record.longitude)
            anno.title = record.title
            return anno
        }
        uiView.addAnnotations(annotations)
        
        // 좌표가 2개 이상일 때만 타임라인 그리기
        let coords = sortedCoordinates
        if coords.count >= 2 {
            let polyline = MKPolyline(coordinates: coords, count: coords.count)
            uiView.addOverlay(polyline)
        }
        
        // 지도 중심점을 최신 등록된 추억 또는 현재 바인딩된 리전으로 동기화
        if let firstCoord = coords.last {
            let region = MKCoordinateRegion(
                center: firstCoord,
                span: uiView.region.span
            )
            uiView.setRegion(region, animated: true)
        }
    }
    
    // MapKit의 렌더링 파이프라인
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: CustomMapView
        
        init(_ parent: CustomMapView) {
            self.parent = parent
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
