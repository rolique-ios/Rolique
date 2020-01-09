//
//  CashHistoryViewController.swift
//  Rolique
//
//  Created by Bohdan Savych on 12/6/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit
import Utils

private struct Constants {
  static var headerHeight: CGFloat { 130 }
}

final class CashHistoryViewController<T: CashHistoryViewModel>: ViewController<T> {
  private lazy var tableView = UITableView(frame: .zero, style: .grouped)
  private lazy var dataSource = CashHistoryDataSource(tableView: self.tableView)
  private lazy var infoHeaderView = CashTrackerInfoView()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    attachViews()
    configureUI()
    configureBinding()
  }
  
  override func performOnceInViewDidLayoutSubviews() {
    view.setNeedsDisplay()
    DispatchQueue.main.async {
      self.tableView.tableHeaderView?.frame = CGRect(origin: .zero, size: .init(width: self.tableView.frame.size.width, height: Constants.headerHeight))
    }
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
    
    tableView.tableHeaderView = infoHeaderView
  }
  
  func configureBinding() {
    dataSource.expensesForSection = { [weak self] section in
      return self?.viewModel.getExpenses(for: section) ?? []
    }
    dataSource.didScrolledToBottom = { [weak self] in
      self?.viewModel.scrolledToBottom()
    }
    
    viewModel.shouldChangeLoadingVisibility = { [weak self] in
      self?.dataSource.setIsLoadingNextPage(self?.viewModel.isLoadingNextPage ?? false)
    }
    
    viewModel.shouldReloadData = { [weak self] in
      self?.dataSource.update(with: self?.viewModel.dates ?? [])
    }
    
    viewModel.onError = { [weak self] error in
      guard let self = self else { return }
      Spitter.showOkAlert(error, viewController: self)
    }
    
    dataSource.update(with: viewModel.dates)
    infoHeaderView.configure(title: viewModel.cashOwner.rawValue, cash: viewModel.balance.cash, card: viewModel.balance.card)
  }
}

