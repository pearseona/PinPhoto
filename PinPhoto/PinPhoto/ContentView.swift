import SwiftUI
import MapKit

struct ContentView: View {
    
    @StateObject private var locationManager = LocationManager()
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780), // 초기값 서울
        span: MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)
    )
    
    @State private var isShowingEditSheet = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // 전체 화면을 차지하는 지도
            Map(coordinateRegion: $region, showsUserLocation: true)
                .onReceive(locationManager.$location) { newLocation in
                    if let coordinate = newLocation?.coordinate {
                        withAnimation {
                            region.center = coordinate
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
                .background(Color.blue)
                .cornerRadius(15)
                .shadow(radius: 5)
            }
            .padding(.bottom, 30)
        }
        //  하단 시트 모달 연동
        .sheet(isPresented: $isShowingEditSheet) {
            RecordEditView() //  올라올 화면 연결
        }
    }
}
