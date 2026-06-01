import SwiftUI
import MapKit

struct ContentView: View {
    
    @StateObject private var locationManager = LocationManager()
    
    @StateObject var viewModel = PinPhotoViewModel()

    // 지도 초기 중심 위치 설정
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.5824, longitude: 127.0103),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    
    // 하단 시트 팝업창 제어 변수
    @State private var isShowingEditSheet = false
    
    @State private var isInitialRegionSet = false
    
    let deepOceanBlue = Color(red: 26/255, green: 75/255, blue: 143/255)
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            // 전체 화면을 차지하는 지도
            Map(
                coordinateRegion: $region,
                showsUserLocation: true,
                annotationItems: viewModel.records
            ) { record in
                MapMarker(
                    coordinate: CLLocationCoordinate2D(latitude: record.latitude, longitude: record.longitude),
                    tint: .red
                )
            }
                .onReceive(locationManager.$location) { newLocation in
                    if let coordinate = newLocation?.coordinate {
                        if !isInitialRegionSet {
                            withAnimation(.easeInOut) {
                                region.center = coordinate
                            }
                            isInitialRegionSet = true
                            print(" [GPS 동기화] 유저의 현재 위치로 지도를 성공적으로 매칭했습니다: \(coordinate.latitude), \(coordinate.longitude)")
                        }
                    }
                }
   
                .edgesIgnoringSafeArea(.all)
        
            // 지도 위의 플로팅 버튼
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

