//
//  MeetingRoomCollectionViewCell.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 11/11/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit
import SnapKit
import Utils

private struct Constants {
  static var meetingViewHeight: CGFloat { return 30.0 }
  static var cellHeight: CGFloat { return 30.0 }
}

final class MeetingRoomCollectionViewCell: UICollectionViewCell {
  private lazy var tableView = UITableView()
  private lazy var dataSource = MeetingRoomsTableViewDataSource(tableView: tableView)
  private(set) var tableViewSelectedIndexPaths = [IndexPath]()
  var tableViewDidScroll: ((CGPoint) -> Void)?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.backgroundColor = Colors.secondaryBackgroundColor
    
    configureViews()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  func configure(with numberOfRows: Int, contentOffsetY: CGFloat) {
    dataSource.configure(with: numberOfRows, contentOffsetY: contentOffsetY)
    dataSource.didScroll = { [weak self] contentOffset in
      self?.tableViewDidScroll?(contentOffset)
    }
  }
  
  func clearTableViewDataSource() {
    dataSource.clearDataSource()
  }
  
  func updateTableViewDataSource(roomsData: [RoomData]) {
    dataSource.updateDataSource(roomsData: roomsData)
  }
  
  func edit() {
    tableView.allowsMultipleSelection = true
  }
  
  func book() {
    tableView.allowsMultipleSelection = false
    tableViewSelectedIndexPaths = tableView.indexPathsForSelectedRows ?? []
  }
  
  func finishBooking() {
    for indexPath in tableView.indexPathsForSelectedRows ?? [] {
      tableView.deselectRow(at: indexPath, animated: false)
    }
  }
  
  private func configureViews() {
    [tableView].forEach(self.addSubview)
    
    tableView.snp.makeConstraints { maker in
      maker.edges.equalToSuperview()
    }
  }
}
