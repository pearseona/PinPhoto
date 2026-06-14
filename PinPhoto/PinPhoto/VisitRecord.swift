import Foundation
import CoreLocation
import MapKit


class VisitRecord: NSObject, Identifiable, Codable, MKAnnotation {
    
    let id: UUID
    let latitude: Double
    let longitude: Double
    var address: String?
    
    private var _title: String
    var title: String? {
        get { return _title }
        set { _title = newValue ?? "" }
    }
    
    let memo: String
    let imageData: Data?
    let date: Date
    var category: MemoryCategory = .daily
    
 
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var subtitle: String? {
        return memo
    }
    

    init(id: UUID = UUID(), latitude: Double, longitude: Double, address: String? = nil, title: String, memo: String, imageData: Data?, date: Date, category: MemoryCategory = .daily) {
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
        self._title = title
        self.memo = memo
        self.imageData = imageData
        self.date = date
        self.category = category
        super.init()
    }
    
  
    enum CodingKeys: String, CodingKey {
        case id, latitude, longitude, address, title, memo, imageData, date, category
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.latitude = try container.decode(Double.self, forKey: .latitude)
        self.longitude = try container.decode(Double.self, forKey: .longitude)
        self.address = try container.decodeIfPresent(String.self, forKey: .address)
        self._title = try container.decode(String.self, forKey: .title)
        self.memo = try container.decode(String.self, forKey: .memo)
        self.imageData = try container.decodeIfPresent(Data.self, forKey: .imageData)
        self.date = try container.decode(Date.self, forKey: .date)
        self.category = try container.decodeIfPresent(MemoryCategory.self, forKey: .category) ?? .daily
        super.init()
    }
    

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
        try container.encodeIfPresent(address, forKey: .address)
        try container.encode(_title, forKey: .title)
        try container.encode(memo, forKey: .memo)
        try container.encodeIfPresent(imageData, forKey: .imageData)
        try container.encode(date, forKey: .date)
        try container.encode(category, forKey: .category)
    }
}


enum MemoryCategory: String, Codable, CaseIterable {
    case food = "맛집"
    case culture = "문화"
    case travel = "여행"
    case daily = "일상"
    
    var iconName: String {
        switch self {
        case .food: return "fork.knife"
        case .culture: return "theatermasks.fill"
        case .travel: return "airplane.departure"
        case .daily: return "heart.text.square.fill"
        }
    }
}
