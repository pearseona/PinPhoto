import Foundation
import Combine

class SidebarViewModel: ObservableObject {
    
    // 유저 프로필 상태 변수
    @Published var nickname: String = UserDefaults.standard.string(forKey: "User_Nickname") ?? "배선아" {
        didSet { UserDefaults.standard.set(nickname, forKey: "User_Nickname") }
    }
    
    @Published var profileImageData: Data? = UserDefaults.standard.data(forKey: "User_ProfileImage") {
        didSet { UserDefaults.standard.set(profileImageData, forKey: "User_ProfileImage") }
    }
    
    @Published var isSidebarOpen: Bool = false
    
    init() {
        print(" [SidebarViewModel] 독립적인 사용자 설정 및 사이드바 인프라 로드 완료")
    }
}
