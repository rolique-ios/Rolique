//
//  MeetingRoomsViewController.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 11/8/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit
import Utils
import SnapKit

private struct Constants {
  static var timeTableViewWidth: CGFloat { return 60.0 }
  static var meetingViewHeight: CGFloat { return 30.0 }
  static var cellHeight: CGFloat { return 30.0 }
  static var backButtonHeight: CGFloat { return 22.0 }
  static var backButtonWidth: CGFloat { return 17.0 }
  static var buttonsContainerHeight: CGFloat { return 40.0 }
  static var defaultOffset: CGFloat { return 10.0 }
  static var headerExpandedHeight: CGFloat { return 240 }
  static var headerCollapsedHeight: CGFloat { return 40 }
}

private enum MeetingRoom: String, CaseIterable {
  case conference = "Conf"
  case first = "MR1"
  case second = "MR2"
}

enum CalendarCollectionViewState { case expanded, collapsed }

final class MeetingRoomsViewController<T: MeetingRoomsViewModelImpl>: ViewController<T>,
  UICollectionViewDelegate,
  UICollectionViewDelegateFlowLayout,
  UICollectionViewDataSource,
  UINavigationControllerDelegate,
  CalendarCollectionViewDelegate {
  private lazy var timeTableView = UITableView()
  private lazy var meetingRooms = MeetingRoom.allCases
  private lazy var meetingRoomsScrollViewContainer = UIView()
  private lazy var meetingRoomsScrollView = UIScrollView()
  private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout().apply({ $0.scrollDirection = .horizontal }))
  private lazy var timeDataSource: TimeDataSource = TimeDataSource(tableView: timeTableView)
  private lazy var buttonsContainerView = UIView()
  private lazy var backButton = UIButton()
  private lazy var editButton = UIButton()
  private lazy var monthNameLabel = UILabel()
  private lazy var expandButton = UIButton()
  private lazy var calendarCollectionView = CalendarCollectionView()
  private var isEdit = false
  private var currentPage = 0
  private var tableViewNumberOfRows = 0
  private var calendarCollectionViewHeightConstraint: Constraint?
  
  private var state: CalendarCollectionViewState = .collapsed {
    didSet {
      handleStateDidChange()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureUI()
    configureConstraints()
    configureDataSources()
  }
  
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
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    navigationController?.setNavigationBarHidden(true, animated: true)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    navigationController?.setNavigationBarHidden(false, animated: true)
  }
  
  override func performOnceInViewDidAppear() {
    configureMeetinRoomsScrollView()
  }
  
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    
    coordinator.animate(alongsideTransition: { [weak self] _ in
      guard let self = self else { return }
      
      self.calendarCollectionView.reloadData()
      self.meetingRoomsScrollView.subviews.forEach { $0.removeFromSuperview() }
      self.configureMeetinRoomsScrollView()
      self.meetingRoomsScrollView.bounds.origin.x = CGFloat(self.currentPage) * self.meetingRoomsScrollView.bounds.width
      self.collectionView.performBatchUpdates({ [weak self] in
        guard let self = self else { return }
        self.collectionView.bounds.origin.x = CGFloat(self.currentPage) * self.collectionView.bounds.width
      }, completion: nil)
      }, completion: nil)
  }
  
  private func configureUI() {
    view.backgroundColor = Colors.mainBackgroundColor
    
    collectionView.backgroundColor = Colors.mainBackgroundColor
    collectionView.isPagingEnabled = true
    collectionView.setDelegateAndDatasource(self)
    collectionView.register([MeetingRoomCollectionViewCell.self])
    
    backButton.setTitleColor(Colors.mainTextColor, for: .normal)
    backButton.addTarget(self, action: #selector(didSelectBackButton), for: .touchUpInside)
    let image = Images.MeetingRoom.backArrow.withRenderingMode(.alwaysTemplate)
    backButton.imageView?.tintColor = Colors.imageColor
    backButton.setImage(image, for: .normal)
    
    editButton.setTitleColor(Colors.mainTextColor, for: .normal)
    editButton.setTitle(Strings.MeetingRooms.edit, for: .normal)
    editButton.addTarget(self, action: #selector(didSelectEditButton), for: .touchUpInside)
    
    expandButton.setImage(Images.MeetingRoom.expand, for: .normal)
    expandButton.addTarget(self, action: #selector(didSelectExpandButton), for: .touchUpInside)
    
    meetingRoomsScrollViewContainer.backgroundColor = Colors.Colleagues.lightBlue
    meetingRoomsScrollView.isPagingEnabled = true
    meetingRoomsScrollView.showsHorizontalScrollIndicator = false
    
    calendarCollectionView.onSelectDate = { [weak self] date in
      guard let self = self else { return }
      
    }
    calendarCollectionView.delegate = self
    let calendar = Calendar.current
    let startDate = Date().previousMonth(with: calendar).startOfMonth(with: calendar)
    let endDate = Date().nextMonth(with: calendar).endOfMonth(with: calendar)
    calendarCollectionView.configure(startDate: startDate, endDate: endDate)
    monthNameLabel.text = Date().monthName()
  }
  
  private func configureConstraints() {
    [buttonsContainerView,
     calendarCollectionView,
     meetingRoomsScrollViewContainer,
     timeTableView,
     collectionView].forEach(self.view.addSubview(_:))
    
    buttonsContainerView.snp.makeConstraints { maker in
      maker.left.top.right.equalTo(self.view.safeAreaLayoutGuide)
      maker.height.equalTo(Constants.buttonsContainerHeight)
    }
    
    calendarCollectionView.snp.makeConstraints { maker in
      maker.top.equalTo(buttonsContainerView.snp.bottom)
      maker.left.equalTo(self.view.safeAreaLayoutGuide)
      calendarCollectionViewHeightConstraint = maker.height.equalTo(Constants.headerCollapsedHeight).constraint
      maker.right.equalTo(self.view.safeAreaLayoutGuide)
    }
    
    meetingRoomsScrollViewContainer.snp.makeConstraints { maker in
      maker.top.equalTo(calendarCollectionView.snp.bottom)
      maker.left.right.equalTo(self.view.safeAreaLayoutGuide)
      maker.height.equalTo(30)
    }
    
    timeTableView.snp.makeConstraints { maker in
      maker.top.equalTo(meetingRoomsScrollViewContainer.snp.bottom)
      maker.left.bottom.equalTo(self.view.safeAreaLayoutGuide)
      maker.width.equalTo(Constants.timeTableViewWidth)
    }
    
    collectionView.snp.makeConstraints { maker in
      maker.top.equalTo(meetingRoomsScrollViewContainer.snp.bottom)
      maker.right.bottom.equalTo(self.view.safeAreaLayoutGuide)
      maker.left.equalTo(timeTableView.snp.right)
    }
    
    [backButton, editButton, monthNameLabel, expandButton].forEach(buttonsContainerView.addSubview(_:))
    backButton.snp.makeConstraints { maker in
      maker.left.equalToSuperview().offset(Constants.defaultOffset)
      maker.centerY.equalToSuperview()
      maker.height.equalTo(Constants.backButtonHeight)
      maker.width.equalTo(Constants.backButtonWidth)
    }
    
    editButton.snp.makeConstraints { maker in
      maker.right.equalToSuperview().offset(-Constants.defaultOffset)
      maker.top.bottom.equalToSuperview()
    }
    
    monthNameLabel.snp.makeConstraints { maker in
      maker.center.equalToSuperview()
    }
    
    expandButton.snp.makeConstraints { maker in
      maker.left.equalTo(monthNameLabel.snp.right)
      maker.centerY.equalToSuperview()
      maker.size.equalTo(24)
    }
    
    [meetingRoomsScrollView].forEach(meetingRoomsScrollViewContainer.addSubview(_:))
    
    meetingRoomsScrollView.snp.makeConstraints { maker in
      maker.edges.equalToSuperview()
    }
  }
  
  private func configureDataSources() {
    let date = Date().utc
    var dataSource = [Date]()
    for value in stride(from: 9, to: 21.5, by: 0.5) {
      let date = Date(timeInterval: TimeInterval(value * TimeInterval.hour), since: date)
      dataSource.append(date)
    }
    tableViewNumberOfRows = dataSource.count - 1
    timeDataSource.updateDataSource(with: dataSource)
  }
  
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    let page = floor(scrollView.contentOffset.x / scrollView.frame.width)
    currentPage = Int(page)
  }
  
  private func configureMeetinRoomsScrollView() {
    meetingRoomsScrollView.contentSize = CGSize(
      width: meetingRoomsScrollView.frame.width * CGFloat(meetingRooms.count),
      height: meetingRoomsScrollView.frame.height
    )
    
    for index in 0..<meetingRooms.count {
      let meetingView = MeetingRoomView()
      meetingView.configure(with: meetingRooms[index].rawValue)
      
      meetingView.frame = CGRect(
        x: meetingRoomsScrollView.frame.width * CGFloat(index),
        y: 0,
        width: meetingRoomsScrollView.frame.width,
        height: meetingRoomsScrollView.frame.height
      )
      
      meetingRoomsScrollView.addSubview(meetingView)
    }
  }
  
  @objc func didSelectEditButton() {
    isEdit.toggle()
    
    UIView.transition(with: editButton, duration: 0.2, options: .transitionFlipFromLeft, animations: { [weak self] in
      self?.editButton.setTitle(self?.isEdit ?? false ? Strings.MeetingRooms.done : Strings.MeetingRooms.edit, for: .normal)
    }, completion: nil)
    
    if let cell = collectionView.cellForItem(at: IndexPath(item: currentPage, section: 0)) as? MeetingRoomCollectionViewCell {
      isEdit ? cell.edit() : cell.done()
    }
  }
  
  @objc func didSelectExpandButton() {
    toggleState()
  }
  
  @objc func didSelectBackButton() {
    navigationController?.popViewController(animated: true)
  }
  
  private func handleStateDidChange() {
    setExpandButtonImageForState(state, animated: true)
    monthNameLabel.text = (calendarCollectionView.calendarState?.anchor ?? Date()).monthName()
    updateHeaderHeight(state, animated: true)
    calendarCollectionView.setState(state)
  }
  
  private func scrollToToday() {
    calendarCollectionView.scrollToToday()
  }
  
  private func setExpandButtonImageForState(_ state: CalendarCollectionViewState, animated: Bool) {
    if animated {
      let animator = UIViewPropertyAnimator(duration: 0.25, curve: UIView.AnimationCurve.easeInOut) {
        switch state {
        case .expanded: self.expandButton.transform = CGAffineTransform(rotationAngle: .pi)
        case .collapsed: self.expandButton.transform = .identity
        }
      }
      animator.startAnimation()
    } else {
      switch state {
      case .expanded: expandButton.transform = CGAffineTransform(rotationAngle: .pi)
      case .collapsed: expandButton.transform = .identity
      }
    }
  }
  
  private func toggleState() {
    switch state {
    case .expanded: state = .collapsed
    case .collapsed: state = .expanded
    }
  }
  
  private func updateHeaderHeight(_ state: CalendarCollectionViewState, animated: Bool) {
    switch state {
    case .expanded:
      calendarCollectionViewHeightConstraint?.update(offset: Constants.headerExpandedHeight)
    case .collapsed:
      calendarCollectionViewHeightConstraint?.update(offset: Constants.headerCollapsedHeight)
    }
    
    collectionView.collectionViewLayout.invalidateLayout()
    if animated {
      let animator = UIViewPropertyAnimator(duration: 0.25, curve: UIView.AnimationCurve.easeInOut, animations: { [weak self] in
        self?.view.layoutIfNeeded()
      })
      animator.startAnimation()
    } else {
      view.layoutIfNeeded()
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return meetingRooms.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeue(type: MeetingRoomCollectionViewCell.self, indexPath: indexPath)
    cell.configure(with: tableViewNumberOfRows, contentOffsetY: timeTableView.contentOffset.y)
    cell.tableViewDidScroll = { [weak self] contentOffset in
      self?.timeTableView.setContentOffset(CGPoint(x: 0, y: contentOffset.y), animated: false)
    }
    
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    (cell as! MeetingRoomCollectionViewCell).configure(with: tableViewNumberOfRows, contentOffsetY: timeTableView.contentOffset.y)
  }
  
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
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let offset = scrollView.contentOffset.x * meetingRoomsScrollView.contentSize.width / scrollView.contentSize.width
    self.meetingRoomsScrollView.setContentOffset(CGPoint(x: offset, y: 0), animated: false)
  }
  
  func calendarCollectionView(_ calendarCollectionView: CalendarCollectionView, didScrollToMonthWithName monthName: String?) {
    monthNameLabel.text = monthName
  }
}
