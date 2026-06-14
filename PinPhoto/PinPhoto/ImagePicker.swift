import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    
    @Binding var selectedImageData: Data?
    @Environment(\.presentationMode) private var presentationMode
    
    // UIViewController 설정 및 초기화
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        
    }
    
    func makeCoordinator() ->Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent =  parent
        }
        
        // 사진 선택 완료 시 호출
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                if let data = uiImage.jpegData(compressionQuality: 0.8) {
                    parent.selectedImageData = data
                }
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        // 취소 시 화면 닫기
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
