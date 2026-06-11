import SwiftUI
import CoreLocation

struct RecordEditView: View {
    
    let deepOceanBlue = Color(red: 23/255, green: 111/255, blue: 247/255)
    let lightBlueGray = Color(red: 245/255, green: 247/255, blue: 250/255)
    
    @ObservedObject var viewModel: PinPhotoViewModel
    
    let currentCoordinate: CLLocationCoordinate2D?
    
    // 하단 창 닫기
    @Environment(\.presentationMode) private var presentationMode
    
    // 사진첩 시트 팝업창 제어
    @State private var isImagePickerPresented = false
    
    // 로드된 이미지의 실제 바이너리 데이터를 저장
    @State private var selectedImageData: Data? = nil
    
    // 한 줄 메모 입력
    @State private var memoText: String = ""
    
    // 제목 입력
    @State private var titleText: String = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                
                // 사진 영역
                
                if let selectedImageData = selectedImageData, let uiImage = UIImage(data: selectedImageData) {
                    
                    // 로드된 데이터를 이미지 뷰로 화면에 표출
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, maxHeight: 250)
                        .cornerRadius(12)
                        .clipped()
                    
                    // 사진 다시 고르고 싶을 때
                    Button("사진 다시 고르기") {
                        self.selectedImageData = nil
                    }
                    .foregroundColor(.red)
                } else {
                    
             
                    Button(action: {
                        isImagePickerPresented = true
                    }){
                        VStack(spacing: 10) {
                            Image(systemName: "plus.rectangle.on.folder")
                                .font(.largeTitle)
                            Text("사진 추가하기")
                                .font(.callout)
                        }
                        .frame(maxWidth: .infinity, minHeight: 180)
                        .background(lightBlueGray)
                        .foregroundColor(deepOceanBlue)
                        .cornerRadius(12)
                    }
                }
                
                // 제목 입력 폼 영역
                VStack(alignment: .leading, spacing: 6) {
                    Text("제목")
                        .font(.headline)
                        .foregroundColor(Color(red: 30/255, green: 42/255, blue: 58/255))
                    
                    TextField("추억의 제목을 입력하세요", text: $titleText)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }
                
                // 메모 입력 폼 영역
                VStack(alignment: .leading, spacing: 8) {
                    Text("메모")
                        .font(.headline)
                        .foregroundColor(Color(red: 30/255, green: 42/255, blue: 58/255))
                    
                    TextEditor(text: $memoText)
                        .frame(minHeight: 120, maxHeight: 180)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }
                
                Spacer()
            }
            .padding()
            
            // 내비게이션 바 중앙 타이틀
            .navigationBarTitle("추억 기록하기", displayMode: .inline)
            
            .navigationBarItems(
                leading: Button("취소") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.secondary),
                
                trailing: Button("저장") {
                    
                    let targetLatitude = viewModel.region.center.latitude
                    let targetLongitude = viewModel.region.center.longitude
                    
                    viewModel.addRecord(
                        title: titleText.isEmpty ? "제목 없음" : titleText,
                        latitude: targetLatitude,
                        longitude: targetLongitude,
                        memo: memoText,
                        imageData: selectedImageData
                    )
                    
                    // 저장 후 입력 폼 닫기
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(deepOceanBlue)
                .font(.system(size: 17, weight: .bold))
                
                .disabled(titleText.isEmpty || memoText.isEmpty || selectedImageData == nil)
            )
        }
        
        .onAppear {
            UITextView.appearance().backgroundColor = .clear
        }
            
            // 사진첩 시트 모달 연결
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(selectedImageData: $selectedImageData)
            }
        }
    }


struct RecordEditView_Previews: PreviewProvider {
    static var previews: some View {
        RecordEditView(viewModel: PinPhotoViewModel(), currentCoordinate: nil)
    }
}
