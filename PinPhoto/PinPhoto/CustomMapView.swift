import SwiftUI
import CoreLocation
import MapKit

struct CustomMapView: UIViewRepresentable {
    
    @ObservedObject var viewModel: PinPhotoViewModel
    @Binding var searchedCoordinate: CLLocationCoordinate2D?
    @Binding var centerCoordinate: CLLocationCoordinate2D
    
    var sortedCoordinates: [CLLocationCoordinate2D] {
        return viewModel.records
            .sorted(by: { $0.date < $1.date })
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
        uiView.removeOverlays(uiView.overlays)
        uiView.removeAnnotations(uiView.annotations)
        
       
        let annotations = viewModel.records.map { $0 as MKAnnotation }
        uiView.addAnnotations(annotations)
        
        let coords = sortedCoordinates
        if coords.count >= 2 {
            let polyline = MKPolyline(coordinates: coords, count: coords.count)
            uiView.addOverlay(polyline)
        }
        
        if let searchTarget = searchedCoordinate {
            let customSpan = MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
            let region = MKCoordinateRegion(center: searchTarget, span: customSpan)
            uiView.setRegion(region, animated: true)
            
            DispatchQueue.main.async {
                self.centerCoordinate = searchTarget
                self.searchedCoordinate = nil
            }
        }
    }
    
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
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation { return nil }
            
           
            guard let record = annotation as? VisitRecord else { return nil }
            
            let reuseId = "MemoryPin"
            
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
            
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                annotationView?.canShowCallout = true
            } else {
                annotationView?.annotation = annotation
            }
            
            let size = CGSize(width: 50, height: 50)
            let containerView = UIView(frame: CGRect(origin: .zero, size: size))
            
            let imageView = UIImageView(frame: CGRect(x: 2, y: 2, width: 46, height: 46))
            imageView.contentMode = .scaleAspectFill
            imageView.layer.cornerRadius = 23
            imageView.layer.masksToBounds = true
            
            imageView.layer.borderWidth = 2.5
            imageView.layer.borderColor = UIColor(red: 23/255, green: 111/255, blue: 247/255, alpha: 1.0).cgColor
            
            if let imgData = record.imageData, let uiImage = UIImage(data: imgData) {
                imageView.image = uiImage
            } else {
                imageView.image = UIImage(systemName: "mappin.circle.fill")
                imageView.tintColor = .systemRed
                imageView.backgroundColor = .white
            }
            
            containerView.addSubview(imageView)
            
            annotationView?.frame = containerView.frame
            annotationView?.addSubview(containerView)
            annotationView?.layer.shadowColor = UIColor.black.cgColor
            annotationView?.layer.shadowOpacity = 0.15
            annotationView?.layer.shadowOffset = CGSize(width: 0, height: 3)
            annotationView?.layer.shadowRadius = 4
            
            return annotationView
        }
    }
}
