import SwiftUI

@main
struct PinPhotoApp: App {
    
    @StateObject private var viewModel = PinPhotoViewModel()
    @State private var showSplash = true
    
    var body: some Scene {
        WindowGroup {
            
            if showSplash {
                
                SplashView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            withAnimation { showSplash = false }
                        }
                    }
            } else {
                ContentView(viewModel: viewModel)
            }
        }
    }
}

