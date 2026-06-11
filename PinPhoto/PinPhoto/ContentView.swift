import SwiftUI
import MapKit

struct ContentView: View {
    
    @StateObject private var locationManager = LocationManager()
    @ObservedObject var viewModel: PinPhotoViewModel
    @StateObject private var searchViewModel = SearchViewModel()

    @State private var isShowingEditSheet = false
    @State private var isInitialRegionSet = false
    
    @State private var trackingMode: MapUserTrackingMode = .none
    
    let deepOceanBlue = Color(red: 23/255, green: 111/255, blue: 247/255) 
    let midnightText = Color(red: 30/255, green: 42/255, blue: 58/255)
    let iconGray = Color(red: 140/255, green: 151/255, blue: 167/255)
    let lightBlueGray = Color(red: 245/255, green: 247/255, blue: 250/255)
    
    var body: some View {
        
        TabView(selection: $viewModel.selectedTab) {
            
            ZStack(alignment: .bottom) {
                
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
                
                // 상단 팝업 검색창
                VStack {
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
                    .padding()
                    .background(Color(.systemBackground).opacity(0.95))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    Spacer()
                }
                
                // 하단 버튼
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
    }
}
