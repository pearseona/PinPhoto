import SwiftUI

struct RecordListView: View {
    
    @ObservedObject var viewModel: PinPhotoViewModel
    
    @State private var searchText = ""
    
    let deepOceanBlue = Color(red: 23/255, green: 111/255, blue: 247/255)
    let midnightText = Color(red: 30/255, green: 42/255, blue: 58/255)
    let iconGray = Color(red: 140/255, green: 151/255, blue: 167/255)
    let lightBlueGray = Color(red: 245/255, green: 247/255, blue: 250/255)
    
    // 검색 필터링 파이프라인
    private var filteredRecords: [VisitRecord] {
        
        // 최신순 정렬
        let sorted = viewModel.records.sorted { $0.date > $1.date }
        
        // 검색어 비어 있을 때
        if searchText.isEmpty {
            return sorted
        } else {
            // 검색어 존재할 때
            return sorted.filter { record in
                record.title.localizedCaseInsensitiveContains(searchText) ||
                record.memo.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    
    var body: some View {
      
        NavigationView {
            
            ZStack {
                lightBlueGray
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    
                    // 검색창 UI
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(iconGray)
                        
                        TextField("제목, 메모 키워드로 추억을 검색하세요...", text: $searchText)
                            .foregroundColor(midnightText)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                        
                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(iconGray)
                            }
                        }
                    }
                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
                    .padding(.horizontal)
                    .padding(.top, 12)
                    .padding(.bottom, 16)
                    
                    // 리스트 렌더링 영역
                    if filteredRecords.isEmpty {
                        Spacer()
                        VStack(spacing: 12) {
                            Image(systemName: searchText.isEmpty ? "mappin.slash.circle" : "doc.text.magnifyingglass")
                                .font(.system(size: 50))
                                .foregroundColor(iconGray)
                            
                           
                            Text(searchText.isEmpty ? "아직 기록된 추억이 없습니다." : "'\(searchText)'가 포함된 추억이 없습니다.")
                                .foregroundColor(midnightText)
                                .font(.headline)
                            
                            Text(searchText.isEmpty ? "지도에서 현재 위치에 추억을 남겨보세요!" : "다른 키워드로 다시 검색해 보세요.")
                                .font(.caption)
                                .foregroundColor(iconGray)
                        }
                        Spacer()
                    } else {
                        
                        ScrollView {
                            LazyVStack(spacing: 14) {
                                ForEach(filteredRecords, id: \.id) { record in
                                    NavigationLink(destination: RecordDetailView(record: record, viewModel: viewModel)) {
                                        
                                        HStack(spacing: 16) {
                                            
                                            // 저장된 이미지 썸네일
                                            if let data = record.imageData, let uiImage = UIImage(data: data) {
                                                Image(uiImage: uiImage)
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 65, height: 65)
                                                    .cornerRadius(10)
                                                    .clipped()
                                            } else {
                                                ZStack {
                                                    Color(red: 235/255, green: 243/255, blue: 255/255)
                                                    Image(systemName: "photo")
                                                        .foregroundColor(deepOceanBlue)
                                                }
                                                .frame(width: 65, height: 65)
                                                .cornerRadius(10)
                                            }
                                            
                                            // 텍스트 영역 정보
                                            VStack(alignment: .leading, spacing: 5) {
                                                Text(record.title.isEmpty ? "제목 없음" : record.title)
                                                    .font(.system(size: 16, weight: .bold))
                                                    .foregroundColor(midnightText)
                                                    .lineLimit(1)
                                                
                                                // 역지오코딩된 주소 텍스트 매핑
                                                Text(record.address ?? "위치 정보 없음")
                                                    .font(.system(size: 13))
                                                    .foregroundColor(iconGray)
                                                    .lineLimit(1)
                                            }
                                            
                                            Spacer()
                                            
                                            Image(systemName: "chevron.right")
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundColor(deepOceanBlue)
                                        }
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(14)
                                        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                
                        }
                    }
                }
            }
            .navigationTitle("내 추억 목록")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}


                

