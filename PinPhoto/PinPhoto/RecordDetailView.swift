import SwiftUI

struct RecordDetailView: View {
    
    let record: VisitRecord
    
    @ObservedObject var viewModel: PinPhotoViewModel
    
    let deepOceanBlue = Color(red: 26/255, green: 75/255, blue: 143/255)
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // 대형 사진 영역
                if let data = record.imageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, minHeight: 300, maxHeight: 400)
                        .cornerRadius(16)
                        .shadow(radius: 5)
                        .clipped()
                } else {
                    
                    // 사진이 없는 경우
                    VStack(spacing: 12) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("등록된 사진이 없습니다.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, minHeight: 250)
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                }
                
                // 텍스트 정보 영역
                VStack(alignment: .leading, spacing: 16) {
                    
                    // 제목 파트
                    VStack(alignment: .leading, spacing: 6) {
                        Text("제목")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .bold()
                        Text(record.title.isEmpty ? "제목 없음" : record.title)
                            .font(.title2)
                            .bold()
                            .foregroundColor(.primary)
                    }
                    
                    Divider()
                    
                    // 메모 파트
                    VStack(alignment: .leading, spacing: 6) {
                        Text("기록된 메모")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .bold()
                        Text(record.memo.isEmpty ? "추가된 메모가 없습니다." : record.memo)
                            .font(.body)
                            .foregroundColor(.primary)
                            .lineSpacing(4)
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(14)
                
                // 지도 바로가기 버튼 액션 파이프라인
                Button(action: {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        viewModel.moveMapTo(record: record)
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "mappin.and.ellipse")
                        Text("지도에서 위치 확인하기")
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(deepOceanBlue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(color: deepOceanBlue.opacity(0.3), radius: 4, x: 0, y: 3)
                }
                .padding(.top, 8)
                
                Spacer()
            }
            .padding()
        }
        .navigationBarTitle(record.title.isEmpty ? "상세 보기" : record.title, displayMode: .inline)
    }
}
