import SwiftUI
import CoreLocation

struct RecordEditView: View {
    
    @ObservedObject var viewModel: PinPhotoViewModel
    
    let currentCoordinate: CLLocationCoordinate2D?
    
    // 하단 창 닫기
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var isImagePickerPresented = false
    @State private var selectedImageData: Data? = nil
    @State private var memoText: String = ""
    @State private var titleText: String = ""
    
    let deepOceanBlue = Color(red: 23/255, green: 111/255, blue: 247/255)
    let midnightText = Color(red: 30/255, green: 42/255, blue: 58/255)
    let iconGray = Color(red: 140/255, green: 151/255, blue: 167/255)
    let lightBlueGray = Color(red: 245/255, green: 247/255, blue: 250/255)
    
    var body: some View {
            NavigationView {

                ZStack(alignment: .top) {
                    lightBlueGray
                        .edgesIgnoringSafeArea(.all)
                    
                    ScrollView {
                        VStack(spacing: 24) {
                            
                            // 사진 영역
                            if let selectedImageData = selectedImageData, let uiImage = UIImage(data: selectedImageData) {
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
                                    .background(Color.white)
                                    .foregroundColor(deepOceanBlue)
                                    .cornerRadius(12)
                                    .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 3)
                                }
                            }
                            
                            // 제목 입력 영역
                            VStack(alignment: .leading, spacing: 6) {
                                Text("제목")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(midnightText)
                                
                                TextField("추억의 제목을 입력하세요", text: $titleText)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
                            }
                            
                            // 메모 입력 영역
                            VStack(alignment: .leading, spacing: 8) {
                                Text("메모")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(midnightText)
                                
                                TextEditor(text: $memoText)
                                    .frame(minHeight: 120, maxHeight: 180)
                                    .padding(8)
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
                            }
                            
                            Spacer(minLength: 40)
                        }
                        .padding()
                    }
                }
                .navigationBarTitle("추억 기록하기", displayMode: .inline)
                .navigationBarItems(
                    leading: Button("취소") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.secondary),
                    
                    trailing: Button("저장") {
                        
                        // 지도 중심 좌표 추출 및 저장
                        let targetLatitude = viewModel.region.center.latitude
                        let targetLongitude = viewModel.region.center.longitude
                        
                        viewModel.addRecord(
                            title: titleText.isEmpty ? "제목 없음" : titleText,
                            latitude: targetLatitude,
                            longitude: targetLongitude,
                            memo: memoText,
                            imageData: selectedImageData,
                            category: .daily
                        )
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(deepOceanBlue)
                    .font(.system(size: 17, weight: .bold))
                    .disabled(memoText.isEmpty || selectedImageData == nil)
                )
            }
            
            .onAppear {
                UITextView.appearance().backgroundColor = .clear
            }
            
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(selectedImageData: $selectedImageData)
            }
        }
    }
