import SwiftUI

struct RecordListView: View {
    
    @ObservedObject var viewModel: PinPhotoViewModel
    
    private var sortedRecords: [VisitRecord] {
        // 최신순 정렬 (date 기준 내림차순)
        return viewModel.records.sorted { $0.date > $1.date }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if sortedRecords.isEmpty {
                    Spacer()
                    // 데이터가 하나도 없을 때의 예외 UI
                    VStack(spacing: 12) {
                        Image(systemName: "mappin.slash.circle")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("아직 기록된 추억이 없습니다.")
                            .foregroundColor(.secondary)
                        Text("지도에서 현재 위치에 추억을 남겨보세요!")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                } else {
                    // 최신순으로 정렬된 리스트 렌더링
                    List(sortedRecords, id: \.id) { record in
                        RecordRowView(record: record)
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("내 추억 목록")
        }
    }
}
