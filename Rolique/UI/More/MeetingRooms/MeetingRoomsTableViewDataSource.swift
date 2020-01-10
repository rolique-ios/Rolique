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
  static var headerHeight: CGFloat { return Constants.defaultCellHeight / 2 - 0.5 }
}

final class MeetingRoomsTableViewDataSource: NSObject, UITableViewDelegate, UITableViewDataSource {
  private let tableView: UITableView
  private var selectedRow = -1
  private var previousLocation: CGFloat = 0
  private var direction: Direction?
  private var numberOfRows: Int = 0
  private var roomsData = [RoomData]()
  private var bookedTimeViews = [BookedTimeView]()
  var didScroll: ((CGPoint) -> Void)?
  var didSelectCell: ((MoreTableRow) -> Void)?
  var didChangedEditMode: Completion?
  
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
      v.frame = CGRect(origin: v.frame.origin, size: CGSize(width: v.frame.width, height: Constants.headerHeight))
      v.backgroundColor = Colors.secondaryBackgroundColor
    }
    tableView.register([EmptyTimeRoomTableViewCell.self])
    let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(tableViewLongPressGesture))
    tableView.addGestureRecognizer(longPressGesture)
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
      switch UIDevice.current.orientation {
      case .portrait, .portraitUpsideDown, .faceUp, .faceDown:
        frame = roomData.verticalFrame ?? .zero
      default:
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
  
  @objc func tableViewLongPressGesture(sender: UILongPressGestureRecognizer) {
    switch sender.state {
    case .possible, .began:
      didChangedEditMode?()
      tableView.isScrollEnabled = false
      tableView.allowsMultipleSelection = true
      let location = sender.location(in: tableView).y
      let row = Int(floor((location - Constants.headerHeight) / Constants.defaultCellHeight))
      tableView.selectRow(at: IndexPath(row: row, section: 0), animated: false, scrollPosition: .none)
      selectedRow = row
      previousLocation = location
    case .changed:
      let location = sender.location(in: tableView).y
      
      if location - tableView.frame.height > tableView.contentOffset.y && location <= tableView.contentSize.height + tableView.contentInset.bottom {
        tableView.contentOffset.y += (location - tableView.frame.height) - tableView.contentOffset.y
      }
      
      if location > 0 && location < tableView.contentOffset.y {
        tableView.contentOffset.y -= abs(location - tableView.contentOffset.y)
      }
      
      let row = Int(floor((location - Constants.headerHeight) / Constants.defaultCellHeight))
      
      var changeDirection: Bool
      switch location {
      case let(location) where location < previousLocation:
        if direction ?? .toBottom != Direction.toBottom {
          changeDirection = true
        } else {
          changeDirection = false
        }
        direction = .toBottom
      case let(location) where location > previousLocation:
        if direction ?? .toTop != Direction.toTop {
          changeDirection = true
        } else {
          changeDirection = false
        }
        direction = .toTop
      default:
        changeDirection = false
      }
      previousLocation = location
      
      guard row != selectedRow || changeDirection else { return }
      
      let indexPath = IndexPath(row: row, section: 0)
      if let selectedRows = tableView.indexPathsForSelectedRows, selectedRows.contains(indexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
      } else if indexPath.row != numberOfRows {
        tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
      }
      selectedRow = row
    case .ended, .cancelled, .failed:
      tableView.allowsMultipleSelection = false
      tableView.isScrollEnabled = true
      direction = nil
      selectedRow = -1
      previousLocation = 0
      didChangedEditMode?()
    @unknown default:
      break
    }
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
