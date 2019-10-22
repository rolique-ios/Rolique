//
//  CalendarViewController.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 10/1/19.
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
  static var topViewHeight: CGFloat { return 25.0 }
  static var stickySectionHeight: CGFloat { return 40.0 }
  static var stickyRowWidth: CGFloat { return 60.0 }
  static var currentDayButtonOffset: CGFloat { return -15 }
}

final class CalendarViewController<T: CalendarViewModel>: ViewController<T>, UICollectionViewDataSource, UICollectionViewDelegate {
  private lazy var topView = UIView()
  private lazy var monthLabel = UILabel()
  private lazy var currentDayButton = UIButton()
  private lazy var calendarLayout = CalendarCollectionViewFlowLayout()
  private lazy var calendarCollectionView = UICollectionView(frame: .zero, collectionViewLayout: calendarLayout)
  
  private let numberOfSections = 100
  // devisible by 7 days + 1
  private var numberOfRows = 161 + 1
  
  private var contentOffsetX: CGFloat = 0
  private var currentIndex = 0
  private let currentWeekMonday = Date().mondayOfWeek.normalized
  private let dateFormatter = DateFormatter()
  private let today = Date().normalized
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .default
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureUI()
    configureConstraints()
    
    let calendar = Calendar.current
    let todayDate = Date(timeIntervalSinceNow: 0)
    let startDate = Date(timeIntervalSince1970: 0)
    let components = calendar.dateComponents([.weekOfYear], from: startDate, to: todayDate)
    numberOfRows = (components.weekOfYear ?? 0) * Constants.pageItems * 2 + Constants.stickyRowsCount
  }
  
  private func configureUI() {
    navigationController?.setNavigationBarHidden(true, animated: false)
    
    currentDayButton.setTitle("O", for: .normal)
    currentDayButton.setTitleColor(.black, for: .normal)
    currentDayButton.addTarget(self, action: #selector(scrollToToday(sender:)), for: .touchUpInside)
    
    calendarCollectionView.isDirectionalLockEnabled = true
    calendarCollectionView.delegate = self
    calendarCollectionView.dataSource = self
    calendarCollectionView.backgroundColor = .white
    calendarCollectionView.register([WeekdayCollectionViewCell.self,
                                     DayCollectionViewCell.self,
                                     ColleagueCollectionViewCell.self,
                                     GridCollectionViewCell.self,
                                     UICollectionViewCell.self])
    
    calendarLayout.minimumLineSpacing = 0.0
    calendarLayout.minimumInteritemSpacing = 0.0
  }
  
  private func configureConstraints() {
    [topView, calendarCollectionView].forEach(self.view.addSubviewAndDisableMaskTranslate)
    [monthLabel, currentDayButton].forEach(self.topView.addSubviewAndDisableMaskTranslate)
    
    topView.snp.makeConstraints { maker in
      maker.top.left.right.equalTo(self.view.safeAreaLayoutGuide)
      maker.height.equalTo(Constants.topViewHeight)
    }
    
    calendarCollectionView.snp.makeConstraints { maker in
      maker.top.equalTo(topView.snp.bottom)
      maker.left.right.bottom.equalTo(self.view.safeAreaLayoutGuide)
    }
    
    currentDayButton.snp.makeConstraints { maker in
      maker.centerY.equalToSuperview()
      maker.right.equalToSuperview().offset(Constants.currentDayButtonOffset)
      maker.height.width.equalTo(Constants.topViewHeight)
    }
    
    monthLabel.snp.makeConstraints { maker in
      maker.centerY.equalToSuperview()
      maker.left.equalToSuperview().offset(Constants.stickyRowWidth)
      maker.right.equalTo(currentDayButton.snp.left)
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    let insets = view.safeAreaInsets.left + view.safeAreaInsets.right + CGFloat(Constants.stickyRowsCount) * Constants.stickyRowWidth
    let defaultItemWidth = (view.frame.width - insets) / CGFloat(Constants.pageItems)
    
    calendarLayout.configure(with: Constants.stickySectionsCount, stickyRowsCount: Constants.stickyRowsCount, defaultItemWidth: defaultItemWidth, defaultItemHeight: Constants.defaultItemHeight)
    
    scrollToToday()
  }
  
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    
    coordinator.animate(alongsideTransition: { [weak self] (coordinator) in
      guard let self = self else { return }
      
      let safeArea = self.view.safeAreaInsets
      let insets = safeArea.left + safeArea.right + CGFloat(Constants.stickyRowsCount) * self.calendarLayout.stickyRowWidth
      self.calendarLayout.updateItemWidth(width: (size.width - insets) / CGFloat(Constants.pageItems))
      }, completion: { [weak self] _ in
        guard let self = self else { return }
        self.calendarCollectionView.setContentOffset(CGPoint(x: CGFloat(self.currentIndex) * (self.calendarLayout.itemWidth * CGFloat(Constants.pageItems)),
                                                         y: self.calendarCollectionView.contentOffset.y), animated: false)
    })
  }
  
  @objc func scrollToToday(sender: UIButton? = nil) {
    let hulfOfContentSize = calendarLayout.itemWidth * CGFloat(numberOfRows) / 2
    let itemWidth = calendarLayout.itemWidth
    let page = (itemWidth * CGFloat(Constants.pageItems))
    let currentIndex = Int(hulfOfContentSize / page)
    let leftBound = CGFloat(currentIndex) * page
    self.currentIndex = currentIndex
    
    calendarCollectionView.setContentOffset(CGPoint(x: leftBound, y: calendarCollectionView.contentOffset.y), animated: sender != nil)
  }
  
  // MARK: - UICollectionViewDataSource
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return numberOfSections
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return numberOfRows
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let weekDayIndex = (indexPath.row - 1) % Int(Constants.pageItems)
    
    let currentMondayIndex = numberOfRows / 2
    let value = (indexPath.row - 1) - currentMondayIndex
    
    let calendar = Calendar.current
    let date = calendar.date(byAdding: .day, value: value, to: currentWeekMonday)!
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
      dayCell.configure(with: "\(component.day ?? 0)", isPastDay: isPastDay, isToday: isToday)
      return dayCell
    case let(indexPath, _) where indexPath.row < Constants.stickyRowsCount:
      let colleagueCell = collectionView.dequeue(type: ColleagueCollectionViewCell.self, indexPath: indexPath)
      colleagueCell.configure(with: "lol", image: nil)
      return colleagueCell
    default:
      let gridCell = collectionView.dequeue(type: GridCollectionViewCell.self, indexPath: indexPath)
      gridCell.configure(with: "\(indexPath.section) \(indexPath.row)",
        isTop: indexPath.section - Constants.stickySectionsCount == 0,
        isRight: indexPath.row == numberOfRows - 1)
      return gridCell
    }
  }
  
  // MARK: - UICollectionViewDelegate
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let currentXOffset = scrollView.contentOffset.x
    let itemWidth = calendarLayout.itemWidth
    
    let value = Int((currentXOffset / itemWidth).rounded(.toNearestOrEven)) - numberOfRows / 2
    
    let calendar = Calendar.current
    let date = calendar.date(byAdding: .day, value: value, to: currentWeekMonday)!
    let components = calendar.dateComponents([.month, .year], from: date)
    let currentMondayComponents = calendar.dateComponents([.year], from: currentWeekMonday)
    var text = "\(dateFormatter.monthSymbols[components.month! - 1])"
    text += (currentMondayComponents.year ?? 0) != (components.year ?? 0) ? " \(components.year ?? 0)" : ""
    monthLabel.text = text
  }
  
  func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    guard scrollView.contentOffset.x != contentOffsetX else { return }
    
    contentOffsetX = scrollView.contentOffset.x
    
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
    
    self.currentIndex = Int(offset.x / (itemWidth * CGFloat(Constants.pageItems)))
    self.calendarCollectionView.setContentOffset(offset, animated: true)
  }
}
