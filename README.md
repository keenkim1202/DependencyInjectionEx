# DependencyInjectionEx
의존성 주입 실습 예제 프로젝트

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

- `DICaller.shared as? DataFetchable` 처럼 캐스팅 해주는 대신 `DICaller`에 `DataFetchable`을 extension 함으로써 타입을 맞춰줄 수 있다. (optional 이 아니게 됨)
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
