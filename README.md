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

## 의존성 주입의 장점
- 모듈간의 결합도를 낮춘다.
  - 객체 간 의존성(종속성)을 줄이거나 없앨 수 있다.
  - 확장과 재사용성이 좋다.
  - 모듈별 독립적인 재사용이 가능하다.
- 유지보수가 용이하다.
  - 어떤 객체가 어디에서 영향을 받고, 주고 있는지 파악하기 쉽다.
- 테스트에 용이하다.
- 가독성이 좋아진다.
  - 

## 의존성?
- A가 B에 의존성이 걸려있다면, B가 변화가 되었을 때 A에 영향을 미친다.
```swift
class A {
  var awesome: String = "머쩅이"
}

class B {
  var bwesome = A() // B는 A에 의존하고 있다.
}

let b = B()
b.bwesome.awesome
```

## 주입?
- 내부가 아닌, 외부에서 객체를 생성해서 넣어주는 것
```swift
class C {
  var someVar: String
 
  init (someVar: String) {
    self.someVar = someVar
  }
}

let c = C(someVar: "나는 머쩅이") // 외부로부터 "나는 머쩅이" 라는 문자열을 C의 someVar 프로퍼티에 주입
```

## 왜 서드파티 라이브러리를 사용하지 않고 구현을 해보면 좋은가?
- 외부 라이브러리를 사용함으로써 빠르고 쉽게 의존성 주입을 해볼 수 있다.  
- 하지만 꼭 외부 라이브러리를 쓰지 않아도 충분하고 강력한 기능을 구현할 수 있다.  
- 스위프트 표준 라이브러리의 기능들과 가깝게 지내므로써, 외부 라이브러리를 접하는 러닝커브가 낮아지고, 다음 릴리즈가 언제 나올지에 의존하지 않아도 된다!  
- 항상 라이브러리를 찾고 거기에 의존하는 것은 더 이상 라이브러리가 유지되지 않을 경우에 대한 위험을 감수해야한다.  
- 반면, 나만의 해결방법을 작성해봄으로써 내가 아직 친숙하지 않은 개념들을 필요로 할 수 있다.

## 필요한 이유는?
의존성을 가지는 코드가 많아진다면,  
재활용성이 떨어지고 의존성을 가지는 객체들은 매번 함께 수정해 주어야 하는 문제점이 발생한다.

- 테스트를 위한 데이터를 mocking 하기 쉬워진다.
- 가독성은 Swift standard API들에 친숙하게 유지하는 것이 좋다.
- 컴파일 시점에 숨겨진 crash들을 방지할 수 있다.
(앱을 빌드할 때, 모든 의존성이 올바르게 설정되었음을 알 수 있음)
- 의존성을 주입한 결과로써의 거대한 initializer들은 피할 수 있다.
- 잠재적 러닝커브를 방지하기 위해 서드파티에 의존을 하지 않는다.
- 강제언래핑은 필요없다.
- 패키지 내부에서 `private, interal` 타입들을 노출 시키지 않고 의존성을 정의하는 것이 가능하다.
- 재사용성을 위해 라이브러리들을 넘나들며 공유가 가능하도록 패키지 안에 정의되어야 한다. (public 키워드 활용)

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
- DI는 필요한 것을 주입해주면서 Protocol을 통해 소스코드의 의존성을 감소시킬 수 있다.
 - Protocol을 사용하여 의존성을 주입을 하게되면, IoC(Inversion of Control) 즉, 제어 역전이 발생한다.
 - 이 IoC를 통해 의존성을 분리하고, 분리된 의존성을 주입(DI) 해주는 방식으로 구현한다.

> `IoC` 란?  
> `코드 호출 방향`과 `소스코드 의존성`에서 소스코드 의존성의 방향을 역전시켜  
> 하위 모듈에 대한 상위모듈의 의존성을 역전시킨 것이다.  
> (나중에 더 자세히 다뤄보자.)
```
상위 모듈(=비즈니스 로직)이 하위 모듈(=구현체)을 import 해야 하는 의존 방향에서 반대로 역전되는 상황이 생기는데, 
코드 호출 방향이 달라지는 것은 아니고, 여전히 상위 모듈 -> 하위모듈을 호출한다.
```
</br>

### 참고링크
- [DI Container, IOC Container 개념과 예제](https://eunjin3786.tistory.com/233)
- [3가지 의존성 주입 방법](https://eunjin3786.tistory.com/115)
- [Dependency Inversion Principle in Swift](https://medium.com/movile-tech/dependency-inversion-principle-in-swift-18ef482284f5)
- [Swift 5.1 Takes Dependency Injection to the Next Level](https://betterprogramming.pub/taking-swift-dependency-injection-to-the-next-level-b71114c6a9c6)
