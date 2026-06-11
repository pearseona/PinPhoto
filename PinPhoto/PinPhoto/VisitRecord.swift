import Foundation

// 방문 곳을 지도에 핀으로 표시
struct VisitRecord: Identifiable, Codable {
    
    // 각각의 기록을 고유하게 식별한 PK (ID)
    let id: UUID
    
    // 위치 정보 (위도, 경도)
    let latitude: Double
    let longitude: Double
    
    // 사용자가 입력한 메모 제목
    let title: String
    
    // 사용자가 입력한 한 줄 메모
    let memo: String
    
    // 사진 바이너리 데이터
    let imageData: Data?
    
    // 기록된 날짜 및 시간
    let date: Date
}
