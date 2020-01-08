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
  private lazy var refreshControl = UIRefreshControl()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    attachViews()
    configureUI()
    configureBinding()
  }
  
  override func performOnceInViewDidAppear() {
    dataSource.reload()
  }
  
  // MARK: - Actions
  @objc func refresh() {
    refreshControl.beginRefreshing()
    viewModel.getBalances()
  }
}

// MARK: - Private
private extension CashTrackerViewController {
  func configureUI() {
    navigationController?.navigationBar.prefersLargeTitles = false
    navigationItem.title = Strings.More.cashTracker
    navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
    tableView.addSubview(refreshControl)
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
    
    viewModel.onError = { [weak self] error in
      guard let self = self else { return }
      Spitter.showOkAlert(error, viewController: self)
    }
    
    viewModel.onHrBalanceChange = { [weak self] in
      self?.dataSource.update(hrBalance: self?.viewModel.hrBalance, omBalance: self?.viewModel.omBalance)
    }
    
    viewModel.onOmBalanceChange = { [weak self] in
      self?.dataSource.update(hrBalance: self?.viewModel.hrBalance, omBalance: self?.viewModel.omBalance)
    }
    
    viewModel.didGetAllBalances = { [weak self] in
      self?.refreshControl.endRefreshing()
    }
  }
}
