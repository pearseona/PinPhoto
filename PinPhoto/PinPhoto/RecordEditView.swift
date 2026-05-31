import SwiftUI

struct RecordEditView: View {
    
    // 색상 : 딥 오션 블루
    let deepOceanBlue = Color(red: 26/255, green: 75/255, blue: 143/255)
    
    let lightBlueGray = Color(red: 240/255, green: 244/255, blue: 248/255)
    
    // 하단 창 닫기
    @Environment(\.presentationMode) private var presentationMode
    
    // 사진첩 시트 팝업창 제어
    @State private var isImagePickerPresented = false
    
    // 로드된 이미지의 실제 바이너리 데이터를 저장
    @State private var selectedImageData: Data? = nil
    
    // 한 줄 메모 입력
    @State private var memoText: String = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                
                /* --- 사진 영역 --- */
                
                // 선택된 사진 데이터가 있으면 미리보기를 보여주고, 없으면 버튼을 노출
                if let selectedImageData = selectedImageData, let uiImage = UIImage(data: selectedImageData) {
                    
                    // 로드된 데이터를 이미지 뷰로 화면에 표출
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, maxHeight: 250)
                        .cornerRadius(12)
                        .clipped()
                    
                    // 다시 고르고 싶을 때를 위한 초기화 버튼
                    Button("사진 다시 고르기") {
                        self.selectedImageData = nil
                    }
                    .foregroundColor(.red)
                } else {
                    
                    // 버튼을 누르면 사진첩을 열도록 스위치(isImagePickerPresented)를 true로 변경
                    Button(action: {
                        isImagePickerPresented = true
                    }){
                        VStack(spacing: 10) {
                            Image(systemName: "photo.badge.plus")
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
                
                /* --- 메모 입력 폼 영역 --- */
                VStack(alignment: .leading, spacing: 8) {
                    Text("메모")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    TextField("이 장소의 추억을 기록하세요", text: $memoText)
                        .padding()
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
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(deepOceanBlue)
                .font(.system(size: 17, weight: .bold))
                
                // 사진을 고르고 메모에 최소 한 글자 이상 써야 저장 버튼 활성화
                .disabled(memoText.isEmpty || selectedImageData == nil)
            )
        }
            
            // 사진첩 시트 모달 연결
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(selectedImageData: $selectedImageData)
            }
        }
    }


struct RecordEditView_Previews: PreviewProvider {
    static var previews: some View {
        RecordEditView()
    }
}
