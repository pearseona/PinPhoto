import SwiftUI

struct RecordRowView: View {
    
    let record: VisitRecord
    
    var body: some View {
        HStack(spacing: 12) {
            
            // 이미지 영역 (유저 이미지가 없으면 기본 플레이스홀더)
            if let data = record.imageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
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
            
            // 텍스트 정보 영역 (제목, 메모, 날짜)
            VStack(alignment: .leading, spacing: 4) {
                
                Text(record.title.isEmpty ? "제목 없음" : record.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(record.memo.isEmpty ? "추가된 메모가 없습니다." : record.memo)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                // 좌표 임시 표출 (추후 변경 예정
                Text(" 위도: \(String(format: "%.4f", record.latitude)), 경도: \(String(format: "%.4f", record.longitude))")
                    .font(.caption2)
                    .foregroundColor(.blue)
            }
            
            Spacer()
            
            // 우측 날짜 표출
            Text(formatDate(record.date))
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd HH:mm"
        return formatter.string(from: date)
    }
}
