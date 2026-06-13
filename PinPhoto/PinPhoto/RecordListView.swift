import SwiftUI

struct RecordListView: View {
    
    @ObservedObject var viewModel: PinPhotoViewModel
    @ObservedObject var sidebarVM: SidebarViewModel

    @State private var searchText: String = ""
    @State private var selectedFilterCategory: MemoryCategory? = nil
    
    let deepOceanBlue = Color(red: 23/255, green: 111/255, blue: 247/255)
    let midnightText = Color(red: 30/255, green: 42/255, blue: 58/255)
    let iconGray = Color(red: 140/255, green: 151/255, blue: 167/255)
    let lightBlueGray = Color(red: 245/255, green: 247/255, blue: 250/255)
    let softSoftBlue = Color(red: 238/255, green: 247/255, blue: 255/255)
    
    var filteredRecords: [VisitRecord] {
        var records = viewModel.records
        
        // 카테고리 필터링
        if let category = selectedFilterCategory {
            records = records.filter { $0.category == category }
        }
        
        // 검색어 키워드 매칭
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !query.isEmpty {
            records = records.filter { record in
                record.title.localizedCaseInsensitiveContains(query) ||
                record.memo.localizedCaseInsensitiveContains(query)
            }
        }
        
        return records
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                
                // 상단 검색창 및 사이드바
                HStack(spacing: 12) {
                    
                    // 왼쪽 사이드바 오픈 버튼
                    Button(action: {
                        withAnimation(.spring(response: 0.38, dampingFraction: 0.8)) {
                            sidebarVM.isSidebarOpen = true
                        }
                    }) {
                        Image(systemName: "line.horizontal.3")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(midnightText)
                            .frame(width: 44, height: 44)
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: midnightText.opacity(0.1), radius: 6, x: 0, y: 3)
                    }
                    
                    // 키워드 검색 바 텍스트 필드
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(iconGray)
                        
                        TextField("기록의 제목이나 내용을 검색하세요...", text: $searchText)
                            .foregroundColor(midnightText)
                            .font(.system(size: 14))
                        
                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(iconGray)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .frame(height: 44)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: midnightText.opacity(0.1), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal)
                .padding(.top, 12)
                .padding(.bottom, 12)
                .background(Color(.systemBackground))
                
                // 카테고리 칩 바 영역
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        Button(action: { selectedFilterCategory = nil }) {
                            Text("전체")
                                .font(.system(size: 14, weight: .bold))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(selectedFilterCategory == nil ? deepOceanBlue : Color.white)
                                .foregroundColor(selectedFilterCategory == nil ? .white : midnightText)
                                .cornerRadius(20)
                                .shadow(color: selectedFilterCategory == nil ? deepOceanBlue.opacity(0.15) : Color.black.opacity(0.01), radius: 3, x: 0, y: 1)
                        }
                        
                        ForEach(MemoryCategory.allCases, id: \.self) { category in
                            Button(action: { selectedFilterCategory = category }) {
                                Text(category.rawValue)
                                    .font(.system(size: 14, weight: .bold))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(selectedFilterCategory == category ? deepOceanBlue : Color.white)
                                    .foregroundColor(selectedFilterCategory == category ? .white : midnightText)
                                    .cornerRadius(20)
                                    .shadow(color: selectedFilterCategory == category ? deepOceanBlue.opacity(0.15) : Color.black.opacity(0.02), radius: 3, x: 0, y: 1)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 14)
                }
                .background(softSoftBlue)
                .cornerRadius(16, corners: [.bottomLeft, .bottomRight]) // 모서리 라운딩
                .shadow(color: Color.black.opacity(0.04), radius: 5, x: 0, y: 3)

                // 필터링 및 검색 결과 리스트 레이어
                if filteredRecords.isEmpty {
                    Spacer()
                    Text(searchText.isEmpty ? "해당 카테고리에 등록된 추억이 없습니다." : "검색 결과와 일치하는 추억이 없습니다.")
                        .font(.system(size: 15))
                        .foregroundColor(iconGray)
                    Spacer()
                } else {
                    List {
                        ForEach(filteredRecords) { record in
                            NavigationLink(destination: RecordEditView(
                                viewModel: viewModel,
                                currentCoordinate: .init(latitude: record.latitude, longitude: record.longitude),
                                record: record
                            )) {
                                HStack(spacing: 16) {
                                    if let data = record.imageData, let uiImage = UIImage(data: data) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 60, height: 60)
                                            .cornerRadius(8)
                                            .clipped()
                                    } else {
                                        Rectangle()
                                            .fill(lightBlueGray)
                                            .frame(width: 60, height: 60)
                                            .cornerRadius(8)
                                            .overlay(Image(systemName: "photo").foregroundColor(iconGray))
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            Text(record.title)
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundColor(midnightText)
                                            Spacer()
                                            Text(record.category.rawValue)
                                                .font(.system(size: 11, weight: .semibold))
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 3)
                                                .background(deepOceanBlue.opacity(0.1))
                                                .foregroundColor(deepOceanBlue)
                                                .cornerRadius(6)
                                        }
                                        
                                        Text(record.memo)
                                            .font(.system(size: 14))
                                            .foregroundColor(.secondary)
                                            .lineLimit(1)
                                        
                                        if let address = record.address {
                                            Text(address)
                                                .font(.system(size: 12))
                                                .foregroundColor(iconGray)
                                        }
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .onDelete(perform: deleteRecord)
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    private func deleteRecord(at offsets: IndexSet) {
        for index in offsets {
            let recordToDelete = filteredRecords[index]
            if let originalIndex = viewModel.records.firstIndex(where: { $0.id == recordToDelete.id }) {
                viewModel.deleteRecord(at: originalIndex)
                print(" [CRUD] 레코드 삭제 성공: \(recordToDelete.title)")
            }
        }
    }
}

// 특정 모서리 절삭 사양 확장 정의
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
