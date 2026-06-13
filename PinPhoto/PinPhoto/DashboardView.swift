import SwiftUI

struct DashboardView: View {
    @ObservedObject var viewModel: PinPhotoViewModel
    @Environment(\.presentationMode) var presentationMode
    
    let deepOceanBlue = Color(red: 23/255, green: 111/255, blue: 247/255)
    let midnightText = Color(red: 30/255, green: 42/255, blue: 58/255)
    
    // 이번 달에 쌓은 추억 개수 집계 연산 프로퍼티
    var currentMonthRecordCount: Int {
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: Date())
        let currentYear = calendar.component(.year, from: Date())
        
        return viewModel.records.filter { record in
            let recordMonth = calendar.component(.month, from: record.date)
            let recordYear = calendar.component(.year, from: record.date)
            return recordMonth == currentMonth && recordYear == currentYear
        }.count
    }
    
    // 가장 많이 방문한 카테고리 TOP 3 추출 로직
    var topCategories: [(key: MemoryCategory, value: Int)] {
        let grouped = Dictionary(grouping: viewModel.records) { $0.category }
        let sorted = grouped.mapValues { $0.count }.sorted { $0.value > $1.value }
        return Array(sorted.prefix(3))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 22) {
                    
                    // 카드 1: 이번 달 요약 리포트
                    VStack(alignment: .leading, spacing: 12) {
                        Text("📅 이달의 발자국 리포트")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Text("이번 달에 쌓은 추억")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(midnightText)
                            Spacer()
                            Text("\(currentMonthRecordCount) 개")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(deepOceanBlue)
                        }
                    }
                    .padding(20)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    
                    // 카드 2: 카테고리 선호도 TOP 3
                    VStack(alignment: .leading, spacing: 16) {
                        Text("🏆 내가 가장 많이 찾은 테마 TOP 3")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.secondary)
                        
                        if viewModel.records.isEmpty {
                            Text("아직 기록된 추억이 없습니다.")
                                .font(.system(size: 15))
                                .foregroundColor(.gray)
                                .padding(.vertical, 10)
                        } else {
                            VStack(spacing: 12) {
                                ForEach(0..<topCategories.count, id: \.self) { index in
                                    let item = topCategories[index]
                                    HStack {
                                        Image(systemName: item.key.iconName)
                                            .foregroundColor(deepOceanBlue)
                                            .frame(width: 24)
                                        
                                        Text("\(index + 1)위  \(item.key.rawValue)")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(midnightText)
                                        
                                        Spacer()
                                        
                                        Text("\(item.value)회 방문")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.secondary)
                                    }
                                    if index != topCategories.count - 1 { Divider() }
                                }
                            }
                        }
                    }
                    .padding(20)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                }
                .padding()
            }
            .navigationBarTitle("추억 통계 대시보드", displayMode: .inline)
            .navigationBarItems(trailing: Button("닫기") {
                presentationMode.wrappedValue.dismiss()
            }.foregroundColor(deepOceanBlue).font(.system(size: 16, weight: .bold)))
        }
    }
}
