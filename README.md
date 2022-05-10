# DependencyInjectionEx
의존성 주입 실습 예제 프로젝트

## 개념
> “의존성 주입"이란,

한 객체가 다른 인스턴스들을 받아 그것에 의존하게 되는 소프트웨어 디자인 패턴이다.  
흔히 코드를 재사용하는 것을 허용하거나, 목(mock) 데이터를 삽입하거나, 간단한 테스트를 하는데 사용되는 기술이다.  
네트워크 공급자를 dependency로써 뷰를 초기화하는 것을 예로 들 수 있다.  
```
이 프로젝트에서는 DICaller 안의 fetchRandomNames() 메서드를 통해 API 통신을 하여 랜덤한 이름 리스트를 받아온다.
버튼을 눌렀을 때, KeenViewController가 present되며 위의 메서드를 실행 데이터를 받아와 테이블뷰에 주입해준다.
```
스위프트에서 의존성을 주입하는데에는 여러 방법이 있지만, 각자 장단점이 있다.

## 의존성 주입의 장점
- 모듈간의 결합도를 낮춘다.
- 유지보수가 용이하다.
- 테스트에 용이하다.

## 왜 서드파티 라이브러리를 사용하지 않고 구현을 해보면 좋은가?
- 외부 라이브러리를 사용함으로써 빠르고 쉽게 의존성 주입을 해볼 수 있다.  
- 하지만 꼭 외부 라이브러리를 쓰지 않아도 충분하고 강력한 기능을 구현할 수 있다.  
- 스위프트 표준 라이브러리의 기능들과 가깝게 지내므로써, 외부 라이브러리를 접하는 러닝커브가 낮아질 것이고, 다음 릴리즈가 언제 나올지에 의존하지 않아도 된다!  
- 항상 라이브러리를 찾고 거기에 의존하는 것은 더 이상 라이브러리가 유지되지 않을 경우에 대한 위험을 감수해야한다.  
- 반면, 나만의 해결방법을 작성해봄으로써 내가 아직 친숙하지 않은 개념들을 필요로 할 수 있다.

## 필요한 이유는?
- 테스트를 위한 데이터를 mocking 하기 쉬워진다.
- 가독성은 Swift 표준 API들과 가깝게 지내며 유지되어야 한다.
- 컴파일 시점에 숨겨진 crash들을 방지하는 것을 선호한다.
(앱을 빌드할 때, 모든 의존성이 올바르게 설정되었음을 알 수 있음)
- 의존성을 주입한 결과로써의 거대한 initializer들은 피할 것
- 잠재적 러닝커브를 방지하기 위해 서드파티에 의존을 하지 않는다.
- 강제언래핑은 필요없다.
- 패키지 내부에서 `private, interal` 타입들을 노출 시키지 않고 표준 의존성을 정의하는 것이 가능하다.
- 재사용성을 위해 라이브러리들을 가로지르며 공유가 가능하도록 패키지 안에 정의되어야 한다.

```
 보통 의존성 주입을 하면
 한쪽은 view와 연관되어 있을 것이고, 나머지 한쪽은 data와 연관되어 있을 것이다.
```
 
## 프로젝트 구성
- 랜덤한 10개의 이름이 담긴 json 데이터를 넘겨주는 [API](http://names.drycodes.com/10)를 사용하였다.
- `DIKit`, `KEENUIKit` 이라는 타겟(framework)이 2개 있다.
  - `DIKit` 에는 API로부터 데이터를 fetching 해오는 메서드가 들어있는 `DICaller.swift` 가 있다.
  - `KEENUIKit` 에는 `dataFetchable`을 만족하는 데이터를 초기값으로 갖는 테이블뷰를 보여주는 `KeenViewController.swift` 가 있다.

 
## 프로젝트 설명
- `DIKit`은 랜덤이름 API로 부터 데이터를 fetching 해오는 함수를 가지고 있다.
```swift
// KEENUIKit
// KeenViewController.swift

func configure() {
  view.backgroundColor = .systemBackground
  dataFetchable.fetchRandomNames { [weak self] names in // here!
    self?.names = names.map { User(name: $0) }
    
    DispatchQueue.main.async {
      self?.tableView.reloadData()
    }
  }
}
```

- `DIKit`의 initializer는 `DataFetchable` 이라는 의존성을 가지고 있다.
```swift
// DIKit
// DICaller.swift

public class KeenViewController: UIViewController {
  
  let dataFetchable: DataFetchable

  public init(dataFetchable: DataFetchable) { // here!
    self.dataFetchable = dataFetchable
    super.init(nibName: nil, bundle: nil)
  }
  
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    configure()
  }

}
```

</br>

- `DataFetchable` 이라는 프로토콜은 `fetchRandomNames` 라는 함수를 구현하도록 되어있다.
```swift
// KEENUIKit
// KeenViewController.swift

public protocol DataFetchable {
  func fetchRandomNames(completion: @escaping ([String]) -> Void)
}
```
 
 </br>
 
- 메인 타켓의 `ViewController`에서 `DIKit, KEENUIKit` 에 접근할 수 있다.
```swift
// DependencyInjectionEx
// ViewController.swift

import UIKit
import DIKit // here!
import KEENUIKit // here!

class ViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
  }

  @IBAction func buttonClicked(_ sender: UIButton) {
    // some button action code ...
  }
}

```

</br>

- `ViewController`에서 버튼을 누르면 `KeenViewController`를 부르게 되고 인자로 `DataFetchable`을 가져올 수 있다.
```swift
// DependencyInjectionEx
// ViewController.swift

  @IBAction func buttonClicked(_ sender: UIButton) {
    let vc = KeenViewController(dataFetchable: DICaller.shared) // here!
    self.present(vc, animated: true)
  }
```

</br>

- `DICaller.shared as? DataFetchable` 처럼 캐스팅 해주는 대신 `DICaller`에 `DataFetchable`을 extension 함으로써 타입을 맞춰줄 수 있다. (optional 이 아니게 되므로 강제 언래핑을 하지 않아도 됨)
```swift
// DependencyInjectionEx
// ViewController.swift

extension DICaller: DataFetchable { }
```
 
</br>
 
### 결과
- `DIKit`과 `KEENUIKit` 사이에는 의존성이 존재하지 않는 상황에서  
  `KEENKit`의 `KeenViewController`의 인자로 `DIKit`의 `DICaller.shared`를 주입해주었음.

```
전체 코드는 프로젝트를 참고 하자!
```
