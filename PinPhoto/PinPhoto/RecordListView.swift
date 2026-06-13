import SwiftUI

struct RecordListView: View {
    @ObservedObject var viewModel: PinPhotoViewModel
    
    @State private var selectedFilterCategory: MemoryCategory? = nil
    
    let deepOceanBlue = Color(red: 23/255, green: 111/255, blue: 247/255)
    let midnightText = Color(red: 30/255, green: 42/255, blue: 58/255)
    
    // 데이터 스트림 필터링 연산
    var filteredRecords: [VisitRecord] {
        if let category = selectedFilterCategory {
            return viewModel.records.filter { $0.category == category }
        }
        return viewModel.records
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                
                // 상단 스크롤 카테고리 필터 바 영역
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        // '전체' 버튼
                        Button(action: { selectedFilterCategory = nil }) {
                            Text("전체")
                                .font(.system(size: 14, weight: .bold))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(selectedFilterCategory == nil ? deepOceanBlue : Color(.secondarySystemBackground))
                                .foregroundColor(selectedFilterCategory == nil ? .white : midnightText)
                                .cornerRadius(20)
                        }
                        
                        ForEach(MemoryCategory.allCases, id: \.self) { category in
                            Button(action: { selectedFilterCategory = category }) {
                                HStack(spacing: 6) {
                                    Image(systemName: category.iconName)
                                    Text(category.rawValue)
                                }
                                .font(.system(size: 14, weight: .bold))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(selectedFilterCategory == category ? deepOceanBlue : Color(.secondarySystemBackground))
                                .foregroundColor(selectedFilterCategory == category ? .white : midnightText)
                                .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                }
                .background(Color(.systemBackground))
                
                Divider()
                
                // 실시간 필터링된 추억 목록 출력 영역
                if filteredRecords.isEmpty {
                    Spacer()
                    Text("해당 카테고리에 등록된 추억이 없습니다.")
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                    Spacer()
                } else {
                    List {
                        ForEach(filteredRecords) { record in
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
                                        .fill(Color(.secondarySystemBackground))
                                        .frame(width: 60, height: 60)
                                        .cornerRadius(8)
                                        .overlay(Image(systemName: "photo").foregroundColor(.gray))
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text(record.title)
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(midnightText)
                                        Spacer()
                                        
                                        // 카테고리 태그 배지
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
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationBarTitle("내 추억 목록", displayMode: .inline)
        }
    }
}
