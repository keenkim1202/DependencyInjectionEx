//
//  KeenViewController.swift
//  KEENUIKit
//
//  Created by KEEN on 2022/05/10.
//

import UIKit

public protocol DataFetchable {
  func fetchRandomNames(completion: @escaping ([String]) -> Void)
}

struct User {
  let name: String
}

public class KeenViewController: UIViewController {
  
  let dataFetchable: DataFetchable
  
  private let tableView: UITableView = {
    let tableView = UITableView()
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    return tableView
  }()
  
  public init(dataFetchable: DataFetchable) {
    self.dataFetchable = dataFetchable
    super.init(nibName: nil, bundle: nil)
  }
  
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  var names: [User] = []
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    view.addSubview(tableView)
    tableView.delegate = self
    tableView.dataSource = self
    configure()
  }
  
  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    tableView.frame = view.bounds
  }
  
  func configure() {
    view.backgroundColor = .systemBackground
    dataFetchable.fetchRandomNames { [weak self] names in
      self?.names = names.map { User(name: $0) }
      
      DispatchQueue.main.async {
        self?.tableView.reloadData()
      }
    }
  }
  
}

extension KeenViewController: UITableViewDelegate, UITableViewDataSource {
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return names.count
  }
  
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    cell.textLabel?.text = names[indexPath.row].name
    return cell
  }
}
