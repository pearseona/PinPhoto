import SwiftUI
import MapKit

class SearchViewModel: ObservableObject {
    
    @Published var searchQuery: String = ""
    
    // 장소 검색 로직
    func performSearch(currentRegion: MKCoordinateRegion, completion: @escaping(CLLocationCoordinate2D?) -> Void) {
        let trimmedQuery = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return }
        
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = trimmedQuery
        searchRequest.region = currentRegion
        
        // 검색 실행
        let localSearch = MKLocalSearch(request: searchRequest)
        localSearch.start { response, error in
            guard let response = response, error == nil else {
                print(" [검색 실패] 장소를 찾을 수 없습니다: \(error?.localizedDescription ?? "알 수 없는 에러")")
                
                let fallbackCoordinate = CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780)
                completion(fallbackCoordinate)
                return
            }
            
            // 가장 연관성 높은 첫 번째 장소의 좌표 변환
            if let firstMatch = response.mapItems.first {
                let coordinate = firstMatch.placemark.coordinate
                print(" [검색 성공] \(firstMatch.name ?? "장소") 좌표 획득 완료")
                completion(coordinate)
                
            } else {
                let fallbackCoordinate = CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780)
                completion(nil)
            }
        }
    }
}
