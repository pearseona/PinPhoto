import Foundation
import Combine
import MapKit
import CoreLocation

class PinPhotoViewModel: ObservableObject {
    
    @Published var records: [VisitRecord] = []
    @Published var selectedTab: Int = 0
    
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.5824, longitude: 127.0103),
        span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
    )
    
    private let userDefaultsKey = "PinPhoto_VisitRecords"
    
    init() {
        
        self.selectedTab = 0
        
        loadFromUserDefaults()
        
        DispatchQueue.main.async {
            self.selectedTab = 0
        }
    }
    
    // 특정 기록 위치로 지도 이동 및 탭 전환
    func moveMapTo(record: VisitRecord) {
        
        self.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: record.latitude, longitude: record.longitude),
            span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        )
        self.selectedTab = 0
        print(" [ViewModel] '\(record.title)' 위치로 지도 시점 이동 및 탭 전환 완료!")
    }
    
    // 새로운 추억 기록을 배열에 추가
    func addRecord(title: String, latitude: Double, longitude: Double, memo: String, imageData: Data?, category: MemoryCategory) {
        
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self else { return }
            
            var parsedAddress = "위치 정보 불명"
            
            if let error = error {
                print(" [ViewModel Geocoder 에러]: \(error.localizedDescription)")
            } else if let placemark = placemarks?.first {
                
                let city = placemark.administrativeArea ?? ""
                let locality = placemark.locality ?? ""
                let subLocality = placemark.subLocality ?? ""
                let rawAddress = "\(city) \(locality) \(subLocality)"
                let cleanedAddress = rawAddress.components(separatedBy: .whitespacesAndNewlines)
                    .filter { !$0.isEmpty }
                    .joined(separator: " ")
                                
                if !cleanedAddress.isEmpty {
                    parsedAddress = cleanedAddress
                }
            }
            
            DispatchQueue.main.async {
                // VisitRecord 인스턴스 생성
                let newRecord = VisitRecord(
                    id: UUID(), //  고유한 식별자 자동 생성
                    latitude: latitude,
                    longitude: longitude,
                    address: "📍 \(parsedAddress)",
                    title: title,
                    memo: memo,
                    imageData: imageData,
                    date: Date(), // 현재 기록하는 시점의 날짜/시간 저장
                    category: category
                )
                self.records.insert(newRecord, at: 0)
                self.saveToUserDefaults()
                print(" [ViewModel] 새로운 기록 저장 완료 및 로컬 DB 동기화 성공!")
            }
        }
    }
    
    // 기존 레코드 내용 수정 및 로컬 DB 동기화
    func updateRecord(_ updatedRecord: VisitRecord) {
        DispatchQueue.main.async {
            if let index = self.records.firstIndex(where: { $0.id == updatedRecord.id }) {
                self.records[index] = updatedRecord
                self.saveToUserDefaults() // 변경된 데이터 영구 저장
                print(" [ViewModel] 추억 레코드 수정 완료 및 로컬 DB 업데이트 성공: \(updatedRecord.title)")
            }
        }
    }
    
    // 특정 인덱스의 레코드 제거 및 로컬 DB 동기화
    func deleteRecord(at index: Int) {
        guard index >= 0 && index < records.count else { return }
        let removedTitle = records[index].title
        records.remove(at: index)
        saveToUserDefaults()
        print(" [ViewModel] 레코드 삭제 완료 및 로컬 DB 동기화 성공: \(removedTitle)")
    }
    
    // 현재 메모리에 있는 records 배열을 JSON으로 직렬화하여 영구 저장
    private func saveToUserDefaults() {
        do {
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(self.records)
            
            UserDefaults.standard.set(encodedData, forKey: userDefaultsKey)
        } catch {
            print(" [ViewModel 데이터 인코딩 및 저장 실패: \(error.localizedDescription)")
        }
    }
    
    // 앱 실행 시 로컬에 저장된 JSON을 읽어와서 역직렬화
    private func loadFromUserDefaults() {
        
        guard let savedData = UserDefaults.standard.data(forKey: userDefaultsKey) else {
            print(" [ViewModel] 기존에 저장된 데이터가 없습니다. 빈 상태로 시작합니다.")
            return
        }
        
        do {
            let decoder = JSONDecoder()
            let decodedRecords = try decoder.decode([VisitRecord].self, from: savedData)
            
            DispatchQueue.main.async {
                self.records = decodedRecords
                print(" [ViewModel] 로컬 DB 로드 성공! 총 \(self.records.count)개의 추억을 복원했습니다.")
            }
        } catch {
            print(" [ViewModel] 데이터 불러오기 및 디코딩 실패: \(error.localizedDescription)")
        }
    }
}
