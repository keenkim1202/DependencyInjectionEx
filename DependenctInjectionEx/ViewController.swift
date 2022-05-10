//
//  ViewController.swift
//  DependenctInjectionEx
//
//  Created by KEEN on 2022/05/10.
//

import UIKit
import DIKit
import KEENUIKit

extension DICaller: DataFetchable { }

class ViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
  }

  @IBAction func buttonClicked(_ sender: UIButton) {
    let vc = KeenViewController(dataFetchable: DICaller.shared)
    self.present(vc, animated: true)
  }
}

