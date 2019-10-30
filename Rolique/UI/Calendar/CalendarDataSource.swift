//
//  CalendarDataSource.swift
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
  static var weekDays: [String] { return ["M", "T", "W", "T", "F", "S", "S"] }
  static var stickySectionsCount: Int { return 2 }
  static var stickyRowsCount: Int { return 1 }
  static var defaultItemHeight: CGFloat { return 80 }
  static var weekdayCellHeigth: CGFloat { return 20.0 }
  static var dayCellHeigth: CGFloat { return 40.0 }
  static var stickyRowWidth: CGFloat { return 60.0 }
}

enum Direction {
  case toLeft, toRight
}

final class CalendarDataSouce: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
  private var calendarLayout: CalendarCollectionViewFlowLayout
  private var calendarCollectionView: UICollectionView
  private var users: [User]
  private var startDate: Date
  private var endDate: Date
  private var events: [Date: [String: [RecordType]]]
  // devisible by 7 days + 1
  private var numberOfRows = 0
  private var contentOffsetX: CGFloat = 0
  private var currentIndex = 0
  private let currentWeekMonday = Date().mondayOfWeek.utc
  private let dateFormatter = DateFormatter()
  private let today = Date().utc
  var onMonthUpdate: ((String) -> Void)?
  var getMoreEvents: ((Direction) -> Void)?
  
  init(calendarCollectionView: UICollectionView, calendarLayout: CalendarCollectionViewFlowLayout, users: [User], startDate: Date, endDate: Date, events: [Date: [String: [RecordType]]]) {
    self.calendarCollectionView = calendarCollectionView
    self.calendarLayout = calendarLayout
    self.users = users
    self.startDate = startDate
    self.endDate = endDate
    self.events = events
    let calendar = Calendar.current
    let startDate = Date(timeIntervalSince1970: 0)
    let components = calendar.dateComponents([.weekOfYear], from: startDate, to: today)
    numberOfRows = components.weekOfYear.orZero * Constants.pageItems * 2 + Constants.stickyRowsCount
    
    super.init()
    
    calendarCollectionView.scrollIndicatorInsets = UIEdgeInsets(top: Constants.weekdayCellHeigth + Constants.dayCellHeigth, left: 0, bottom: 0, right: 0)
    calendarCollectionView.showsHorizontalScrollIndicator = false
    calendarCollectionView.backgroundColor = Colors.secondaryBackgroundColor
    calendarCollectionView.isDirectionalLockEnabled = true
    calendarCollectionView.setDelegateAndDatasource(self)
    calendarCollectionView.register([WeekdayCollectionViewCell.self,
                                     DayCollectionViewCell.self,
                                     ColleagueCollectionViewCell.self,
                                     GridCollectionViewCell.self,
                                     UICollectionViewCell.self])
  }
  
  func configureCalendarLayout(with safeAreaInsets: UIEdgeInsets, viewWidth: CGFloat) {
    let insets = safeAreaInsets.left + safeAreaInsets.right + CGFloat(Constants.stickyRowsCount) * Constants.stickyRowWidth
    let defaultItemWidth = (viewWidth - insets) / CGFloat(Constants.pageItems)
    
    calendarLayout.configure(stickySectionsCount: Constants.stickySectionsCount,
                             stickyRowsCount: Constants.stickyRowsCount,
                             defaultItemWidth: defaultItemWidth,
                             defaultItemHeight: Constants.defaultItemHeight)
  }
  
  func update(users: [User]) {
    self.users = users
    self.calendarCollectionView.reloadData()
  }
  
  func update(events: [Date: [String: [RecordType]]]) {
    self.events = events
    self.calendarCollectionView.reloadData()
  }
  
  func update(startDate: Date, endDate: Date) {
    self.startDate = startDate
    self.endDate = endDate
  }
  
  func scrollToToday(animated: Bool) {
    let hulfOfContentSize = calendarLayout.itemWidth * CGFloat(numberOfRows) / 2
    let itemWidth = calendarLayout.itemWidth
    let page = (itemWidth * CGFloat(Constants.pageItems))
    let currentIndex = Int(hulfOfContentSize / page)
    let leftBound = CGFloat(currentIndex) * page
    self.currentIndex = currentIndex
    
    calendarCollectionView.setContentOffset(CGPoint(x: leftBound, y: calendarCollectionView.contentOffset.y), animated: animated)
    self.contentOffsetX = leftBound
  }
  
  func changeItemWidthOnViewWillTransition(with safeAreaInsets: UIEdgeInsets, size: CGSize) {
    calendarCollectionView.performBatchUpdates({ [weak self] in
      guard let self = self else { return }
      
      let insets = safeAreaInsets.left + safeAreaInsets.right + CGFloat(Constants.stickyRowsCount) * Constants.stickyRowWidth
      self.calendarLayout.updateItemWidth(width: (size.width - insets) / CGFloat(Constants.pageItems))
      
      let contentOffsetX = CGFloat(self.currentIndex) * (self.calendarLayout.itemWidth * CGFloat(Constants.pageItems))
      self.calendarCollectionView.setContentOffset(CGPoint(x: contentOffsetX,
                                                       y: self.calendarCollectionView.contentOffset.y), animated: false)
      self.contentOffsetX = contentOffsetX
    }, completion: { _ in
      self.calendarCollectionView.reloadData()
    })
  }
  
  // MARK: - UICollectionViewDataSource
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return users.count + Constants.stickySectionsCount
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return numberOfRows
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let weekDayIndex = (indexPath.row - 1) % Int(Constants.pageItems)
    
    let currentMondayIndex = numberOfRows / 2
    let value = (indexPath.row - 1) - currentMondayIndex
    
    let calendar = Calendar.current
    let date = calendar.date(byAdding: .day, value: value, to: currentWeekMonday)!.utc
    let isPastDay = date < today
    let isToday = today == date
    
    switch (indexPath, weekDayIndex) {
    case let(indexPath, _) where indexPath.section < Constants.stickySectionsCount && indexPath.row < Constants.stickyRowsCount:
      let cell = collectionView.dequeue(type: UICollectionViewCell.self, indexPath: indexPath)
      cell.backgroundColor = Colors.secondaryBackgroundColor
      return cell
    case let(indexPath, weekDayIndex) where indexPath.section < Constants.stickySectionsCount - 1 && weekDayIndex > -1:
      let weekdayCell = collectionView.dequeue(type: WeekdayCollectionViewCell.self, indexPath: indexPath)
      weekdayCell.configure(with: Constants.weekDays[weekDayIndex], isPastDay: isPastDay, isToday: isToday)
      return weekdayCell
    case let(indexPath, _) where indexPath.section == Constants.stickySectionsCount - 1 && indexPath.row > Constants.stickyRowsCount - 1:
      let dayCell = collectionView.dequeue(type: DayCollectionViewCell.self, indexPath: indexPath)
      let component = calendar.dateComponents([.day], from: date)
      dayCell.configure(with: "\(component.day.orZero)", isPastDay: isPastDay, isToday: isToday)
      return dayCell
    case let(indexPath, _) where indexPath.row < Constants.stickyRowsCount:
      let colleagueCell = collectionView.dequeue(type: ColleagueCollectionViewCell.self, indexPath: indexPath)
      let user = users[indexPath.section - Constants.stickySectionsCount]
      let firstName = user.slackProfile.realName.split(separator: " ")
      colleagueCell.configure(with: String(firstName[0]), image: user.optimalImage)
      return colleagueCell
    default:
      let gridCell = collectionView.dequeue(type: GridCollectionViewCell.self, indexPath: indexPath)
      let user = users[indexPath.section - Constants.stickySectionsCount]
      let userEvents = events[date]?[user.id]
      gridCell.configure(with: userEvents,
        isTop: indexPath.section - Constants.stickySectionsCount == 0,
        isRight: indexPath.row == numberOfRows - 1)
      return gridCell
    }
  }
  
  // MARK: - UICollectionViewDelegate
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let itemWidth = calendarLayout.itemWidth
    
    let value = Int((scrollView.contentOffset.x / itemWidth).rounded(.toNearestOrEven)) - numberOfRows / 2
    
    let calendar = Calendar.current
    let date = calendar.date(byAdding: .day, value: value, to: currentWeekMonday)!
    let components = calendar.dateComponents([.month, .year], from: date)
    let currentMondayComponents = calendar.dateComponents([.year], from: currentWeekMonday)
    var text = "\(dateFormatter.monthSymbols[components.month! - 1])"
    text += (currentMondayComponents.year.orZero) != (components.year.orZero) ? " \(components.year.orZero)" : ""
    onMonthUpdate?(text)
  }
  
  func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    guard scrollView.contentOffset.x != contentOffsetX else { return }
    
    targetContentOffset.pointee = scrollView.contentOffset // set acceleration to 0.0
    
    let currentXOffset = scrollView.contentOffset.x
    let itemWidth = calendarLayout.itemWidth
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
    let calendar = Calendar.current
    let date = calendar.date(byAdding: .day, value: value, to: currentWeekMonday)!
    if contentOffsetX > offset.x {
      let bound = calendar.date(byAdding: .day, value: -Constants.pageItems, to: date)?.utc
      if bound == startDate {
        getMoreEvents?(.toLeft)
      }
    } else {
      let bound = calendar.date(byAdding: .day, value: Constants.pageItems, to: date)?.utc
      if bound == endDate {
        getMoreEvents?(.toRight)
      }
    }
    
    self.currentIndex = Int(offset.x / (itemWidth * CGFloat(Constants.pageItems)))
    self.calendarCollectionView.setContentOffset(offset, animated: true)
    self.contentOffsetX = offset.x
  }
}
