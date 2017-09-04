# 앱 사용시 확인필요사항
- 상세화면에서 컬렉션뷰영역을 long press했을때 원본이미지를 확인할 수 있습니다.
- 카메라 찍기 버튼을 누르고 있을때 연속촬영이 됩니다.

# 환경

- `cocoapods` 설치

# 실행


```bash
$ pod install
$ open gallery.xcworkspace
```

# 테스팅

`Cmd + U`

# 주요 서드파티 라이브러리 및 프레임웍

- CoreStore : CoreData 
- RxSwift, RxCocoa : 이벤트 바인딩
- SnapKit : AutoLayout 
- SDWebImage : 이미지 디스크 캐시용도
- FSImageViewer : 이미지 뷰어
- MBProgressHUD : 로딩 인디케이터
- UITextView+Placeholder : UI

# TODO 및 개선사항.

- 각종 성능이슈 개선 및 리펙토링이 필요합니다.
- MVVM 적용을 `Story`모델에만 적용됨.
- CameraView & CaptureSessionManager : 필터적용, 카메라 캡쳐 퀄리티 조정, 캡쳐 퍼포먼스 및 예외사항 처리 보완필요
- UIs : 전체적으로 많은 개선이 필요. 프로토 타입수준으로 만들어짐
- `Storage.swift` File 과 DB 책임 분리 및 리펙토링 필요.
- SDWebImage를 굳이 디스크 캐시로 사용하지 않아도 됨.
