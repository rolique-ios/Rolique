//
//  CashHistoryViewController.swift
//  Rolique
//
//  Created by Bohdan Savych on 12/6/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit

final class CashHistoryViewController<T: CashHistoryViewModel>: ViewController<T> {
  private lazy var tableView = UITableView(frame: .zero, style: .grouped)
  private lazy var dataSource = CashHistoryDataSource(tableView: self.tableView)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    attachViews()
    configureUI()
    configureBinding()
  }
}

// MARK: - Private
private extension CashHistoryViewController {
  func configureUI() {
    navigationItem.title = "History"
  }
  
  func attachViews() {
    [tableView].forEach(view.addSubview)
    tableView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
  }
  
  func configureBinding() {
    dataSource.expensesForSection = { [weak self] section in
      return self?.viewModel.getExpenses(for: section) ?? []
    }
    dataSource.update(with: viewModel.dates)
  }
}

