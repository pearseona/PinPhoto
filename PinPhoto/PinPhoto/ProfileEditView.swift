import SwiftUI
import PhotosUI

struct ProfileEditView: View {
    @ObservedObject var sidebarVM: SidebarViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var tempNickname: String = ""
    @State private var isShowingImagePicker = false
    
    let deepOceanBlue = Color(red: 23/255, green: 111/255, blue: 247/255)
    let midnightText = Color(red: 30/255, green: 42/255, blue: 58/255)
    
    var body: some View {
        NavigationView {
            VStack(spacing: 40) {
                
                // 프로필 이미지 편집 영역
                VStack(spacing: 20) {
                    Button(action: {
                        isShowingImagePicker = true // 탭하면 사진첩 호출
                    }) {
                        if let data = sidebarVM.profileImageData, let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                                .shadow(radius: 10)
                        } else {
                            Image(systemName: "person.crop.circle.badge.plus")
                                .resizable()
                                .frame(width: 120, height: 120)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Text("탭하여 프로필 사진 변경")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(deepOceanBlue)
                }
                .padding(.top, 40)
                
                // 닉네임 입력 영역
                VStack(alignment: .leading, spacing: 10) {
                    Text("닉네임 설정")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.secondary)
                    
                    TextField("닉네임을 입력하세요", text: $tempNickname)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(midnightText)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationBarTitle("프로필 설정", displayMode: .inline)
            .navigationBarItems(
                leading: Button("취소") { presentationMode.wrappedValue.dismiss() }
                    .foregroundColor(.secondary),
                trailing: Button("저장") {
                    if !tempNickname.isEmpty {
                        sidebarVM.nickname = tempNickname
                    }
                    presentationMode.wrappedValue.dismiss()
                }
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(deepOceanBlue)
            )
            .onAppear {
                tempNickname = sidebarVM.nickname
            }
           
            .sheet(isPresented: $isShowingImagePicker) {
                CompatibleImagePicker(selectedData: $sidebarVM.profileImageData)
            }
        }
    }
}

// PhotosUI의 PHPickerViewController를 SwiftUI와 연결하는 UIKit 브릿지 객체
struct CompatibleImagePicker: UIViewControllerRepresentable {
    @Binding var selectedData: Data?
    @Environment(\.presentationMode) var presentationMode
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: CompatibleImagePicker
        
        init(_ parent: CompatibleImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.presentationMode.wrappedValue.dismiss()
            
            guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else { return }
            
            provider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                if let uiImage = image as? UIImage {
                    DispatchQueue.main.async {
                        self?.parent.selectedData = uiImage.jpegData(compressionQuality: 0.8)
                    }
                }
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
}
