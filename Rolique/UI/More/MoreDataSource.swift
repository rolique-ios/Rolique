//
//  MoreDataSource.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 11/7/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit
import Utils

enum CellType {
  case user
  case meetingRooms
}

private struct TableViewIndexPaths {
  static var user: IndexPath { return IndexPath(row: 0, section: 0) }
  static var meetingRooms: IndexPath { return IndexPath(row: 0, section: 1) }
}

private struct CellInfo {
  let icon: UIImage
  let title: String
}

private struct Constants {
  static var userCellHeight: CGFloat { return 80 }
  static var defaultCellHeight: CGFloat { return 60 }
  static var heightForHeaderInSection: CGFloat { return 15.0 }
  static var heightForFooterInSection: CGFloat { return 0.0001 }
}

final class MoreDataSource: NSObject, UITableViewDelegate, UITableViewDataSource {
  private let tableView: UITableView
  private let user: User
  private var data = [CellInfo(icon: Images.More.meetingRoom, title: Strings.More.meetingRooms)]
  private let numberOfSections = 2
  var didSelectCell: ((CellType) -> Void)?
  
  init(tableView: UITableView,
       user: User) {
    self.tableView = tableView
    self.user = user
    
    super.init()
    
    tableView.backgroundColor = Colors.seconaryGroupedBackgroundColor
    tableView.setDelegateAndDataSource(self)
    tableView.register([ProfileTableViewCell.self,
                        MoreTableViewCell.self])
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return numberOfSections
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case TableViewIndexPaths.user.section:
      return 1
    case TableViewIndexPaths.meetingRooms.section:
      return data.count
    default:
      return 0
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch indexPath {
    case TableViewIndexPaths.user:
      let cell = ProfileTableViewCell.dequeued(by: tableView)
      cell.configure(with: user.slackProfile.realName,
                     userImage: user.biggestImage,
                     todayStatus: user.todayStatus,
                     title: user.slackProfile.title)
      return cell
    case TableViewIndexPaths.meetingRooms:
      let cell = MoreTableViewCell.dequeued(by: tableView)
      let cellInfo = data[indexPath.row]
      cell.configure(with: cellInfo.title, icon: cellInfo.icon)
      return cell
    default:
      return UITableViewCell()
    }
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    switch indexPath {
    case TableViewIndexPaths.user:
      return Constants.userCellHeight
    case TableViewIndexPaths.meetingRooms:
      return Constants.defaultCellHeight
    default:
      return 0
    }
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    switch indexPath {
    case TableViewIndexPaths.user:
      didSelectCell?(.user)
    case TableViewIndexPaths.meetingRooms:
      didSelectCell?(.meetingRooms)
    default:
      break
    }
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    return UIView()
  }
  
  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    return UIView()
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return Constants.heightForHeaderInSection
  }
  
  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return Constants.heightForFooterInSection
  }
  
}
