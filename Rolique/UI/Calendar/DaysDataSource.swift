//
//  DaysDataSource.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 11/4/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit
import Utils
import SnapKit

private struct Constants {
  static var pageItems: Int { return 7 }
  static var weekDays: [String] { return ["M", "T", "W", "T", "F", "S", "S"] }
  static var stickySectionsCount: Int { return 2 }
  static var stickyRowsCount: Int { return 1 }
  static var defaultItemHeight: CGFloat { return 80.0 }
  static var stickyRowWidth: CGFloat { return 60.0 }
}

final class DaysDataSouce: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
  private var daysCollectionView: UICollectionView
  private var daysLayout: DaysCollectionViewFlowLayout
  private let numberOfRows: Int
  private let today = Date().utc
  private let currentWeekMonday = Date().mondayOfWeekUtc
  private var itemWidth = CGFloat.zero
  private var currentContentOffsetX: CGFloat = 0
  private var currentIndex = 0
  var didScroll: ((CGPoint) -> Void)?
  var didChangeCurrentOffsetX: ((CGFloat) -> Void)?
  
  init(daysCollectionView: UICollectionView,
       daysLayout: DaysCollectionViewFlowLayout,
       numberOfRows: Int) {
    self.daysLayout = daysLayout
    self.daysCollectionView = daysCollectionView
    self.numberOfRows = numberOfRows
    
    super.init()
    
    daysCollectionView.showsHorizontalScrollIndicator = false
    daysCollectionView.backgroundColor = Colors.secondaryBackgroundColor
    daysCollectionView.setDelegateAndDatasource(self)
    daysCollectionView.register([WeekdayCollectionViewCell.self,
                                 DayCollectionViewCell.self])
  }
  
  func updateCurrentContentOffsetX(with offset: CGFloat) {
    currentContentOffsetX = offset
    currentIndex = Int(offset / (daysLayout.itemWidth * CGFloat(Constants.pageItems)))
  }
  
  func configureCalendarLayout(with safeAreaInsets: UIEdgeInsets, viewWidth: CGFloat) {
    let insets = safeAreaInsets.left + safeAreaInsets.right + CGFloat(Constants.stickyRowsCount) * Constants.stickyRowWidth
    let defaultItemWidth = (viewWidth - insets) / CGFloat(Constants.pageItems)
    
    daysLayout.configure(itemWidth: defaultItemWidth,
                         itemHeight: Constants.defaultItemHeight)
  }
  
  func changeItemWidthOnViewWillTransition(with safeAreaInsets: UIEdgeInsets, size: CGSize) {
    daysCollectionView.performBatchUpdates({ [weak self] in
      guard let self = self else { return }
      
      let insets = safeAreaInsets.left + safeAreaInsets.right + CGFloat(Constants.stickyRowsCount) * Constants.stickyRowWidth
      self.daysLayout.updateItemWidth(width: (size.width - insets) / CGFloat(Constants.pageItems))
      
      let contentOffsetX = CGFloat(self.currentIndex) * (self.daysLayout.itemWidth * CGFloat(Constants.pageItems))
      self.daysCollectionView.bounds.origin = CGPoint(x: contentOffsetX, y: self.daysCollectionView.contentOffset.y)
      self.currentContentOffsetX = contentOffsetX
      self.daysLayout.reloadCache()
    }, completion: nil)
  }
  
  // MARK: - UICollectionViewDataSource
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return Constants.stickySectionsCount
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return numberOfRows
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let weekDayIndex = indexPath.row % Int(Constants.pageItems)
    
    let currentMondayIndex = numberOfRows / 2
    let value = indexPath.row - currentMondayIndex
    
    let calendar = Calendar.utc
    let date = calendar.date(byAdding: .day, value: value, to: currentWeekMonday)!
    let isPastDay = date < today
    let isToday = today == date
    
    switch indexPath {
    case (let indexPath) where indexPath.section < Constants.stickySectionsCount - 1:
      let weekdayCell = collectionView.dequeue(type: WeekdayCollectionViewCell.self, indexPath: indexPath)
      weekdayCell.configure(with: Constants.weekDays[weekDayIndex], isPastDay: isPastDay, isToday: isToday)
      return weekdayCell
    default:
      let dayCell = collectionView.dequeue(type: DayCollectionViewCell.self, indexPath: indexPath)
      let component = calendar.dateComponents([.day], from: date)
      dayCell.configure(with: "\(component.day.orZero)", isPastDay: isPastDay, isToday: isToday)
      return dayCell
    }
  }
  
  // MARK: - UICollectionViewDelegate
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    didScroll?(scrollView.contentOffset)
  }
  
  func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    guard scrollView.contentOffset.x != currentContentOffsetX else { return }
    
    targetContentOffset.pointee = scrollView.contentOffset // set acceleration to 0.0
    
    let currentXOffset = scrollView.contentOffset.x
    let itemWidth = daysLayout.itemWidth
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
      offset = abs(currentXOffset) < middle + leftBound ? CGPoint(x: (leftBound), y: scrollView.contentOffset.y) : CGPoint(x: (rightBound), y: scrollView.contentOffset.y)
    }
    
    self.currentIndex = Int(offset.x / (itemWidth * CGFloat(Constants.pageItems)))
    daysCollectionView.setContentOffset(offset, animated: true)
    currentContentOffsetX = offset.x
    didChangeCurrentOffsetX?(currentContentOffsetX)
  }
}

