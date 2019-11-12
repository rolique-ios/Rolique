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
  private lazy var meetingView = MeetingRoomView()
  private(set) lazy var tableView = UITableView()
  private lazy var panGesture = UIPanGestureRecognizer(target: self, action: #selector(didTap(gesture:)))
  private lazy var dataSource = MeetingRoomsDataSource(tableView: tableView)
  private var selectedRow = -1
  private var previousLocation: CGFloat = 0
  private var direction: Direction?
  var tableViewDidScroll: ((CGFloat) -> Void)?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.backgroundColor = Colors.mainBackgroundColor
    
    configureViews()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  func configure(with numberOfRows: Int, meetingName: String, contentOffsetY: CGFloat, index: Int) {
    dataSource.configure(with: numberOfRows, contentOffsetY: contentOffsetY)
    dataSource.didScroll = { [weak self] contentOffsetY in
      self?.tableViewDidScroll?(contentOffsetY)
    }
    
    meetingView.configure(with: meetingName)
  }
  
  func edit() {
    tableView.allowsMultipleSelection = true
    tableView.addGestureRecognizer(panGesture)
  }
  
  func done() {
    tableView.allowsMultipleSelection = false
    tableView.removeGestureRecognizer(panGesture)
    selectedRow = -1
    previousLocation = 0
  }
  
  private func configureViews() {
    [meetingView, tableView].forEach(self.addSubview)
    
    meetingView.snp.makeConstraints { maker in
      maker.left.top.right.equalToSuperview()
      maker.height.equalTo(Constants.meetingViewHeight)
    }
    
    tableView.snp.makeConstraints { maker in
      maker.top.equalTo(meetingView.snp.bottom)
      maker.left.bottom.right.equalToSuperview()
    }
  }
  
  @objc func didTap(gesture: UIPanGestureRecognizer) {
    switch gesture.state {
    case .possible, .began, .changed:
      let location = gesture.location(in: tableView).y
      
      if location - tableView.frame.height > tableView.contentOffset.y && location <= tableView.contentSize.height {
        tableView.contentOffset.y += (location - tableView.frame.height) - tableView.contentOffset.y
        print("MODIF 82")
      }
      
      if location > 0 && location < tableView.contentOffset.y {
        tableView.contentOffset.y -= abs(location - tableView.contentOffset.y)
        print("MODIF 86")
      }
      
      let row = Int(floor(location / Constants.cellHeight))
      
      var changeDirection: Bool
      if location < previousLocation {
        if direction ?? .toTop != Direction.toBottom {
          changeDirection = true
        } else {
          changeDirection = false
        }
        direction = .toBottom
      } else {
        if direction ?? .toBottom != Direction.toTop {
          changeDirection = true
        } else {
          changeDirection = false
        }
        direction = .toTop
      }
      previousLocation = location
      
      guard row != selectedRow || changeDirection else { return }
      
      let indexPath = IndexPath(row: row, section: 0)
      if let selectedRows = tableView.indexPathsForSelectedRows, selectedRows.contains(indexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
      } else if indexPath.row != tableView.numberOfRows(inSection: 0) - 1 {
        tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
      }
      selectedRow = row
    default:
      break
    }
  }
}
