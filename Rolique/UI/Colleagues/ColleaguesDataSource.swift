//
//  ColleaguesDataSource.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 8/15/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit
import Utils
import SnapKit

final class ColleaguesDataSource: NSObject, UITableViewDelegate, UITableViewDataSource {
  private let tableView: UITableView
  private var data: [User]
  
  init(tableView: UITableView, data: [User]) {
    self.tableView = tableView
    self.data = data
    
    super.init()
    
    self.tableView.setDelegateAndDataSource(self)
    self.tableView.register([ColleaguesTableViewCell.self])
  }
  
  func update(dataSource: [User]) {
    self.data = dataSource
    self.tableView.reloadData()
  }
  
  func hideRefreshControl() {
    self.tableView.refreshControl?.endRefreshing()
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return data.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = ColleaguesTableViewCell.dequeued(by: tableView)
    cell.delegate = self
    cell.configure(with: data[indexPath.row])
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 100
  }
}

extension ColleaguesDataSource: ColleaguesTableViewCellDelegate {
  func touchPhone(_ cell: ColleaguesTableViewCell) {
    guard let indexPath = tableView.indexPath(for: cell) else { return }
    let phone = data[indexPath.row].slackProfile.phone.replacingOccurrences(of: " ", with: "")
    guard let url = URL(string: "tel://\(phone)") else { return }
    UIApplication.shared.open(url)
  }
}
