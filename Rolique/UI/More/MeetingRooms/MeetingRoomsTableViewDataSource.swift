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
  private var numberOfRows: Int = 0
  private var rooms = [Room]()
  private var bookedTimeViews = [BookedTimeView]()
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
    tableView.register([EmptyTimeRoomTableViewCell.self])
  }
  
  func configure(with numberOfRows: Int, rooms: [Room], contentOffsetY: CGFloat) {
    self.numberOfRows = numberOfRows
    self.rooms = rooms
    self.tableView.contentOffset = CGPoint(x: 0, y: contentOffsetY)
  }
  
  func clearDataSource() {
    self.bookedTimeViews.forEach { $0.removeFromSuperview() }
    self.bookedTimeViews.removeAll()
  }
  
  func updateDataSource(rooms: [Room]) {
    self.rooms = rooms
    self.bookedTimeViews.forEach { $0.removeFromSuperview() }
    self.bookedTimeViews.removeAll()
    
    for (index, room) in rooms.enumerated() {
      let calendar = Calendar.utc
      let startComponents = calendar.dateComponents([.hour, .minute], from: room.start.dateTime)
      let startHour = startComponents.hour.orZero
      let startMinute = startComponents.minute.orZero
      
      let endComponents = calendar.dateComponents([.hour, .minute], from: room.end.dateTime)
      let endHour = endComponents.hour.orZero
      let endMinute = endComponents.minute.orZero
      let yPoint = ((CGFloat(startHour - 9)) * 2 * Constants.defaultCellHeight + CGFloat(startMinute) / CGFloat(Constants.minutesStep) * Constants.defaultCellHeight) + Constants.defaultCellHeight / 2
      let minutesHeight = abs((CGFloat(endMinute) / CGFloat(Constants.minutesStep) * Constants.defaultCellHeight) - (CGFloat(startMinute) / CGFloat(Constants.minutesStep) * Constants.defaultCellHeight))
      let hoursHeight = CGFloat(endHour - startHour) * 2 * Constants.defaultCellHeight
      let height = abs(hoursHeight - minutesHeight)
      
      let start = calendar.date(byAdding: startComponents, to: Date().utc).orCurrent
      let end = calendar.date(byAdding: endComponents, to: Date().utc).orCurrent
      
      var firstIntersectedIndex: Int?
      let instesects = rooms.enumerated().filter { (filteredIndex, filteredRoom) in
        guard room.id != filteredRoom.id else { return false }
        
        let filteredRoomStartComponents = calendar.dateComponents([.hour, .minute], from: filteredRoom.start.dateTime)
        let filteredRoomEndComponents = calendar.dateComponents([.hour, .minute], from: filteredRoom.end.dateTime)
        let filteredRoomStart = calendar.date(byAdding: filteredRoomStartComponents, to: Date().utc).orCurrent
        let filteredRoomEnd = calendar.date(byAdding: filteredRoomEndComponents, to: Date().utc).orCurrent
        
        if start >= filteredRoomStart && start < filteredRoomEnd || filteredRoomStart >= start && filteredRoomStart < end {
          if firstIntersectedIndex == nil {
            firstIntersectedIndex = filteredIndex
          }
          
          return true
        }
        
        return false
      }
      
      let width = instesects.isEmpty ? tableView.bounds.width : tableView.bounds.width / CGFloat(instesects.count + 1)
      let xPoint = instesects.isEmpty ? CGFloat.zero : firstIntersectedIndex.orZero < index ? CGFloat(index - firstIntersectedIndex.orZero) * width : CGFloat.zero
      
      let bookedTimeView = BookedTimeView(frame: CGRect(origin: CGPoint(x: xPoint + Constants.defaultOffset, y: yPoint + Constants.defaultOffset),
                                                        size: CGSize(width: xPoint + width == tableView.bounds.width ? width - Constants.edgeOffset : width - Constants.defaultOffset,
                                                                     height: height - Constants.defaultOffset * 2)))
      bookedTimeView.update(with: room.title)
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
