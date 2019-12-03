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
  static var defaultCellHeight: CGFloat { return 40.0 }
}

struct BookedCellData {
  let room: Room
  let count: Int
  let height: CGFloat
  let width: CGFloat
  let topOffset: CGFloat
  let bottomOffset: CGFloat
  let isIntersects: Bool
}

final class MeetingRoomsTableViewDataSource: NSObject, UITableViewDelegate, UITableViewDataSource {
  private let tableView: UITableView
  private var bookedTimeViews = [BookedTimeView]()
  private var numberOfRows: Int = 0
  private var rooms = [Room]()
  private var bookedCellData = [Int: [BookedCellData]]()
  var didScroll: ((CGPoint) -> Void)?
  var didSelectCell: ((Row) -> Void)?
  
  init(tableView: UITableView) {
    self.tableView = tableView
    
    super.init()
    
    tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: Constants.defaultCellHeight / 2, right: 0)
    tableView.separatorStyle = .none
    tableView.allowsSelection = false
    tableView.backgroundColor = Colors.secondaryBackgroundColor
    tableView.setDelegateAndDataSource(self)
    tableView.tableHeaderView = UIView().apply { v in
      v.frame = CGRect(origin: v.frame.origin, size: CGSize(width: v.frame.width, height: Constants.defaultCellHeight / 2 - 0.5))
      v.backgroundColor = Colors.secondaryBackgroundColor
    }
    tableView.register([EmptyTimeRoomTableViewCell.self,
                        BookedTimeRoomTableViewCell.self])
  }
  
  func configure(with numberOfRows: Int, rooms: [Room], contentOffsetY: CGFloat) {
    self.numberOfRows = numberOfRows
    self.rooms = rooms
    self.tableView.contentOffset = CGPoint(x: 0, y: contentOffsetY)
  }
  
  func updateDataSource(with numberOfRows: Int, rooms: [Room]) {
    self.rooms = rooms
    self.bookedCellData.removeAll()
    
    for room in rooms {
      let calendar = Calendar.utc
      let startComponents = calendar.dateComponents([.hour, .minute], from: room.start.dateTime)
      let startHour = startComponents.hour.orZero
      let startMinute = startComponents.minute.orZero
      let startIndex = (startHour - 9) * 2 + (startMinute >= 30 ? 1 : 0)
      
      let endComponents = calendar.dateComponents([.hour, .minute], from: room.end.dateTime)
      let endHour = endComponents.hour.orZero
      let endMinute = endComponents.minute.orZero
      let endIndex = (endHour - 9) * 2 + (endMinute > 0 ? 0 : -1)
      let topOffset = Constants.defaultCellHeight - CGFloat(30 - startMinute) * Constants.defaultCellHeight / 30
      let bottomOffset = Constants.defaultCellHeight - CGFloat(endMinute) * Constants.defaultCellHeight / 30
      let bookedCellData = BookedCellData(room: room,
                                          count: endIndex - startIndex + 1,
                                          height: 0,
                                          width: 0,
                                          topOffset: topOffset == 40 ? 0 : topOffset,
                                          bottomOffset: 0,
                                          isIntersects: false)
      if self.bookedCellData[startIndex] != nil {
        self.bookedCellData[startIndex]!.append(bookedCellData)
      } else {
        self.bookedCellData[startIndex] = [bookedCellData]
      }
    }
    
    var numberOfRows = numberOfRows
    for (_, value) in bookedCellData {
      numberOfRows -= (value.count - 1)
    }
    self.numberOfRows = numberOfRows
    tableView.reloadData()
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return numberOfRows
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if let data = bookedCellData[indexPath.row] {
      let cell = BookedTimeRoomTableViewCell.dequeued(by: tableView)
      cell.configure(with: data, isLast: indexPath.row == numberOfRows - 1)
      return cell
    } else {
      let cell = EmptyTimeRoomTableViewCell.dequeued(by: tableView)
      cell.configure(isLast: indexPath.row == numberOfRows - 1)
      return cell
    }
  }
  
  func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    if let bookedRoom = bookedCellData[indexPath.row] {
      return CGFloat(bookedRoom.count) * Constants.defaultCellHeight
    } else {
      return Constants.defaultCellHeight
    }
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if let bookedRoom = bookedCellData[indexPath.row] {
      return CGFloat(bookedRoom.count) * Constants.defaultCellHeight
    } else {
      return Constants.defaultCellHeight
    }
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    didScroll?(scrollView.contentOffset)
  }
}
