import SwiftUI

@main
struct PinPhotoApp: App {
    
    @StateObject private var viewModel = PinPhotoViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
        }
    }
}
