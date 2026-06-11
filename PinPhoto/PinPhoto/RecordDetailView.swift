import SwiftUI
import MapKit

struct RecordDetailView: View {
    
    let record: VisitRecord
    
    @ObservedObject var viewModel: PinPhotoViewModel
    
    let deepOceanBlue = Color(red: 23/255, green: 111/255, blue: 247/255)
    let midnightText = Color(red: 30/255, green: 42/255, blue: 58/255)
    let iconGray = Color(red: 140/255, green: 151/255, blue: 167/255)
    let lightBlueGray = Color(red: 245/255, green: 247/255, blue: 250/255)
    
    var body: some View {
    
        ZStack {
            lightBlueGray
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    
                    // 대형 사진 영역
                    if let data = record.imageData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity, minHeight: 280, maxHeight: 350)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
                            .clipped()
                    } else {
                        
                        // 사진이 없는 경우
                        VStack(spacing: 12) {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 50))
                                .foregroundColor(iconGray)
                            Text("등록된 사진이 없습니다.")
                                .font(.subheadline)
                                .foregroundColor(iconGray)
                        }
                        .frame(maxWidth: .infinity, minHeight: 220)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 3)
                    }
                    
                    VStack(alignment: .leading, spacing: 18) {
                        
                        // 주소
                        VStack(alignment: .leading, spacing: 4) {
                            Text("위치")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(deepOceanBlue)
                            
                            Text(record.address ?? "위치 정보 없음")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(iconGray)
                        }
                        
                        Divider()
                            .background(lightBlueGray)
                        
                        // 제목 영역
                        VStack(alignment: .leading, spacing: 6) {
                            Text("제목")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(iconGray)
                            
                            Text(record.title.isEmpty ? "제목 없음" : record.title)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(midnightText)
                        }
                        
                        Divider()
                            .background(lightBlueGray)
                        
                        // 메모 영역
                        VStack(alignment: .leading, spacing: 6) {
                            Text("기록된 메모")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(iconGray)
                            
                            Text(record.memo.isEmpty ? "추가된 메모가 없습니다." : record.memo)
                                .font(.system(size: 15))
                                .foregroundColor(midnightText)
                                .lineSpacing(5)
                        }
                    }
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
                    
                    // 지도 바로가기 버튼 액션 파이프라인 연동
                    Button(action: {
                        withAnimation(.spring(response: 0.55, dampingFraction: 0.78)) {
                            viewModel.region.center = CLLocationCoordinate2D(latitude: record.latitude, longitude: record.longitude)
                            viewModel.region.span = MKCoordinateSpan(latitudeDelta: 0.006, longitudeDelta: 0.006)
                        }
              
                        viewModel.selectedTab = 0
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "mappin.and.ellipse")
                                .font(.system(size: 16, weight: .bold))
                            Text("지도에서 위치 확인하기")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(deepOceanBlue)
                        .foregroundColor(.white)
                        .cornerRadius(27)
                        .shadow(color: deepOceanBlue.opacity(0.25), radius: 6, x: 0, y: 4)
                    }
                    .padding(.top, 6)
                    
                    Spacer()
                }
                .padding()
            }
        }
        .navigationBarTitle("추억 상세보기", displayMode: .inline)
    }
}
