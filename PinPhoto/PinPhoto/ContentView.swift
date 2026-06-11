import SwiftUI
import MapKit

struct ContentView: View {
    
    @StateObject private var locationManager = LocationManager()
    @ObservedObject var viewModel: PinPhotoViewModel
    @StateObject private var searchViewModel = SearchViewModel()
    
    @StateObject private var sidebarVM = SidebarViewModel()

    @State private var isShowingEditSheet = false
    @State private var isInitialRegionSet = false
    
    @State private var trackingMode: MapUserTrackingMode = .none
    
    let deepOceanBlue = Color(red: 23/255, green: 111/255, blue: 247/255)
    let midnightText = Color(red: 30/255, green: 42/255, blue: 58/255)
    let iconGray = Color(red: 140/255, green: 151/255, blue: 167/255)
    let lightBlueGray = Color(red: 245/255, green: 247/255, blue: 250/255)
    
    var body: some View {
        
        TabView(selection: $viewModel.selectedTab) {
            
            ZStack {
                
                // 지도 영역
                Map(
                    coordinateRegion: $viewModel.region,
                    showsUserLocation: true,
                    userTrackingMode: $trackingMode,
                    annotationItems: viewModel.records
                ) { record in
                    MapMarker(
                        coordinate: CLLocationCoordinate2D(
                            latitude: record.latitude,
                            longitude: record.longitude
                        ),
                        tint: .red
                    )
                }
                .onReceive(locationManager.$location) { newLocation in
                    if let coordinate = newLocation?.coordinate, !isInitialRegionSet {
                        withAnimation(.easeInOut) {
                            viewModel.region.center = coordinate
                        }
                        isInitialRegionSet = true
                    }
                }
                .edgesIgnoringSafeArea(.all)
                
                // 지도 중심 이동 핀
                Image(systemName: "mappin.and.ellipse")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundColor(deepOceanBlue)
                    .shadow(color: Color.black.opacity(0.25), radius: 4, x: 0, y: 3)
                    .offset(y: -14)
                
                // 상단 검색창 및 사이드바 토글 통합 바 영역
                VStack {
                    
                    HStack(spacing: 12) {
                        
                        // 왼쪽 사이드바 오픈 버튼
                        Button(action: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.82)) {
                                sidebarVM.isSidebarOpen = true
                            }
                        }) {
                            
                            Image(systemName: "line.horizontal.3")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(midnightText)
                                .frame(width: 44, height: 44)
                                .background(Color(.systemBackground).opacity(0.95))
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 3)
                        }
                        
                        // 장소 검색창
                        HStack {
                            
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            
                            TextField("추억을 기록할 장소를 검색하세요...", text: $searchViewModel.searchQuery, onCommit: {
                                trackingMode = .none
                                searchViewModel.performSearch(currentRegion: viewModel.region) { targetCoordinate in
                                    if let coordinate = targetCoordinate {
                                        DispatchQueue.main.async {
                                            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                                                viewModel.region.center = coordinate
                                                viewModel.region.span = MKCoordinateSpan(
                                                    latitudeDelta: 0.008,
                                                    longitudeDelta: 0.008
                                                )
                                            }
                                        }
                                    }
                                }
                            })
                            
                            .foregroundColor(.primary)
                            
                            if !searchViewModel.searchQuery.isEmpty {
                                Button(action: { searchViewModel.searchQuery = "" }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .frame(height: 44)
                        .background(Color(.systemBackground).opacity(0.95))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    Spacer()
                }
                
                // 하단 기록하기 버튼 영역
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
                
                // 왼쪽 사이드바 메뉴 뷰 연동
                SidebarMenuView(sidebarVM: sidebarVM, viewModel: viewModel)
                    .animation(.spring(response: 0.4, dampingFraction: 0.85))
            }
            .tabItem {
                Image(systemName: "map.fill")
                Text("지도")
            }
            .tag(0)
            
            RecordListView(viewModel: viewModel)
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("목록")
                }
                .tag(1)
        }
        
        .sheet(isPresented: $isShowingEditSheet) {
            RecordEditView(
                viewModel: viewModel,
                currentCoordinate: locationManager.location?.coordinate
            )
        }
    }
}
