import SwiftUI
import MapKit

struct ContentView: View {
    
    @StateObject private var locationManager = LocationManager()
    @ObservedObject var viewModel: PinPhotoViewModel
    @StateObject private var searchViewModel = SearchViewModel()
    @StateObject private var sidebarVM = SidebarViewModel()

    @State private var isShowingEditSheet = false
    @State private var searchedCoordinate: CLLocationCoordinate2D? = nil
    
    @State private var centerCoordinate = CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780)

    let deepOceanBlue = Color(red: 23/255, green: 111/255, blue: 247/255)
    let midnightText = Color(red: 30/255, green: 42/255, blue: 58/255)
    let iconGray = Color(red: 140/255, green: 151/255, blue: 167/255)
    let lightBlueGray = Color(red: 245/255, green: 247/255, blue: 250/255)
    
    var body: some View {
        
        ZStack {
            
            TabView(selection: $viewModel.selectedTab) {
                
                // 지도 화면
                ZStack {
                    
                    // 바닥 지도 레이어
                    CustomMapView(
                        viewModel: viewModel,
                        searchedCoordinate: $searchedCoordinate,
                        centerCoordinate: $centerCoordinate
                    )
                    .edgesIgnoringSafeArea(.all)
                    
                    // 지도 중심축 조준 핀
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundColor(deepOceanBlue)
                        .shadow(color: midnightText.opacity(0.25), radius: 4, x: 0, y: 3)
                        .offset(y: -14)
                    
                    // 상단 검색창 바 레이어
                    VStack(spacing: 0) {
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
                                    .background(lightBlueGray.opacity(0.95))
                                    .cornerRadius(12)
                                    .shadow(color: midnightText.opacity(0.1), radius: 6, x: 0, y: 3)
                            }
                            
                            // 장소 검색창 바
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(iconGray)
                                
                                TextField("추억을 기록할 장소를 검색하세요...", text: $searchViewModel.searchQuery, onCommit: {
                                   
                                    searchViewModel.performSearch(currentRegion: viewModel.region) { targetCoordinate in
                                        if let coordinate = targetCoordinate {
                                            DispatchQueue.main.async {
                                                withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                                                    
                                                    self.searchedCoordinate = coordinate
                                                    self.centerCoordinate = coordinate
                                                }
                                            }
                                        }
                                    }
                                })
                                .foregroundColor(midnightText)
                                
                                if !searchViewModel.searchQuery.isEmpty {
                                    Button(action: { searchViewModel.searchQuery = "" }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(iconGray)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .frame(height: 44)
                            .background(lightBlueGray.opacity(0.95))
                            .cornerRadius(12)
                            .shadow(color: midnightText.opacity(0.1), radius: 8, x: 0, y: 4)
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                        
                        // 현재 위치로 이동 버튼
                        HStack {
                            Spacer()
                            Button(action: {
                                if let userLocation = locationManager.location?.coordinate {
                                    withAnimation(.spring(response: 0.45, dampingFraction: 0.7)) {
                                        
                                        self.searchedCoordinate = userLocation
                                        self.centerCoordinate = userLocation
                                    }
                                }
                            }) {
                                Image(systemName: "location.fill")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 38, height: 38)
                                    .background(deepOceanBlue)
                                    .cornerRadius(10)
                                    .shadow(color: deepOceanBlue.opacity(0.25), radius: 4, x: 0, y: 2)
                            }
                            .padding(.trailing, 16)
                            .padding(.top, 8)
                        }
                        Spacer()
                    }
                    
                    // 하단 플로팅 기록하기 버튼 영역
                    VStack {
                        Spacer()
                        
                        Button(action: {
                            isShowingEditSheet = true
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 18, weight: .bold))
                                Text("현재 지도 위치에 기록하기")
                                    .font(.system(size: 16, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 28)
                            .padding(.vertical, 16)
                            .background(deepOceanBlue)
                            .cornerRadius(28)
                            .shadow(color: deepOceanBlue.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .padding(.bottom, 30)
                    }
                }
                .tabItem {
                    Image(systemName: "map.fill")
                    Text("지도")
                }
                .tag(0)
                
                // 추억 목록 화면
                RecordListView(viewModel: viewModel, sidebarVM: sidebarVM)
                    .tabItem {
                        Image(systemName: "list.bullet")
                        Text("목록")
                    }
                    .tag(1)
            }
            

            if sidebarVM.isSidebarOpen {
                SidebarMenuView(sidebarVM: sidebarVM, viewModel: viewModel)
                    .zIndex(1)
                    .transition(.move(edge: .leading))
            }
        }
        .sheet(isPresented: $isShowingEditSheet) {
            NavigationView {
                RecordEditView(
                    viewModel: viewModel,
                    currentCoordinate: centerCoordinate,
                    record: nil
                )
            }
 
        }
    }
}
