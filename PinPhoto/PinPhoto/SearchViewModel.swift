import SwiftUI
import MapKit

class SearchViewModel: ObservableObject {
    
    @Published var searchQuery: String = ""
    
    // 장소 검색 로직 (가상머신 시스템 결함 차단 및 일반 웹 통신 URLSession 우회)
    func performSearch(currentRegion: MKCoordinateRegion, completion: @escaping(CLLocationCoordinate2D?) -> Void) {
        let trimmedQuery = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return }
        
        print(" [가상머신 네트워크 우회] '\(trimmedQuery)' 웹 API 기반 역지오코딩 세션 가동")
        
        // 일반 웹 서핑 통신망(포트 80/443)으로 공용 위경도 검색 파이프라인으로 직접 요청
        let allowedCharacterSet = CharacterSet.urlQueryAllowed
        guard let encodedQuery = trimmedQuery.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet),
              let url = URL(string: "https://nominatim.openstreetmap.org/search?q=\(encodedQuery)&format=json&limit=1&addressdetails=1") else {
            completion(nil)
            return
        }
        
        // 가상머신의 차단 가드를 통과
        var request = URLRequest(url: url)
        request.setValue("PinPhotoApp/1.0 (suna_bae@hansung.ac.kr)", forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 5.0 // 타임아웃 5초 설정
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print(" [웹 API 우회 실패]: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                completion(nil)
                return
            }
            
            // JSON 응답 구조체 파싱
            do {
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]],
                   let firstResult = jsonArray.first,
                   let latStr = firstResult["lat"] as? String,
                   let lonStr = firstResult["lon"] as? String,
                   let latitude = Double(latStr),
                   let longitude = Double(lonStr) {
                    
                    let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    print(" [웹 API 검색 성공] '\(trimmedQuery)' 좌표 확보 완료 -> 위도: \(latitude), 경도: \(longitude)")
                    
                    DispatchQueue.main.async {
                        completion(coordinate)
                    }
                } else {
                    print(" [웹 API] 일치하는 장소 결과가 존재하지 않습니다.")
                    completion(nil)
                }
            } catch {
                print(" [JSON 디코딩 에러]: \(error.localizedDescription)")
                completion(nil)
            }
        }.resume()
    }
}
