
# 브루어리 소개 앱 만들기

## 구현

### 1) 구현 기능

- URLSession
- SnapKit
- Kingfisher
- pagination 

### 2) 기본 개념

#### (1) OSI Model

OSI 7 계층
> Open Systems Interconnection
<img src="https://www.imperva.com/learn/wp-content/uploads/sites/13/2020/02/OSI-7-layers.jpg.webp">

1. 1레벨: Physical 물리 계층
    - 전압 레벨, 데이터 속도, 최대 전송 거리, 커넥터..
    - 케이블, 모뎀, 리피터
    - bits
2. 2레벨: Data Link 데이터 링크 계층
    - 데이터 오류 감지, 복구
    - MAC 주소: 이더넷 NIC 고유 번호
    - frames
3. 3레벨: Network 네트워크 계층
    - 논리 주소 정의
    - IP 주소
    - packets
4. 4레벨: Transport 전송 계층
    - 데이터 흐름 제어
    - TCP, UDP
    - Segments
5. 5레벨: Session 전송 계층 
    - 통신 장치 간의 상호작용 설정, 유지, 관리
6. 6레벨: Presentation 표현 계층
    - 7레벨에 적용되는 데이터 형식, 코딩, 변환 기능
    - 파일 확장자
7. 7레벨: Application 응용계층
    - 앱 상의 네트워크
    - *HTTP*

#### (2) URL Session

An object that coordinates a group of related, network data transfer tasks.
The *URLSession* class and related classes provide an API for downloading data from and uploading data to endpoints indicated by URLs. Your app can also use this API to perform background downloads when your app isn't running or, in iOS, while your app is suspended. 

URL
> Uniform Resource Locator
    - protocol: http, ftp, mailto
    - DNS => IP (layer3)
    - port (layer4)
    - resource path (layer7)

HTTP

1. Request
    - Method: Get, Post, Put, Patch, Delete, Head, Connect, Options, Trace
    - URL
    - Header
    - Body
2. Response
    - Status Code: 100..200..30..400..500..
    - Message
    - Header
    - Body

##### Get vs Post

Get: retrieve, parameter가 URL에 노출됨, 메세지 양적인 한계 (200bytes)
Post: create, parameter를 body에 넣음, 재현 불가능

ios Framework: *URLSession*
네트워크 구축 위해 사용하는 프레임 워크
HTTP, OSI7 프로토콜 구현 
네트워크 인증, 세션, 쿠키 관리
네트워크 전송과 관련된 Task 그룹 조정 

URL Loading System 
URL 과 표준 인터넷 프로토콜 (HTTP...) 통해 리소스 접근
*비동기*

```swift
URLSession.shared
```

- URLSession 객체
- cache, cookie 사용
- Cellular network 연결 허용 여부
- singleton (shared) : 세션에 대한 복잡한 요구가 없을 경우 shared 사용하여 객체 사용

##### URLSessionConfiguration

```ruby
.default : shared + a (데이터를 점진적으로 가져오도록 delegate 설정 등)
.ephemeral : 임시, cache/cookie/자격증명을 Disk에 쓰지 않는다
.background(withIdentifier): App 이 실행되지 않는 동안에도 데이터 업로드/다운로드
```

##### URLSessionTask

> 세션 내에서 데이터를 서버에 업로드한 후 서버로 부터 데이터를 검색하는 작업을 만든다

- URLSessionDataTask: NSData 객체 사용해 데이터 송수신 (작은 단위의 단발성 데이터)
- URLSessionUploadTask: 파일 전송, 백그라운드 업로드 지원 
- URLSessionDownloadTask: 파일 형식 기반 검색, 백그라운드 다운로드 지원
- URLSessionStreamTask
- URLSessionWebSocketTask

##### URLSession Life Cycle

1. URLSession 생성: 속성 정의, URLrequest 객체 정의 (url, method...)
2. URLSessionDataTask: *resume* sends data, request, error parameters 
3. CompletionHandler: data 처리

##### 사용하기

1. URL 설정
2. Request 생성 (HTTP method 지정)
3. dataTask 생성
4. dataTask *resume*

#### (3) Punk API

#### (4) GCD

(참고자료)
https://medium.com/nbt-tech/dispatchqueue%EB%8A%94-%EC%96%B4%EB%96%BB%EA%B2%8C-%EC%82%AC%EC%9A%A9%ED%95%A0%EA%B9%8C-44f22f08d62

https://80000coding.oopy.io/4690385f-97d9-4add-9e94-004c47c82820

https://developer.apple.com/documentation/dispatch/dispatchqueue

### 3) 새롭게 배운 것

- SceneDelegate
```swift
func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = scene as? UIWindowScene else { return }
        self.window = UIWindow(windowScene: windowScene)
        let rootViewController = BeerListViewController()
        let rootNavigationController = UINavigationController(rootViewController: rootViewController)
        self.window?.rootViewController = rootNavigationController
        self.window?.makeKeyAndVisible()
    }
```
위의 주석을 참고, storyboard 사용할 경우 class의 property인 window에 자동으로 초기화 되지만 
코드로만 UI를 작성하기 위해 storyboard에 의존하지 않을 경우, 내가 작성한 viewController가 rootview가 되도록 작업한다.

