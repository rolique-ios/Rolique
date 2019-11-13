//
//  MeetingRoomsDataSource.swift
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

final class MeetingRoomsDataSource: NSObject, UITableViewDelegate, UITableViewDataSource {
  private let tableView: UITableView
  private var numberOfRows: Int = 0
  var didScroll: ((CGFloat) -> Void)?
  var didSelectCell: ((Row) -> Void)?
  
  init(tableView: UITableView) {
    self.tableView = tableView
    
    super.init()
    
    tableView.separatorStyle = .none
    tableView.allowsSelection = false
    tableView.backgroundColor = Colors.mainBackgroundColor
    tableView.setDelegateAndDataSource(self)
    tableView.register([MeetingRoomTableViewCell.self])
  }
  
  func configure(with numberOfRows: Int, contentOffsetY: CGFloat) {
    self.numberOfRows = numberOfRows
    self.tableView.contentOffset = CGPoint(x: 0, y: contentOffsetY)
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return numberOfRows
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = MeetingRoomTableViewCell.dequeued(by: tableView)
    cell.configure(isLast: false)
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
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    didScroll?(scrollView.contentOffset.y)
  }
}
