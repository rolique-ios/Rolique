//
//  CashTrackerDataSource.swift
//  Rolique
//
//  Created by Bohdan Savych on 12/6/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit
import Utils

private struct Constants {
  static var rowHeight: CGFloat { 50 }
}


final class CashTrackerDataSource: NSObject {
  private let tableView: UITableView
  private let sections = CashOwner.allCases
  private lazy var expandedDictionary = [IndexPath: Bool]()
  private var hrBalance: Balance?
  private var omBalance: Balance?
  
  var didSelect: ((CashOwner, CashType) -> Void)?
  
  init(tableView: UITableView) {
    self.tableView = tableView

    super.init()
    
    configure()
  }
  
  func update(hrBalance: Balance?, omBalance: Balance?) {
    self.hrBalance = hrBalance
    self.omBalance = omBalance
    reload()
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
    let rows = section.types.count
    
    return rows
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeue(type: CashTypeTableViewCell.self, indexPath: indexPath)
    let section = sections[indexPath.section]
    let row = section.types[indexPath.row]
    
    switch section {
    case .hrManager:
      cell.configure(text: "\(row == .card ? hrBalance?.card ?? 0 : hrBalance?.cash ?? 0) UAH", image: row.image)

    case .officeManager:
      cell.configure(text: "\(row == .card ? omBalance?.card ?? 0 : omBalance?.cash ?? 0) UAH", image: row.image)

    }
    
    
    return cell
  }
}

// MARK: - UITableViewDelegate
extension CashTrackerDataSource: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let section = sections[indexPath.section]
    let row = section.types[indexPath.row]

    didSelect?(section, row)
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
