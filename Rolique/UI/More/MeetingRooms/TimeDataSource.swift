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
  static var defaultCellHeight: CGFloat { return 30.0 }
}

final class TimeDataSource: NSObject, UITableViewDelegate, UITableViewDataSource {
  private let tableView: UITableView
  private let numberOfRows: Int
  private let dataSource: [Date]
  private let dateFormatter: DateFormatter = {
    var dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone(identifier: "UTC")!
    dateFormatter.dateFormat = "HH:mm"
    return dateFormatter
  }()
  var didScroll: ((CGFloat) -> Void)?
  
  init(tableView: UITableView,
       numberOfRows: Int,
       dataSource: [Date]) {
    self.tableView = tableView
    self.numberOfRows = numberOfRows
    self.dataSource = dataSource
    
    super.init()
    
    tableView.isScrollEnabled = false
    tableView.allowsSelection = false
    tableView.backgroundColor = Colors.mainBackgroundColor
    tableView.setDelegateAndDataSource(self)
    tableView.tableHeaderView = UIView().apply { v in
      v.frame = CGRect(origin: v.frame.origin, size: CGSize(width: v.frame.width, height: 0.5 +  Constants.defaultCellHeight / 2))
      v.backgroundColor = .red
      return v
    }
    
    tableView.register([TimeTableViewCell.self, UITableViewCell.self])
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dataSource.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = TimeTableViewCell.dequeued(by: tableView)
    cell.configure(with: dateFormatter.string(from: dataSource[indexPath.row]))
    return cell
  }
  
  func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    let cellHeight = Constants.defaultCellHeight
    return cellHeight
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let cellHeight = Constants.defaultCellHeight
    return cellHeight
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    didScroll?(scrollView.contentOffset.y)
  }
}
