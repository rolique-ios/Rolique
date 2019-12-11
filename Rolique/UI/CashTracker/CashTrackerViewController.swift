//
//  CashTrackerViewController.swift
//  Rolique
//
//  Created by Bohdan Savych on 12/5/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit
import Utils

final class CashTrackerViewController<T: CashTrackerViewModel>: ViewController<T> {
  private lazy var tableView = UITableView(frame: .zero, style: .grouped)
  private lazy var dataSource = CashTrackerDataSource(tableView: tableView)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    attachViews()
    configureUI()
    configureBinding()
  }
  
  override func performOnceInViewDidAppear() {
    dataSource.reload()
  }
}

// MARK: - Private
private extension CashTrackerViewController {
  func configureUI() {
    navigationController?.navigationBar.prefersLargeTitles = false
    navigationItem.title = Strings.More.cashTracker
    navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
  }
  
  func attachViews() {
    [tableView].forEach(view.addSubview)
    
    tableView.snp.makeConstraints {
      $0.top.equalTo(self.view.safeAreaLayoutGuide)
      $0.left.right.bottom.equalToSuperview()
    }
  }
  
  func configureBinding() {
    dataSource.didSelect = { [weak self] cashOwner, cashType in
      self?.viewModel.select(cashOwner: cashOwner, cashType: cashType)
    }
  }
}
