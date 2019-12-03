//
//  MeetingRoomsCollectionViewDataSource.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 11/18/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit
import Utils

final class MeetingRoomsCollectionViewDataSource: NSObject,
  UICollectionViewDelegate,
  UICollectionViewDelegateFlowLayout,
  UICollectionViewDataSource {
  private let collectionView: UICollectionView
  private let meetingRooms = MeetingRoom.allCases
  private let timeTableView: UITableView
  private var currentPage = 0
  private var tableViewNumberOfRows = 0
  private var meetingRoomsDataSource = [MeetingRoom: [Room]]()
  var didScroll: ((CGPoint) -> Void)?
  var didChangeCurrentPage: ((Int) -> Void)?
  
  init(collectionView: UICollectionView,
       timeTableView: UITableView) {
    self.collectionView = collectionView
    self.timeTableView = timeTableView
    
    super.init()
    
    collectionView.backgroundColor = Colors.secondaryBackgroundColor
    collectionView.isPagingEnabled = true
    collectionView.setDelegateAndDatasource(self)
    collectionView.register([MeetingRoomCollectionViewCell.self])
  }
  
  func configure(with tableViewNumberOfRows: Int) {
    self.tableViewNumberOfRows = tableViewNumberOfRows
  }
  
  func clearDataSource(with room: MeetingRoom) {
    guard let index = meetingRooms.firstIndex(of: room),
      let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? MeetingRoomCollectionViewCell else { return }
    
    cell.clearTableViewDataSource()
  }
  
  func clearDataSource() {
    for (index, _) in meetingRooms.enumerated() {
      guard let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? MeetingRoomCollectionViewCell else { continue }
      
      cell.clearTableViewDataSource()
    }
  }
  
  func updateDataSource(with room: MeetingRoom, rooms: [Room]) {
    meetingRoomsDataSource[room] = rooms
    
    guard let index = meetingRooms.firstIndex(of: room),
      let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? MeetingRoomCollectionViewCell else { return }
    
    cell.updateTableViewDataSource(rooms: rooms)
  }
  
  func viewWillTransition() {
    self.collectionView.performBatchUpdates({ [weak self] in
      guard let self = self else { return }
      self.collectionView.bounds.origin.x = CGFloat(self.currentPage) * self.collectionView.bounds.width
    }, completion: nil)
  }
  
  //MARK: - UICollectionViewDataSource
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return meetingRooms.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeue(type: MeetingRoomCollectionViewCell.self, indexPath: indexPath)
    let meetingRoom = meetingRooms[indexPath.row]
    cell.configure(with: tableViewNumberOfRows, rooms: meetingRoomsDataSource[meetingRoom] ?? [], contentOffsetY: timeTableView.contentOffset.y)
    cell.tableViewDidScroll = { [weak self] contentOffset in
      self?.timeTableView.setContentOffset(CGPoint(x: 0, y: contentOffset.y), animated: false)
    }

    return cell
  }
  
  //MARK: - UICollectionViewDelegate
  func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    let meetingRoom = meetingRooms[indexPath.row]
    (cell as! MeetingRoomCollectionViewCell).configure(with: tableViewNumberOfRows, rooms: meetingRoomsDataSource[meetingRoom] ?? [], contentOffsetY: timeTableView.contentOffset.y)
  }
  
  //MARK: - UIScrollViewDelegate
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    didScroll?(scrollView.contentOffset)
  }
  
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    let page = floor(scrollView.contentOffset.x / scrollView.frame.width)
    let currentPage = Int(page)
    
    guard self.currentPage != currentPage else { return }
    self.currentPage = currentPage
    didChangeCurrentPage?(currentPage)
  }
  
  //MARK: - UICollectionViewFlowLayout
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return collectionView.bounds.size
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return .zero
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 0
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 0
  }
}
