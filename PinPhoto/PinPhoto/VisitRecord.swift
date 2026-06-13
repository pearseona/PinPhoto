import Foundation

// 추억의 종류를 구분할 카데고리 열거형
enum MemoryCategory: String, Codable, CaseIterable {
    case food = "맛집"
    case culture = "문화"
    case travel = "여행"
    case daily = "일상"
    
    var iconName: String {
        switch self {
        case .food: return "fork.knife"
        case .culture: return "ticker.fill"
        case .travel: return "globe.asia.australia.fill"
        case .daily: return "heart.text.square.fill"
        }
    }
}

// 방문 곳을 지도에 핀으로 표시
struct VisitRecord: Identifiable, Codable {
    
    // 각각의 기록을 고유하게 식별한 PK (ID)
    let id: UUID
    
    // 위치 정보 (위도, 경도)
    let latitude: Double
    let longitude: Double
    
    var address: String?
    
    // 사용자가 입력한 메모 제목
    let title: String
    
    // 사용자가 입력한 한 줄 메모
    let memo: String
    
    // 사진 바이너리 데이터
    let imageData: Data?
    
    // 기록된 날짜 및 시간
    let date: Date
    
    var category: MemoryCategory = .daily
}
