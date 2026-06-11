import SwiftUI
import MapKit

struct ContentView: View {
    
    @StateObject private var locationManager = LocationManager()
    @ObservedObject var viewModel: PinPhotoViewModel
    @StateObject private var searchViewModel = SearchViewModel()

    @State private var isShowingEditSheet = false
    @State private var isInitialRegionSet = false
    @State private var trackingMode: MapUserTrackingMode = .follow
    
    let deepOceanBlue = Color(red: 26/255, green: 75/255, blue: 143/255)
    
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
                
                // 검색창
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
                    .background(Color(.systemBackground).opacity(0.9))
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
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("현재 위치에 기록하기")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(deepOceanBlue)
                    .cornerRadius(15)
                    .shadow(radius: 5)
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
        .sheet(isPresented: $isShowingEditSheet) {
            RecordEditView(
                viewModel: viewModel,
                currentCoordinate: locationManager.location?.coordinate
            )
        }
    }
}
