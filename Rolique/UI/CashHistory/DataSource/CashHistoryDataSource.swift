//
//  CashHistoryDataSource.swift
//  Rolique
//
//  Created by Bohdan Savych on 12/9/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit
import Utils

private struct Constants {
  static var rowHeight: CGFloat { 50 }
}

final class CashHistoryDataSource: NSObject {
  private let tableView: UITableView
  private let sectionDateFormatter = DateFormatters.groupedExpenseDateFormatter
  private let expenseDateFormatter = DateFormatters.expenseDateFormatter
  var dates = [Date]()
  private lazy var isLoadingNextPage = false
  
  var expensesForSection: ((Int) -> [Expense])?
  var didSelectExpense: ((Expense) -> Void)?
  var didScrolledToBottom: Completion?
  
  init(tableView: UITableView) {
    self.tableView = tableView
    
    super.init()
    
    tableView.setDelegateAndDataSource(self)
    tableView.register([ExpenseTableViewCell.self, LoadingTableViewCell.self])
  }
  
  func update(with dates: [Date]) {
    self.dates = dates
    tableView.reloadData()
  }
  
  func setIsLoadingNextPage(_ value: Bool) {
    isLoadingNextPage = value
    let expenses = expensesForSection?(dates.count - 1) ?? []
    let indexPath = IndexPath(row: expenses.count, section: dates.count - 1)

    DispatchQueue.main.async { [weak self] in
      self?.tableView.beginUpdates()
      if value {
        self?.tableView.insertRows(at: [indexPath], with: .automatic)
      } else {
        self?.tableView.deleteRows(at: [indexPath], with: .automatic)
      }
      self?.tableView.endUpdates()
    }
  }
}

// MARK: - UITableViewDelegate
extension CashHistoryDataSource: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    let isLastSection = indexPath.section == dates.count - 1
    let expenses = expensesForSection?(indexPath.section) ?? []
    
    if isLastSection && isLoadingNextPage && indexPath.row >= expenses.count {
      return
    }
    
    let expense = expensesForSection?(indexPath.section)[indexPath.row]
    expense.apply(didSelectExpense)
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let isLastSection = indexPath.section == dates.count - 1
    let expenses = expensesForSection?(indexPath.section) ?? []
    
    if isLastSection && isLoadingNextPage && indexPath.row >= expenses.count {
      return 50
    }
    
    let expense = expensesForSection?(indexPath.section)[indexPath.row]
    return ExpenseTableViewCell.height(for: expense?.description ?? "", width: tableView.bounds.width)
  }
  
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    if dates[indexPath.section] == dates.last {
      didScrolledToBottom?()
    }
  }
}

// MARK: - UITableViewDataSource
extension CashHistoryDataSource: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    dates.count
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let rows = expensesForSection?(section).count ?? 0
    let isLastSection = section == dates.count - 1
    let count = rows + (isLastSection && isLoadingNextPage ? 1 : 0)
    
    return count
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    sectionDateFormatter.string(from: dates[section])
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let isLastSection = indexPath.section == dates.count - 1
    let expenses = expensesForSection?(indexPath.section) ?? []
    
    if isLastSection && isLoadingNextPage && indexPath.row >= expenses.count {
      let cell = tableView.dequeue(type: LoadingTableViewCell.self, indexPath: indexPath)
      cell.selectionStyle = .none
      cell.startAnimating()
      return cell
    }
    
    let cell = tableView.dequeue(type: ExpenseTableViewCell.self, indexPath: indexPath)
    let expense = expensesForSection?(indexPath.section)[indexPath.row]
    cell.configure(description: expense?.description ?? "", value: expense?.value ?? 0, dateString: expenseDateFormatter.string(from: (expense?.date).orCurrent))

    return cell
  }
}
