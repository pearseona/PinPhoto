import SwiftUI
import CoreLocation

struct RecordRowView: View {
    
    let record: VisitRecord
    
    @State private var addressText: String = "주소 변환 중..."
    
    var body: some View {
        HStack(spacing: 12) {
            
            // 이미지 영역 (유저 이미지가 없으면 기본 플레이스홀더)
            if let data = record.imageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
                    .clipped()
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .padding(10)
                    .background(Color(.systemGray6))
                    .foregroundColor(.gray)
                    .cornerRadius(8)
            }
            
            // 텍스트 정보 영역
            VStack(alignment: .leading, spacing: 4) {
                
                // 제목
                Text(record.title.isEmpty ? "제목 없음" : record.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                // 메오
                Text(record.memo.isEmpty ? "추가된 메모가 없습니다." : record.memo)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                // 좌표 (위경도 주소)
                Text(addressText)
                    .font(.caption2)
                    .foregroundColor(.blue)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // 우측 날짜 표출
            Text(formatDate(record.date))
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
        
        .onAppear {
            fetchAddress()
        }
    }
    
    // 애플 지도 서버에 한글 주소 요청
    private func fetchAddress() {
        let location = CLLocation(latitude: record.latitude, longitude: record.longitude)
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print(" [Geocoder 에러]: \(error.localizedDescription)")
                self.addressText = "📍 주소 변환 실패"
                return
            }
            
            if let placemark = placemarks?.first {
                let city = placemark.administrativeArea ?? ""
                let locality = placemark.locality ?? ""
                let subLocality = placemark.subLocality ?? ""
                
                let rawAddress = "\(city) \(locality) \(subLocality)"
                let cleanedAddress = rawAddress.components(separatedBy: .whitespacesAndNewlines)
                    .filter { !$0.isEmpty }
                    .joined(separator: " ")
                
                DispatchQueue.main.async {
                    self.addressText = cleanedAddress.isEmpty ? "📍 주소 불명" : "📍 \(cleanedAddress)"
                }
            
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd HH:mm"
        return formatter.string(from: date)
    }
}
