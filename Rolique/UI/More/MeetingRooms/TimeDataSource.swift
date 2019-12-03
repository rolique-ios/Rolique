//
//  TimeDataSource.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 11/8/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit
import Utils

private struct Constants {
  static var defaultCellHeight: CGFloat { return 40.0 }
}

final class TimeDataSource: NSObject, UITableViewDelegate, UITableViewDataSource {
  private let tableView: UITableView
  private var dataSource = [Date]()
  var didScroll: ((CGFloat) -> Void)?
  
  init(tableView: UITableView) {
    self.tableView = tableView
    
    super.init()
    
    tableView.showsVerticalScrollIndicator = false
    tableView.separatorStyle = .none
    tableView.isScrollEnabled = false
    tableView.allowsSelection = false
    tableView.backgroundColor = Colors.secondaryBackgroundColor
    tableView.setDelegateAndDataSource(self)
    tableView.register([TimeTableViewCell.self, UITableViewCell.self])
  }
  
  func updateDataSource(with dates: [Date]) {
    dataSource = dates
    tableView.reloadData()
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dataSource.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = TimeTableViewCell.dequeued(by: tableView)
    cell.configure(with: DateFormatters.timeDateFormatter.string(from: dataSource[indexPath.row]))
    return cell
  }
  
  func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    return Constants.defaultCellHeight
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return Constants.defaultCellHeight
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    didScroll?(scrollView.contentOffset.y)
  }
}
