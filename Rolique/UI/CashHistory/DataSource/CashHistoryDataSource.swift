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
  private let sectionDateFormatter = DateFormatters.dateFormatter
  var dates = [Date]()
  
  var expensesForSection: ((Int) -> [Expense])?
  var didSelectExpense: ((Expense) -> Void)?
  
  init(tableView: UITableView) {
    self.tableView = tableView
    
    super.init()
    
    tableView.setDelegateAndDataSource(self)
    tableView.register([ExpenseTableViewCell.self])
  }
  
  func update(with dates: [Date]) {
    self.dates = dates
    tableView.reloadData()
  }
}

// MARK: - UITableViewDelegate
extension CashHistoryDataSource: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let expense = expensesForSection?(indexPath.section)[indexPath.row]
    expense.apply(didSelectExpense)
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    Constants.rowHeight
  }
}

// MARK: - UITableViewDataSource
extension CashHistoryDataSource: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    dates.count
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    expensesForSection?(section).count ?? 0
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    sectionDateFormatter.string(from: dates[section])
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeue(type: ExpenseTableViewCell.self, indexPath: indexPath)
    
    return cell
  }
}
