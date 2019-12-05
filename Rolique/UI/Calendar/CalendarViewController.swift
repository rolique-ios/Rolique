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
  static var topViewHeight: CGFloat { return 30.0 }
  static var stickyRowWidth: CGFloat { return 60.0 }
  static var currentDayButtonSize: CGFloat { return 25.0 }
  static var currentDayButtonOffset: CGFloat { return 15.0 }
  static var pageItems: Int { return 7 }
  static var stickyRowsCount: Int { return 1 }
  static var weekdayCellHeigth: CGFloat { return 20.0 }
  static var dayCellHeigth: CGFloat { return 40.0 }
  static var shadowRadius: CGFloat { return 3.0 }
  static var shadowHeight: CGFloat { return 3.0 }
}

final class CalendarViewController<T: CalendarViewModel>: ViewController<T> {
  private lazy var emptyView = UIView()
  private lazy var topView = UIView()
  private lazy var monthLabel = UILabel()
  private lazy var currentDayButton = UIButton()
  private lazy var gridLayout = GridCollectionViewFlowLayout()
  private lazy var gridCollectionView = UICollectionView(frame: .zero, collectionViewLayout: gridLayout)
  private lazy var usersLayout: UICollectionViewFlowLayout = {
    let flowLayout = UICollectionViewFlowLayout()
    flowLayout.minimumLineSpacing = 0
    flowLayout.minimumInteritemSpacing = 0
    return flowLayout
  }()
  private lazy var usersCollectionView = UICollectionView(frame: .zero, collectionViewLayout: usersLayout)
  private lazy var daysLayout = DaysCollectionViewFlowLayout()
  private lazy var daysCollectionView = UICollectionView(frame: .zero, collectionViewLayout: daysLayout)
  private lazy var daysCollectionViewContainer = UIView()
  private var usersDataSource: UsersDataSouce?
  private var daysDataSource: DaysDataSouce?
  private var gridDataSource: GridDataSouce?

  override var preferredStatusBarStyle: UIStatusBarStyle {
    if #available(iOS 13.0, *) {
      if self.traitCollection.userInterfaceStyle == .dark {
        return .lightContent
      } else {
        return .darkContent
      }
    } else {
      return .default
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureUI()
    configureConstraints()
    configureCollectionDataSource()
    configureBindings()
  }
  
