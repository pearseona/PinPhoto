import SwiftUI

struct RecordListView: View {
    @ObservedObject var viewModel: PinPhotoViewModel
    
    @State private var selectedFilterCategory: MemoryCategory? = nil
    
    let deepOceanBlue = Color(red: 23/255, green: 111/255, blue: 247/255)
    let midnightText = Color(red: 30/255, green: 42/255, blue: 58/255)
    let iconGray = Color(red: 140/255, green: 151/255, blue: 167/255)
    let lightBlueGray = Color(red: 245/255, green: 247/255, blue: 250/255)
    
    // 동적 필터링 파이프라인 연산 프로퍼티
    var filteredRecords: [VisitRecord] {
        if let category = selectedFilterCategory {
            return viewModel.records.filter { $0.category == category }
        }
        return viewModel.records
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                
                // 상단 카테고리 칩 바
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        Button(action: { selectedFilterCategory = nil }) {
                            Text("전체")
                                .font(.system(size: 14, weight: .bold))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(selectedFilterCategory == nil ? deepOceanBlue : lightBlueGray)
                                .foregroundColor(selectedFilterCategory == nil ? .white : midnightText)
                                .cornerRadius(20)
                        }
                        
                      
                        ForEach(MemoryCategory.allCases, id: \.self) { category in
                            Button(action: { selectedFilterCategory = category }) {
                              
                                Text(category.rawValue)
                                    .font(.system(size: 14, weight: .bold))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(selectedFilterCategory == category ? deepOceanBlue : lightBlueGray)
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
                
                // 필터링된 리스트 레이어
                if filteredRecords.isEmpty {
                    Spacer()
                    Text("해당 카테고리에 등록된 추억이 없습니다.")
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
                        .onDelete(perform: deleteRecord) // 왼쪽으로 밀면 삭제
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationBarTitle("내 추억 목록", displayMode: .inline)
        }
    }
    
    // 필터링된 배열의 인덱스를 원본 배열의 ID와 매칭하여 삭제
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
