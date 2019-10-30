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
}

final class CalendarViewController<T: CalendarViewModel>: ViewController<T> {
  private lazy var topView = UIView()
  private lazy var monthLabel = UILabel()
  private lazy var currentDayButton = UIButton()
  private lazy var calendarLayout = CalendarCollectionViewFlowLayout()
  private lazy var calendarCollectionView = UICollectionView(frame: .zero, collectionViewLayout: calendarLayout)
  private var dataSource: CalendarDataSouce?

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
    
    view.backgroundColor = Colors.secondaryBackgroundColor
    
    topView.backgroundColor = Colors.secondaryBackgroundColor
    
    monthLabel.textColor = Colors.mainTextColor
    
    currentDayButton.setImage(Images.Calendar.calendarToday, for: .normal)
    currentDayButton.setTitleColor(Colors.mainTextColor, for: .normal)
    currentDayButton.addTarget(self, action: #selector(scrollToToday(sender:)), for: .touchUpInside)
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
      maker.right.equalToSuperview().offset(-Constants.currentDayButtonOffset)
      maker.size.equalTo(Constants.currentDayButtonSize)
    }
    
    monthLabel.snp.makeConstraints { maker in
      maker.centerY.equalToSuperview()
      maker.left.equalToSuperview().offset(Constants.stickyRowWidth)
      maker.right.equalTo(currentDayButton.snp.left)
    }
  }
  
  private func configureCollectionDataSource() {
    dataSource = CalendarDataSouce(calendarCollectionView: calendarCollectionView, calendarLayout: calendarLayout, users: viewModel.users, startDate: viewModel.startDate, endDate: viewModel.endDate, events: viewModel.events)
    dataSource?.onMonthUpdate = onMonthUpdate
  }
  
  private func configureBindings() {
    viewModel.onUsersSuccess = { [weak self] users in
      guard let self = self else { return }
      
      self.dataSource?.update(users: users)
    }
    
    viewModel.onEventsSuccess = { [weak self] events in
      guard let self = self else { return }
      
      self.dataSource?.update(events: events)
    }
    
    viewModel.onError = { error in
      print(error)
    }
    
    viewModel.onUpdateDates = { [weak self] (startDate, endDate) in
      self?.dataSource?.update(startDate: startDate, endDate: endDate)
    }
    
    dataSource?.getMoreEvents = { [weak self] direction in
      self?.viewModel.getMoreEvents(direction: direction)
    }
  }
  
  override func performOnceInViewDidAppear() {
    super.performOnceInViewDidAppear()
    dataSource?.configureCalendarLayout(with: view.safeAreaInsets, viewWidth: view.frame.width)
    
    scrollToToday()
  }
  
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    
    coordinator.animate(alongsideTransition: { [weak self] (coordinator) in
      guard let self = self else { return }
      
      self.dataSource?.changeItemWidthOnViewWillTransition(with: self.view.safeAreaInsets, size: size)
      }, completion: nil)
  }
  
  @objc func scrollToToday(sender: UIButton? = nil) {
    dataSource?.scrollToToday(animated: sender != nil)
  }
  
  override func updateColors() {
    super.updateColors()
    calendarCollectionView.reloadData()
  }

  func onMonthUpdate(_ text: String) {
    monthLabel.text = text
  }
}
