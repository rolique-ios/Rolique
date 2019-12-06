//
//  CashTrackerDataSource.swift
//  Rolique
//
//  Created by Bohdan Savych on 12/6/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit

private struct Constants {
  static var rowHeight: CGFloat { 50 }
}

private enum Section: String, CaseIterable {
  case officeManager = "Office Manager",
  hrManager = "Human Resource Manager"
  
  var rows: [Row] {
    [.card, .cash]
  }
}

private enum Row {
  case card,
  cash
}

final class CashTrackerDataSource: NSObject {
  private let tableView: UITableView
  private let sections = Section.allCases
  
  init(tableView: UITableView) {
    self.tableView = tableView

    super.init()
    
    configure()
  }
  
  func reload() {
    tableView.reloadData()
  }
}

// MARK: - UITableViewDataSource
extension CashTrackerDataSource: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    sections.count
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let section = sections[section]
    let rows = section.rows.count
    
    return rows
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeue(type: CashTypeTableViewCell.self, indexPath: indexPath)
    
    return cell
  }
}

// MARK: - UITableViewDelegate
extension CashTrackerDataSource: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    sections[section].rawValue
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    Constants.rowHeight
  }
}

// MARK: - Private
private extension CashTrackerDataSource {
  func configure() {
    if #available(iOS 13.0, *) {
      tableView.automaticallyAdjustsScrollIndicatorInsets = false
    }
    
    tableView.contentInset = .zero
    tableView.setDelegateAndDataSource(self)
    tableView.register([CashTypeTableViewCell.self])
    tableView.reloadData()
  }
}
