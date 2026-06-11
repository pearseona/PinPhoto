import SwiftUI

struct RecordListView: View {
    
    @ObservedObject var viewModel: PinPhotoViewModel
    
    @State private var searchText = ""
    
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
            VStack(spacing: 0) {
                
                // 검색창 UI
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("제목, 메모 키워드로 추억을 검색하세요...", text: $searchText)
                        .foregroundColor(.primary)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 12)
                
                // 리스트 렌더링
                if filteredRecords.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        
                        Image(systemName: searchText.isEmpty ? "mappin.slash.circle" : "doc.text.magnifyingglass")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        
                        Text(searchText.isEmpty ? "아직 기록된 추억이 없습니다." : "'\(searchText)'가 포함된 추억이 없습니다.")
                            .foregroundColor(.secondary)
                            .font(.headline)
                        
                        Text(searchText.isEmpty ? "지도에서 현재 위치에 추억을 남겨보세요!" : "다른 키워드로 다시 검색해 보세요.")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                } else {
                    // 최신순으로 정렬된 리스트 렌더링
                    List(filteredRecords, id: \.id) { record in
                        
                        NavigationLink(destination: RecordDetailView(record: record)) {
                            RecordRowView(record: record)
                        }
                }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("내 추억 목록")
        }
    }
}
                

