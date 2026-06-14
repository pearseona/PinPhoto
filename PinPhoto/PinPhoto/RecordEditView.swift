import SwiftUI
import CoreLocation
import MapKit

struct RecordEditView: View {
    
    @ObservedObject var viewModel: PinPhotoViewModel
    
    let currentCoordinate: CLLocationCoordinate2D?
    let record: VisitRecord?
    
    // 하단 창 닫기
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var isImagePickerPresented = false
    @State private var selectedImageData: Data? = nil
    @State private var memoText: String = ""
    @State private var titleText: String = ""
    @State private var selectedCategory: MemoryCategory = .daily
    @State private var isEditMode: Bool = false
    
    @State private var miniMapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.5824, longitude: 127.0103),
        span: MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)
    )
    
    let deepOceanBlue = Color(red: 23/255, green: 111/255, blue: 247/255)
    let midnightText = Color(red: 30/255, green: 42/255, blue: 58/255)
    let iconGray = Color(red: 140/255, green: 151/255, blue: 167/255)
    let lightBlueGray = Color(red: 245/255, green: 247/255, blue: 250/255)
    
    var body: some View {
     
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
                        
                        if isEditMode {
                            Button("사진 다시 고르기") {
                                self.selectedImageData = nil
                            }
                            .foregroundColor(.red)
                        }
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
                        .disabled(!isEditMode)
                    }
                    
                    // 카테고리 선택 영역
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 10) {
                            ForEach(MemoryCategory.allCases, id: \.self) { category in
                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        self.selectedCategory = category
                                    }
                                }) {
                                    Text(category.rawValue)
                                        .font(.system(size: 14, weight: .bold))
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                        .background(selectedCategory == category ? deepOceanBlue : Color.white)
                                        .foregroundColor(selectedCategory == category ? .white : midnightText)
                                        .cornerRadius(20)
                                        .shadow(color: selectedCategory == category ? deepOceanBlue.opacity(0.2) : Color.black.opacity(0.02), radius: 4, x: 0, y: 2)
                                }
                                .disabled(!isEditMode)
                            }
                        }
                    }
                    
                    // 제목 입력 영역
                    VStack(alignment: .leading, spacing: 6) {
                        Text("제목")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(midnightText)
                        
                        TextField("", text: $titleText)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
                            .disabled(!isEditMode)
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
                            .disabled(!isEditMode)
                    }
                    
                    // 위치 정보 및 미니맵 영역
                    VStack(alignment: .leading, spacing: 10) {
                        Text("위치")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(midnightText)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            // 한글 주소 텍스트 행
                            HStack(spacing: 6) {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundColor(deepOceanBlue)
                                    .font(.system(size: 16))
                                Text(record?.address ?? "📍 위치 정보 분명")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(midnightText)
                            }
                            .padding(.horizontal, 4)
                            
                            // 미니맵 레이어
                            Map(coordinateRegion: $miniMapRegion, annotationItems: record != nil ? [record!] : []) { item in
                                MapMarker(
                                    coordinate: CLLocationCoordinate2D(latitude: item.latitude, longitude: item.longitude),
                                    tint: .red
                                )
                            }
                            .frame(height: 140)
                            .cornerRadius(10)
                            .disabled(true)
                        }
                        .padding(12)
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // 지도에서 위치 확인하기 버튼
                    if !isEditMode, let existingRecord = record {
                        Button(action: {
                            viewModel.moveMapTo(record: existingRecord)
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "mappin.and.ellipse")
                                    .font(.system(size: 16, weight: .bold))
                                Text("지도에서 위치 확인하기")
                                    .font(.system(size: 16, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(deepOceanBlue)
                            .cornerRadius(12)
                            .shadow(color: deepOceanBlue.opacity(0.25), radius: 6, x: 0, y: 3)
                        }
                        .padding(.top, 8)
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding()
            }
        }
      
        .navigationBarTitle(record == nil ? "추억 기록하기" : (isEditMode ? "추억 수정하기" : "추억 상세보기"), displayMode: .inline)
        .navigationBarItems(
            leading: Button(isEditMode && record != nil ? "취소" : "닫기") {
                if isEditMode && record != nil {
                    withAnimation {
                        isEditMode = false
                    }
                } else {
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .foregroundColor(.secondary),
            
            trailing: Group {
                if record == nil {
                    Button("저장") {
                        saveAction()
                    }
                    .foregroundColor(deepOceanBlue)
                    .font(.system(size: 17, weight: .bold))
                    .disabled(memoText.isEmpty || selectedImageData == nil)
                } else {
                    if isEditMode {
                        Button("저장") {
                            saveAction()
                        }
                        .foregroundColor(deepOceanBlue)
                        .font(.system(size: 17, weight: .bold))
                        .disabled(memoText.isEmpty || selectedImageData == nil)
                    } else {
                        Button("수정") {
                            withAnimation { isEditMode = true }
                        }
                        .foregroundColor(deepOceanBlue)
                        .font(.system(size: 17, weight: .bold))
                    }
                }
            }
        )
        .onAppear {
            UITextView.appearance().backgroundColor = .clear
            
            if let existingRecord = record {
                titleText = existingRecord.title
                memoText = existingRecord.memo
                selectedImageData = existingRecord.imageData
                selectedCategory = existingRecord.category
                
                miniMapRegion = MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: existingRecord.latitude, longitude: existingRecord.longitude),
                    span: MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)
                )
                isEditMode = false
            } else {
                isEditMode = true
            }
        }
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(selectedImageData: $selectedImageData)
        }
    }

    private func saveAction() {
        let targetLatitude = currentCoordinate?.latitude ?? viewModel.region.center.latitude
        let targetLongitude = currentCoordinate?.longitude ?? viewModel.region.center.longitude
        
        if let existingRecord = record {
            if let originalIndex = viewModel.records.firstIndex(where: { $0.id == existingRecord.id }) {
                viewModel.deleteRecord(at: originalIndex)
            }
        }
        
        viewModel.addRecord(
            title: titleText.isEmpty ? "제목 없음" : titleText,
            latitude: targetLatitude,
            longitude: targetLongitude,
            memo: memoText,
            imageData: selectedImageData,
            category: selectedCategory
        )
        presentationMode.wrappedValue.dismiss()
    }
}