  private func configureUI() {
    navigationController?.setNavigationBarHidden(true, animated: false)
    
    for view in [view, topView, emptyView] {
      view?.backgroundColor = Colors.secondaryBackgroundColor
    }
    
    monthLabel.textColor = Colors.mainTextColor
    
    currentDayButton.setImage(R.image.calendarToday(), for: .normal)
    currentDayButton.setTitleColor(Colors.mainTextColor, for: .normal)
    currentDayButton.addTarget(self, action: #selector(scrollToToday(sender:)), for: .touchUpInside)
  }
  
  private func configureConstraints() {
    [gridCollectionView, usersCollectionView, topView, daysCollectionViewContainer, emptyView].forEach(self.view.addSubviewAndDisableMaskTranslate)
    [daysCollectionView].forEach(self.daysCollectionViewContainer.addSubviewAndDisableMaskTranslate(_:))
    [monthLabel, currentDayButton].forEach(self.topView.addSubviewAndDisableMaskTranslate)
    
    emptyView.snp.makeConstraints { maker in
      maker.top.left.equalTo(self.view.safeAreaLayoutGuide)
      maker.height.equalTo(Constants.weekdayCellHeigth + Constants.dayCellHeigth + Constants.topViewHeight)
      maker.width.equalTo(Constants.stickyRowWidth)
    }
    
    topView.snp.makeConstraints { maker in
      maker.top.right.equalTo(self.view.safeAreaLayoutGuide)
      maker.left.equalTo(emptyView.snp.right)
      maker.height.equalTo(Constants.topViewHeight)
    }
    
    usersCollectionView.snp.makeConstraints { maker in
      maker.top.equalTo(emptyView.snp.bottom)
      maker.left.bottom.equalTo(self.view.safeAreaLayoutGuide)
      maker.width.equalTo(Constants.stickyRowWidth)
    }
    
    daysCollectionViewContainer.snp.makeConstraints { maker in
      maker.top.equalTo(topView.snp.bottom)
      maker.left.equalTo(usersCollectionView.snp.right)
      maker.right.equalTo(self.view.safeAreaLayoutGuide)
      maker.height.equalTo(Constants.weekdayCellHeigth + Constants.dayCellHeigth)
    }
    
    daysCollectionView.snp.makeConstraints { maker in
      maker.edges.equalToSuperview()
    }
    
    gridCollectionView.snp.makeConstraints { maker in
      maker.top.equalTo(daysCollectionView.snp.bottom)
      maker.left.equalTo(usersCollectionView.snp.right)
      maker.right.bottom.equalTo(self.view.safeAreaLayoutGuide)
    }
    
    currentDayButton.snp.makeConstraints { maker in
      maker.centerY.equalToSuperview()
      maker.right.equalToSuperview().offset(-Constants.currentDayButtonOffset)
      maker.size.equalTo(Constants.currentDayButtonSize)
    }
    
    monthLabel.snp.makeConstraints { maker in
      maker.centerY.left.equalToSuperview()
      maker.right.equalTo(currentDayButton.snp.left)
    }
  }
  
  private func configureCollectionDataSource() {
    let today = Date().utc
    let calendar = Calendar.utc
    let startDate = Date(timeIntervalSince1970: 0)
    let components = calendar.dateComponents([.weekOfYear], from: startDate, to: today)
    let numberOfRows = components.weekOfYear.orZero * Constants.pageItems * 2 + Constants.stickyRowsCount
    
    gridDataSource = GridDataSouce(gridCollectionView: gridCollectionView, gridLayout: gridLayout, users: viewModel.users, startDate: viewModel.startDate, endDate: viewModel.endDate, events: viewModel.events, numberOfRows: numberOfRows)
    gridDataSource?.onMonthUpdate = onMonthUpdate
    usersDataSource = UsersDataSouce(usersCollectionView: usersCollectionView, users: viewModel.users)
    daysDataSource = DaysDataSouce(daysCollectionView: daysCollectionView, daysLayout: daysLayout, numberOfRows: numberOfRows)
  }
  
  private func configureBindings() {
    viewModel.onUsersSuccess = { [weak self] users in
      guard let self = self else { return }
      
      self.gridDataSource?.update(users: users)
      self.usersDataSource?.update(users: users)
    }
    
    viewModel.onEventsSuccess = { [weak self] events in
      guard let self = self else { return }
      
      self.gridDataSource?.update(events: events)
    }
    
    viewModel.onUpdateDates = { [weak self] (startDate, endDate) in
      self?.gridDataSource?.update(startDate: startDate, endDate: endDate)
    }
    
    gridDataSource?.getMoreEvents = { [weak self] direction in
      self?.viewModel.getMoreEvents(direction: direction)
    }
    
    gridDataSource?.didScroll = { [weak self] contentOffset in
      guard let self = self else { return }
      self.usersCollectionView.bounds.origin = CGPoint(x: self.usersCollectionView.contentOffset.x, y: contentOffset.y)
      self.daysCollectionView.bounds.origin = CGPoint(x: contentOffset.x, y: self.daysCollectionView.contentOffset.y)
    }
    
    gridDataSource?.didChangeCurrentOffsetX = { [weak self] contentOffset in
      self?.daysDataSource?.updateCurrentContentOffsetX(with: contentOffset)
    }
    
    usersDataSource?.didScroll = { [weak self] contentOffset in
      guard let self = self else { return }
      self.gridCollectionView.bounds.origin = CGPoint(x: self.gridCollectionView.contentOffset.x, y: contentOffset.y)
    }
    
    daysDataSource?.didScroll = { [weak self] contentOffset in
      guard let self = self else { return }
      self.gridCollectionView.bounds.origin = CGPoint(x: contentOffset.x, y: self.gridCollectionView.contentOffset.y)
    }
    
    daysDataSource?.didChangeCurrentOffsetX = { [weak self] contentOffset in
      self?.gridDataSource?.updateCurrentContentOffsetX(with: contentOffset)
    }
  }
  
  override func performOnceInViewDidAppear() {
    super.performOnceInViewDidAppear()
    gridDataSource?.configureCalendarLayout(with: view.safeAreaInsets, viewWidth: view.frame.width)
    daysDataSource?.configureCalendarLayout(with: view.safeAreaInsets, viewWidth: view.frame.width)
    
    [emptyView, daysCollectionViewContainer].forEach { $0.addShadowWithShadowPath(shadowHeight: Constants.shadowHeight, shadowRadius: Constants.shadowRadius) }
    
    scrollToToday()
  }
  
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    
    coordinator.animate(alongsideTransition: { [weak self] (coordinator) in
      guard let self = self else { return }
      
      self.daysDataSource?.changeItemWidthOnViewWillTransition(with: self.view.safeAreaInsets, size: size)
      self.gridDataSource?.changeItemWidthOnViewWillTransition(with: self.view.safeAreaInsets, size: size)
      self.refreshShadows()
      }, completion: nil)
  }
  
  @objc func scrollToToday(sender: UIButton? = nil) {
    gridDataSource?.scrollToToday(animated: sender != nil)
  }
  
  override func updateColors() {
    super.updateColors()
    
    refreshShadows()
  }
  
  func onMonthUpdate(_ text: String) {
    monthLabel.text = text
  }
  
  private func refreshShadows() {
    for view in [emptyView, daysCollectionViewContainer] {
      view.removeShadowWithShadowPath()
      view.addShadowWithShadowPath(shadowHeight: Constants.shadowHeight, shadowRadius: Constants.shadowRadius)
    }
  }
}
