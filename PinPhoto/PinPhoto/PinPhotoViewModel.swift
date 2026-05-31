import Foundation
import Combine

class PinPhotoViewModel: ObservableObject {
    
    // 지도와 리스트 뷰가 바라볼 데이터 배열 (전역 상태)
    @Published var records: [VisitRecord] = []
    
    init() {
        
    }
    
    // 새로운 추억 기록을 배열에 추가하는 로직 함수
    func addRecord(latitude: Double, longitude: Double, memo: String, imageData: Data?) {
        
        // VisitRecord 인스턴스 생성
        let newRecord = VisitRecord(
            id: UUID(), //  고유한 식별자 자동 생성
            latitude: latitude,
            longitude: longitude,
            memo: memo,
            imageData: imageData,
            date: Date() // 현재 기록하는 시점의 날짜/시간 저장
        )
        
        self.records.insert(newRecord, at: 0)
        
        print(" [ViewModel] 새로운 기록이 메모리에 임시 추가되었습니다. 현재 총 기록 수: \(self.records.count)개")
    }
}