> iOS 13 이전, window based
모든 view 의 최상위 hirearchy 에는 window (UIWindow instance which extends UIView)
단 하나의 window가 존재한다.
window는 rootViewController parmeter를 가지고 이 View가 window의 유일한 subView
Lifetime Delegate message: application *didFinishLaunchingWithOptions*
    > tells the delegate that the launch process is almost done and the app is almost teady to run

> iOS 13 +, scene based
iPad에서 여러개의 window가 하나의 앱에서 존재 할 수 있다.
window scene (UIWindowScene)
Lifetime Delegate message: scene *willConnectTo* options
    > tells the delegate about the addition of a scene to the app

(참고자료) <https://woookdev.github.io/programming/Window-based-VS-Scene-Based-(iOS-13-%EC%9D%B4%ED%9B%84-%EB%B0%94%EB%80%90-%EA%B8%B0%EB%B3%B8-%EA%B5%AC%EC%A1%B0%EC%97%90-%EB%8C%80%ED%95%9C-%EC%A0%95%EB%A6%AC)/>

> The core methods you use to respond to life-cycle events occuring within a scene
<https://developer.apple.com/documentation/uikit/uiscenedelegate>

- CodingKey
server에서 받을 key 값과 struct의 property 이름이 일치하지 않을 때 사용

```swift
enum CodingKeys: String, CodingKey {
        case id, name, description
        case taglineString = "tagline"
        case imageURL = "image_url"
        case brewersTips = "brewers_tips"
        case foodParing = "food_paring"
    }
```

- String Method
  - 문자열 replace: replacingOccurrences
  - 문자열 쪼개기 : split vs components(separatedBy:)
    - <https://velog.io/@minni/Swift-split-VS-components>
  - 문자열 합치기 : joined(separator:)

- @override layout Subview
the default implementation uses any constraints you have set to determine the size and position of any subviews.
you should override this method only if the autoresizing and constraint-based befiviors of the subviews do not offer the behavior you want.
현재 프로젝트에서는, custom cell에 subview를 추가하기 위해 사용하고 있다.

- UITableViewCell > contentView (Instance Property)
the content view of a UITableViewCell object is the default superview for content that the cell displays.
If you want to customize cells by simplay adding additional views, you should add them to the content view 
so they position appropriately as the cell trasitions in to and out of editing mode.

- snapkit offset vs inset
  - view constraint = superview constraint + offset
  - inset == UIEdgeInsets

- #imageLiteral(resourceName:)

- configure Cell: UITableViewCell의 Instance property
  - accessoryType
    - The type of standard accessory view the cell should use 
    - The accessory view appears in the right side of the cell in the table view's normal state
    - .none, .disclosureIndicator, .detailDisclosureButton, .checkmark, .detailButton
  - selectionStyle

- TableViewController Instance property
  - tableview
  - title

- UITableView
  - init(frame:style:)
  - frame: a rectangle specifying the initial location and size of the table view in its superview's coordinates.
  - style: a constant that specifies the style of the table view. 
    - .plain, .grouped, .insetGrouped

- CGRect
  - A structure that contains the location and dimensions of a rectangle
  - Core Graphics
    - height
    - width
    - minX midX maxX minY midY maxY

- 지금 작업이 MainThread 에서 이루어지고 있는지 궁금할 때

```swift
po Thread.isMainthread
```

- UITableViewDataSourcePrefetching

```swift
po Thread.isMainthread
 tableView.prefetchDataSource = self
 extension BeerListViewController: UITableViewDataSourcePrefetching {
      func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        [IndexPath].forEach {
            print("Prefetch row \($0.row)")
            // 사용자가 스크롤 하면서 앞으로 보게 될 row를 미리 불러오는 것을 확인할 수 있다.
        }
    }
 }
```

- pagination
  - 페이지 추가의 시점 알기
  - 데이터 중복 막기

```swift
func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        guard self.currentPage != 1 else { return }  // 첫 번째 페이지 fetch는 viewDidLoad에서 이루어진다.
        
        indexPaths.forEach {
            if ($0.row + 1)/25 + 1 == self.currentPage {  // row가 끝에 도달한 시점
                self.fetchBeer(of: self.currentPage)
            }
        }
    }

func fetchBeer(of page: Int) {
        guard let url = URL(string: "https://api.punkapi.com/v2/beers?page=\(page)"),
              self.dataTasks.firstIndex(where: {$0.originalRequest?.url == url}) == nil else { return }
              // Array.firstIndex(of:) 조건을 만족하는 첫 번째 아이템의 인덱스 반환 없을 경우 nil
              // urlSessionTask.originalRequest : passed when the task was created
              // URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
       //...
            switch response.statusCode {
            case (200...299):
                self.beerList += beerList
        ...
        dataTask.resume()
        self.dataTasks.append(dataTask)
    
```

- URLRequest
  - httpMethod
  - url
  - httpBody...

URLRequest encapsulates tow essential properties of a load request: the URL to load and the policies used to load it. In addition, for HTTP and HTTPS requests, URLRequest includes the HTTP mthod and the HTTP headers.

URL Request only represents information about the request. Use other classes, such as URLSession, to send the request to a server.

