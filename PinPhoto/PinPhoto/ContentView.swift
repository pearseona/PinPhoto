import SwiftUI
import MapKit

struct ContentView: View {
    
    @StateObject private var locationManager = LocationManager()
    @StateObject var viewModel = PinPhotoViewModel()
    @StateObject private var searchViewModel = SearchViewModel()

    // 지도 초기 중심 위치 설정
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.5824, longitude: 127.0103),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    
    // 하단 시트 팝업창 제어 변수
    @State private var isShowingEditSheet = false
    
    @State private var isInitialRegionSet = false
    
    @State private var trackingMode: MapUserTrackingMode = .follow
    
    let deepOceanBlue = Color(red: 26/255, green: 75/255, blue: 143/255)
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            // 전체 화면 지도 영역
            Map(
                coordinateRegion: $region,
                showsUserLocation: true,
                userTrackingMode: $trackingMode,
                annotationItems: viewModel.records
            ) { record in
                MapMarker(
                    coordinate: CLLocationCoordinate2D(latitude: record.latitude, longitude: record.longitude),
                    tint: .red
                )
            }
                .onReceive(locationManager.$location) { newLocation in
                    if let coordinate = newLocation?.coordinate, !isInitialRegionSet {
                            withAnimation(.easeInOut) {
                                region.center = coordinate
                            }
                            isInitialRegionSet = true
                            print(" [GPS 동기화] 유저의 현재 위치로 지도를 성공적으로 매칭했습니다: \(coordinate.latitude), \(coordinate.longitude)")
                        }
                }
   
                .edgesIgnoringSafeArea(.all)
            
            // 상단 검색창 UI 레이어
            VStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("추억을 기록할 장소를 검색하세요...", text: $searchViewModel.searchQuery, onCommit: {
                        
                        trackingMode = .none
                        
                        searchViewModel.performSearch(currentRegion: region) { targetCoordinate in
                            if let coordinate = targetCoordinate {
                                
                                DispatchQueue.main.async{
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                                        region.center = coordinate
                                        region.span = MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
                                    }
                                    print(" [UI 매핑] 검색 결과 위치로 지도 중심점을 이동했습니다")
                                }

                            }
                        }
                    })
                    .foregroundColor(.primary)
                    
                    if !searchViewModel.searchQuery.isEmpty {
                        Button(action: {searchViewModel.searchQuery = "" }) {
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
        
            // 하단 플로팅 버튼 영역
            Button(action: {
                isShowingEditSheet = true // 버튼 누르면 시트 오픈
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
        //  하단 시트 모달 연동
        .sheet(isPresented: $isShowingEditSheet) {
            RecordEditView(
                viewModel: viewModel,
                currentCoordinate: locationManager.location?.coordinate
        )
      }
   }
}

