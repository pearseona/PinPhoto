import SwiftUI
import CoreLocation

struct RecordRowView: View {
    
    let record: VisitRecord
    
    @State private var addressText: String = "주소 변환 중..."
    
    let deepOceanBlue = Color(red: 23/255, green: 111/255, blue: 247/255)
    let midnightText = Color(red: 30/255, green: 42/255, blue: 58/255)
    let iconGray = Color(red: 140/255, green: 151/255, blue: 167/255)
    
    var body: some View {
        HStack(spacing: 16) {
            
            // 이미지 영역
            if let data = record.imageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 65, height: 65)
                    .cornerRadius(10)
                    .clipped()
            } else {
                // 이미지가 없을 때
                ZStack {
                    Color(red: 235/255, green: 243/255, blue: 255/255)
                    Image(systemName: "photo")
                        .foregroundColor(deepOceanBlue)
                }
                .frame(width: 65, height: 65)
                .cornerRadius(10)
            }
            
            // 텍스트 정보 영역
            VStack(alignment: .leading, spacing: 5) {
                
                // 제목
                Text(record.title.isEmpty ? "제목 없음" : record.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(midnightText)
                    .lineLimit(1)
                
                // 역지오코딩 주소
                Text(addressText)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(iconGray)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // 우측 날짜 표출
            Text(formatDate(record.date))
                .font(.system(size: 12))
                .foregroundColor(iconGray)
        }

        .padding(.vertical, 2)
        .onAppear {
            fetchAddress()
        }
    }
    
    // 애플 지도 서버에 한글 주소 요청 및 역지오코딩 파이프라인
    private func fetchAddress() {
        let location = CLLocation(latitude: record.latitude, longitude: record.longitude)
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print(" [Geocoder 에러]: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.addressText = "📍 주소 변환 실패"
                }
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
