# PinPhoto (일상의 기록을 지도로 남기다)

'PinPhoto'는 사용자의 소중한 일상과 여행의 기억을 위치 데이터와 함께 체계적으로 기록하고 관리하는 지도 기반 메모 앱입니다.

## 🎥 시연 영상
[[PinPhoto 시연 영상](https://www.youtube.com/watch?v=jDVJ7gjTEgM)]

## 🚀 주요 기능
### 📍Map & Location Intelligence
- 실시간 위치 추적: CoreLocation 기반의 정밀한 실시간 GPS 트래킹 및 사용자 위치 자동 줌인 최적화
- 인터랙티브 마커: 사진 기반의 커스텀 어노테이션 핀 렌더링 및 MKAnnotationView 재사용 최적화
- 지능형 검색 파이프라인: MKLocalSearch 연동을 통한 장소 검색, 지도 중심 좌표와의 실시간 동기화 및 애니메이션 이동 구현

### 📊 Statistical Dashboard
- 개인화 추억 리포트: 사용자 방문 데이터 분석을 통한 카테고리별 선호도 시각화
- 안정적인 랭킹 로직: 방문 횟수가 동일한 카테고리 발생 시, 시스템적 안정성을 위해 가나다순(사전순) 정렬 알고리즘 적용
- 데이터 가공: 통계 대시보드 내 실시간 데이터 가공 및 직관적인 UI 인터페이스 제공

### 📝 Record Management System
- 데이터 영속성 레이어: 로컬 데이터베이스를 통한 메모, 사진, 좌표 정보의 영구 저장 및 앱 재실행 시 복원
- 스마트 검색 엔진: 제목 및 메모 본문 내 키워드 기반 실시간 필터링(Case-insensitive search)
- CRUD 효율화: 리스트 스와이프 액션을 통한 레코드 삭제 및 수정 워크플로우 최적화

### 👤 Profile & User Experience
- 개인화 설정: 프로필 이미지 및 이름 수정 기능을 통한 사용자 맞춤형 인터페이스 제공
- 반응형 UX: 모션이 포함된 사이드바 오픈 및 카테고리 필터 칩(Chip) 컴포넌트 적용으로 사용자 인터랙션 강화


## 🏗️시스템 구조 (MVVM)
PinPhoto는 MVVM(Model-View-ViewModel) 패턴을 채택하여 UI와 비즈니스 로직을 명확히 분리하고 유지보수성을 극대화했습니다.
- **View**: SwiftUI 기반의 선언형 UI 컴포넌트 (`ContentView`, `RecordListView` 등)
- **ViewModel**: 데이터 가공 및 상태 관리 (`PinPhotoViewModel`, `SidebarViewModel`)
- **Model**: 데이터 구조체 및 로컬 영속성 로직 (`VisitRecord`)
  
## 🛠 기술 스택
- **Language:** Swift 5
- **UI:** SwiftUI
- **Framework:** MapKit, CoreLocation
- **Architecture:** MVVM

## 📈 브랜치 전략 (Git Flow)
본 프로젝트는 효율적인 협업과 코드 안정성을 위해 다음과 같은 브랜치 전략을 사용했습니다.
- `main`: 제품 배포용 (최종 배포 버전)
- `develop`: 개발 통합 브랜치 (기능 구현 및 통합)
- `feature/*`: 기능별 개발 브랜치 (기능 단위로 세분화)
    - `feature/1-map` ~ `feature/7-record-crud-ops`까지 단계별 구현
    - 각 기능 브랜치는 독립적인 단위 테스트를 거친 후 `develop`에 병합

## 💡 구현 로직의 핵심
- **UIKit 연동:** `UIViewRepresentable`과 `Coordinator` 패턴을 사용하여 SwiftUI 환경 내에서 `MKMapView`의 커스텀 핀 렌더링 및 델리게이트 로직을 구현했습니다.
- **데이터 동기화:** 지도 드래그 시 발생하는 좌표 불일치 버그를 `regionDidChange` 델리게이트를 통해 뷰모델과 실시간으로 동기화하여 해결했습니다.
- **정렬 알고리즘:** 데이터 분석 시 방문 횟수가 같은 경우, 카테고리 이름의 가나다순으로 정렬하는 안정적인 정렬 로직을 적용했습니다.

## 향후 고도화 계획
- 데이터 저장소: 현재의 로컬 저장 방식을 넘어 `SwiftData` 또는 `CoreData`로의 마이그레이션을 통해 대용량 데이터 처리 성능을 강화할 예정입니다.
- 아키텍처 확장: 점진적으로 `Coordinator` 패턴을 강화하여 뷰 간의 네비게이션 흐름을 더욱 독립적으로 제어할 계획입니다.
- 성능 최적화: `Combine`을 적극 활용하여 비동기 데이터 스트림 처리를 최적화하고 UI 반응 속도를 높일 예정입니다.
