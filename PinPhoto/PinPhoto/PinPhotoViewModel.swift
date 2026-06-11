import Foundation
import Combine

class PinPhotoViewModel: ObservableObject {
    
    // 지도와 리스트 뷰가 바라볼 데이터 배열 (전역 상태)
    @Published var records: [VisitRecord] = []
    
    private let userDefaultsKey = "PinPhoto_VisitRecords"
    
    init() {
        loadFromUserDefaults()
    }
    
    // 새로운 추억 기록을 배열에 추가하는 로직 함수
    func addRecord(title: String, latitude: Double, longitude: Double, memo: String, imageData: Data?) {
        
        // VisitRecord 인스턴스 생성
        let newRecord = VisitRecord(
            id: UUID(), //  고유한 식별자 자동 생성
            latitude: latitude,
            longitude: longitude,
            title: title,
            memo: memo,
            imageData: imageData,
            date: Date() // 현재 기록하는 시점의 날짜/시간 저장
        )
        
        self.records.insert(newRecord, at: 0)
        
        saveToUserDefaults()
        print(" [ViewModel] 새로운 기록 저장 완료 및 로컬 DB 동기화 성공!")
    }
    
    // [Save] 현재 메모리에 있는 records 배열을 JSON으로 직렬화하여 영구 저장
    private func saveToUserDefaults() {
        do {
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(self.records)
            
            UserDefaults.standard.set(encodedData, forKey: userDefaultsKey)
        } catch {
            print(" [ViewModel 데이터 인코딩 및 저장 실패: \(error.localizedDescription)")
        }
    }
    
    // [Read]  앱 실행 시 로컬에 저장된 JSON을 읽어와서 역직렬화(복원)
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
