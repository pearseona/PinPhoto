import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    @State private var opacity = 0.5
    @State private var size: CGFloat = 0.8
    
    let deepOceanBlue = Color(red: 23/255, green: 111/255, blue: 247/255)
    let midnightText = Color(red: 30/255, green: 42/255, blue: 58/255)
    let lightBlueGray = Color(red: 245/255, green: 247/255, blue: 250/255)
    
    var body: some View {
        if isActive {
            // 3초 뒤 스플래시가 끝나면 실제 메인 화면으로 전환
            ContentView(viewModel: PinPhotoViewModel())
        } else {
            ZStack {
               
                LinearGradient(
                    gradient: Gradient(colors: [midnightText, midnightText.opacity(0.85)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                .edgesIgnoringSafeArea(.all)
                
                // 로고 및 서비스 타이틀 영역
                VStack(spacing: 20) {
                    VStack(spacing: 12) {
                    
                        ZStack {
                            Circle()
                                .fill(lightBlueGray.opacity(0.12))
                                .frame(width: 110, height: 110)
                            
                            Image(systemName: "map.circle.fill")
                                .font(.system(size: 85))
                                .foregroundColor(lightBlueGray)
                            
                            Image(systemName: "mappin.and.ellipse")
                                .font(.system(size: 34, weight: .bold))
                                .foregroundColor(deepOceanBlue)
                                .offset(y: -4)
                                .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 3)
                        }
                        
                        // 앱 이름
                        Text("PinPhoto")
                            .font(.system(size: 36, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .tracking(1.5)
                    }
                    .scaleEffect(size)
                    .opacity(opacity)
                    .onAppear {
                     
                        withAnimation(.easeIn(duration: 1.0)) {
                            self.size = 1.0
                            self.opacity = 1.0
                        }
                    }
                    
                
                    Text("지도 위에 새기는 나만의 추억 발자국")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(lightBlueGray.opacity(0.65))
                        .padding(.top, 4)
                }
            }
            .onAppear {
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
    }
}
