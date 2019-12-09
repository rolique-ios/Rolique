//
//  MeetingRoomsTableViewDataSource.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 11/8/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit
import Utils

private struct Constants {
  static var minutesStep: Int { return 30 }
  static var defaultCellHeight: CGFloat { return 40.0 }
  static var defaultOffset: CGFloat { return 2.0 }
  static var edgeOffset: CGFloat { return 15.0 }
}

final class MeetingRoomsTableViewDataSource: NSObject, UITableViewDelegate, UITableViewDataSource {
  private let tableView: UITableView
  private var numberOfRows: Int = 0
  private var roomsData = [RoomData]()
  private var bookedTimeViews = [BookedTimeView]()
  var didScroll: ((CGPoint) -> Void)?
  var didSelectCell: ((Row) -> Void)?
  
  init(tableView: UITableView) {
    self.tableView = tableView
    
    super.init()
    
    tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: Constants.defaultCellHeight / 2, right: 0)
    tableView.showsVerticalScrollIndicator = false
    tableView.separatorStyle = .none
    tableView.allowsSelection = false
    tableView.backgroundColor = Colors.secondaryBackgroundColor
    tableView.setDelegateAndDataSource(self)
    tableView.tableHeaderView = UIView().apply { v in
      v.frame = CGRect(origin: v.frame.origin, size: CGSize(width: v.frame.width, height: Constants.defaultCellHeight / 2 - 0.5))
      v.backgroundColor = Colors.secondaryBackgroundColor
    }
    tableView.register([EmptyTimeRoomTableViewCell.self])
  }
  
  func configure(with numberOfRows: Int, contentOffsetY: CGFloat) {
    self.numberOfRows = numberOfRows
    self.tableView.contentOffset = CGPoint(x: 0, y: contentOffsetY)
  }
  
  func clearDataSource() {
    self.bookedTimeViews.forEach { $0.removeFromSuperview() }
    self.bookedTimeViews.removeAll()
  }
  
  func updateDataSource(roomsData: [RoomData]) {
    self.roomsData = roomsData
    self.bookedTimeViews.forEach { $0.removeFromSuperview() }
    self.bookedTimeViews.removeAll()
    
    for roomData in roomsData {
      let frame: CGRect
      if UIDevice.current.orientation == .portrait {
        frame = roomData.verticalFrame ?? .zero
      } else {
        frame = roomData.horizontalFrame ?? .zero
      }
      let bookedTimeView = BookedTimeView(frame: frame)
      let time = DateFormatters.hourDateFormatter.string(from: roomData.room.start.dateTime)
      bookedTimeView.update(with: (roomData.room.title ?? Strings.MeetingRooms.noTitle) + ", " + time)
      bookedTimeViews.append(bookedTimeView)
      tableView.addSubview(bookedTimeView)
    }
    
    tableView.reloadData()
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return numberOfRows
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = EmptyTimeRoomTableViewCell.dequeued(by: tableView)
    cell.configure(isLast: indexPath.row == numberOfRows - 1)
    return cell
  }
  
  func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    return Constants.defaultCellHeight
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return Constants.defaultCellHeight
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    didScroll?(scrollView.contentOffset)
  }
}
