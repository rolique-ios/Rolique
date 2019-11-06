//
//  GridDataSource.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 10/24/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit
import Utils
import SnapKit

private struct Constants {
  static var pageItems: Int { return 7 }
  static var stickyRowsCount: Int { return 1 }
  static var defaultItemHeight: CGFloat { return 80.0 }
  static var stickyRowWidth: CGFloat { return 60.0 }
}

enum Direction {
  case toLeft, toRight
}

extension RecordType {
  var abbreviation: (String, UIColor) {
    switch self {
    case .vacation:
      return ("V", Colors.Calendar.vacation)
    case .remote:
      return ("R", Colors.Calendar.remote)
    case .sick:
      return ("S", Colors.Calendar.sick)
    case .dayoff:
      return ("D", Colors.Calendar.dayOff)
    case .business_trip:
      return ("Bt", Colors.Calendar.businessTrip)
    case .marrige:
      return ("M", Colors.Calendar.marrige)
    case .baby_birth:
      return ("Bb", Colors.Calendar.babyBirth)
    case .funeral:
      return ("P", Colors.Calendar.funeral)
    case .birthday:
      return ("Bd", Colors.Calendar.babyBirth)
    default:
      return ("", .clear)
    }
  }
}

final class GridDataSouce: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
  private var gridCollectionView: UICollectionView
  private var gridLayout: GridCollectionViewFlowLayout
  private var users: [User]
  private var startDate: Date
  private var endDate: Date
  private var events: [Date: [String: [SequentialRecordType]]]
  // devisible by 7 days + 1
  private let numberOfRows: Int
  private var currentContentOffsetX: CGFloat = 0
  private var currentIndex = 0
  private let currentWeekMonday = Date().mondayOfWeekUtc
  private let dateFormatter = DateFormatter()
  private let today = Date().utc
  var onMonthUpdate: ((String) -> Void)?
  var getMoreEvents: ((Direction) -> Void)?
  var didScroll: ((CGPoint) -> Void)?
  var didChangeCurrentOffsetX: ((CGFloat) -> Void)?
  
  init(gridCollectionView: UICollectionView,
       gridLayout: GridCollectionViewFlowLayout,
       users: [User],
       startDate: Date,
       endDate: Date,
       events: [Date: [String: [SequentialRecordType]]],
       numberOfRows: Int) {
    self.gridCollectionView = gridCollectionView
    self.gridLayout = gridLayout
    self.users = users
    self.startDate = startDate
    self.endDate = endDate
    self.events = events
    self.numberOfRows = numberOfRows
    
    super.init()
    
    gridCollectionView.showsHorizontalScrollIndicator = false
    gridCollectionView.backgroundColor = Colors.secondaryBackgroundColor
    gridCollectionView.isDirectionalLockEnabled = true
    gridCollectionView.setDelegateAndDatasource(self)
    gridCollectionView.register([GridCollectionViewCell.self])
  }
  
  func configureCalendarLayout(with safeAreaInsets: UIEdgeInsets, viewWidth: CGFloat) {
    let insets = safeAreaInsets.left + safeAreaInsets.right + CGFloat(Constants.stickyRowsCount) * Constants.stickyRowWidth
    let defaultItemWidth = (viewWidth - insets) / CGFloat(Constants.pageItems)
    
    gridLayout.configure(itemWidth: defaultItemWidth,
                             itemHeight: Constants.defaultItemHeight)
  }
  
  func update(users: [User]) {
    self.users = users
    self.gridCollectionView.reloadData()
    self.gridLayout.reloadCache()
  }
  
  func update(events: [Date: [String: [SequentialRecordType]]]) {
    self.events = events
    self.gridCollectionView.reloadData()
  }
  
  func update(startDate: Date, endDate: Date) {
    self.startDate = startDate
    self.endDate = endDate
  }
  
  func updateCurrentContentOffsetX(with offset: CGFloat) {
    currentContentOffsetX = offset
    currentIndex = Int(offset / (gridLayout.itemWidth * CGFloat(Constants.pageItems)))
  }
  
  func scrollToToday(animated: Bool) {
    let hulfOfContentSize = gridLayout.itemWidth * CGFloat(numberOfRows) / 2
    let itemWidth = gridLayout.itemWidth
    let page = (itemWidth * CGFloat(Constants.pageItems))
    let currentIndex = Int(hulfOfContentSize / page)
    let leftBound = CGFloat(currentIndex) * page
    self.currentIndex = currentIndex
    
    gridCollectionView.setContentOffset(CGPoint(x: leftBound, y: gridCollectionView.contentOffset.y), animated: animated)
    currentContentOffsetX = leftBound
    didChangeCurrentOffsetX?(currentContentOffsetX)
  }
  
  func changeItemWidthOnViewWillTransition(with safeAreaInsets: UIEdgeInsets, size: CGSize) {
    gridCollectionView.performBatchUpdates({ [weak self] in
      guard let self = self else { return }
      
      let insets = safeAreaInsets.left + safeAreaInsets.right + CGFloat(Constants.stickyRowsCount) * Constants.stickyRowWidth
      self.gridLayout.updateItemWidth(width: (size.width - insets) / CGFloat(Constants.pageItems))
      
      let contentOffsetX = CGFloat(self.currentIndex) * (self.gridLayout.itemWidth * CGFloat(Constants.pageItems))
      self.gridCollectionView.bounds.origin = CGPoint(x: contentOffsetX, y: self.gridCollectionView.contentOffset.y)
      self.currentContentOffsetX = contentOffsetX
      self.gridLayout.reloadCache()
    }, completion: nil)
  }
  
  // MARK: - UICollectionViewDataSource
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return users.count
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return numberOfRows
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let currentMondayIndex = numberOfRows / 2
    let value = indexPath.row - currentMondayIndex
    
    let calendar = Calendar.utc
    let date = calendar.date(byAdding: .day, value: value, to: currentWeekMonday)!
    
    let gridCell = collectionView.dequeue(type: GridCollectionViewCell.self, indexPath: indexPath)
    let user = users[indexPath.section]
    let userEvents = events[date]?[user.id]
    gridCell.configure(with: userEvents,
      isTop: indexPath.section == 0,
      isRight: indexPath.row == numberOfRows - 1)
    return gridCell
  }
  
  // MARK: - UICollectionViewDelegate
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    didScroll?(scrollView.contentOffset)
    
    let itemWidth = gridLayout.itemWidth
    
    let value = Int((scrollView.contentOffset.x / itemWidth).rounded(.toNearestOrEven)) - numberOfRows / 2
    
    let calendar = Calendar.utc
    let date = calendar.date(byAdding: .day, value: value, to: currentWeekMonday)!
    let components = calendar.dateComponents([.month, .year], from: date)
    let currentMondayComponents = calendar.dateComponents([.year], from: currentWeekMonday)
    var text = "\(dateFormatter.monthSymbols[components.month! - 1])"
    text += (currentMondayComponents.year.orZero) != (components.year.orZero) ? " \(components.year.orZero)" : ""
    onMonthUpdate?(text)
  }
  
  func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    guard scrollView.contentOffset.x != currentContentOffsetX else { return }
    
    targetContentOffset.pointee = scrollView.contentOffset // set acceleration to 0.0
    
    let currentXOffset = scrollView.contentOffset.x
    let itemWidth = gridLayout.itemWidth
    let page = (itemWidth * CGFloat(Constants.pageItems))
    let currentIndex = Int(currentXOffset / page)
    let leftBound = CGFloat(currentIndex) * page
    let rightBound = CGFloat(currentIndex + 1) * page
    
    var offset = CGPoint.zero
    if velocity.x < -0.5 {
      offset = CGPoint(x: (leftBound), y: scrollView.contentOffset.y)
    } else if velocity.x > 0.5 {
      offset = CGPoint(x: (rightBound), y: scrollView.contentOffset.y)
    } else {
      let middle = (rightBound - leftBound) / 2
      
      if abs(currentXOffset) < middle + leftBound {
        offset = CGPoint(x: (leftBound), y: scrollView.contentOffset.y)
      } else {
        offset = CGPoint(x: (rightBound), y: scrollView.contentOffset.y)
      }
    }
    
    let currentMondayIndex = (numberOfRows - 1) / 2
    let value = currentIndex * Constants.pageItems - currentMondayIndex
    let calendar = Calendar.utc
    let date = calendar.date(byAdding: .day, value: value, to: currentWeekMonday)!
    let addValue = currentContentOffsetX > offset.x ? -Constants.pageItems : Constants.pageItems
    let bound = calendar.date(byAdding: .day, value: addValue, to: date)?.utc
    bound == startDate ? getMoreEvents?(.toLeft) : bound == endDate ? getMoreEvents?(.toRight) : nil
    
    self.currentIndex = Int(offset.x / (itemWidth * CGFloat(Constants.pageItems)))
    gridCollectionView.setContentOffset(offset, animated: true)
    currentContentOffsetX = offset.x
    didChangeCurrentOffsetX?(currentContentOffsetX)
  }
}
