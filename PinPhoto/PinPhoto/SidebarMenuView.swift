import SwiftUI

struct SidebarMenuView: View {
    
    @ObservedObject var sidebarVM: SidebarViewModel
    @ObservedObject var viewModel: PinPhotoViewModel
    
    @State private var isShowingDashboard = false
    @State private var isShowingProfileEdit = false
    
    let deepOceanBlue = Color(red: 23/255, green: 111/255, blue: 247/255)
    let midnightText = Color(red: 30/255, green: 42/255, blue: 58/255)
    let iconGray = Color(red: 140/255, green: 151/255, blue: 167/255)
    let lightBlueGray = Color(red: 245/255, green: 247/255, blue: 250/255)
    
    var body: some View {
        
        ZStack(alignment: .leading) {
         
            Color.black.opacity(0.3)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                        sidebarVM.isSidebarOpen = false // 빈 곳 누르면 닫히기
                    }
                }
            
            // 왼쪽 사이드바 메뉴
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 28) {
                    
                    // 프로필 영역
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(spacing: 16) {
                            if let data = sidebarVM.profileImageData, let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 62, height: 62)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .frame(width: 62, height: 62)
                                    .foregroundColor(iconGray)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(sidebarVM.nickname)
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(midnightText)
                                                                            
                                Button(action: { isShowingProfileEdit = true }) {
                                    Text("프로필 설정 변경")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(deepOceanBlue)
                                }
                            }
                        }
                        .padding(.top, 24)
                        
                        Divider()
                    }
                    
                    // 메뉴 리스트 영역
                    VStack(alignment: .leading, spacing: 10) {
                        Text("추억 탐색")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.secondary)
                            .padding(.bottom, 4)
                        
                        // 통계 대시보드
                        SidebarRow(icon: "chart.bar.xaxis", title: "추억 통계 대시보드", midnightText: midnightText, lightBlueGray: lightBlueGray, iconGray: iconGray) {
                            isShowingDashboard = true
                        }
                        
                        // 타임라인 동선 지도
                        SidebarRow(icon: "map.fill", title: "타임라인 동선 지도", midnightText: midnightText, lightBlueGray: lightBlueGray, iconGray: iconGray) {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                                viewModel.selectedTab = 0
                                sidebarVM.isSidebarOpen = false
                            }
                        }
                                                
                        // 카테고리 필터링 설정
                        SidebarRow(icon: "slider.horizontal.3", title: "카테고리 필터링 설정", midnightText: midnightText, lightBlueGray: lightBlueGray, iconGray: iconGray) {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                                viewModel.selectedTab = 1
                                sidebarVM.isSidebarOpen = false
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding(24)
                .frame(width: UIScreen.main.bounds.width * 0.72)
                .background(Color(.systemBackground))
                .edgesIgnoringSafeArea(.vertical)
                
                Spacer()
            }
        }

        .sheet(isPresented: $isShowingProfileEdit) {
            ProfileEditView(sidebarVM: sidebarVM)
        }
        .sheet(isPresented: $isShowingDashboard) {
            DashboardView(viewModel: viewModel)
        }
    }
}


struct SidebarRow: View {
    let icon: String
    let title: String
    let midnightText: Color
    let lightBlueGray: Color
    let iconGray: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 17, weight: .medium))
                    .frame(width: 24)
                    .foregroundColor(iconGray)
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(midnightText)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(iconGray.opacity(0.5))
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 12)
            .background(lightBlueGray)
            .cornerRadius(10)
        }
    }
}
