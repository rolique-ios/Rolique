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
import IgyToast

private struct Constants {
  static var timeTableViewWidth: CGFloat { return 60.0 }
  static var meetingViewHeight: CGFloat { return 30.0 }
  static var cellHeight: CGFloat { return 40.0 }
  static var backButtonHeight: CGFloat { return 22.0 }
  static var backButtonWidth: CGFloat { return 17.0 }
  static var buttonsContainerHeight: CGFloat { return 40.0 }
  static var defaultOffset: CGFloat { return 10.0 }
  static var headerExpandedHeight: CGFloat { return 240 }
  static var headerCollapsedHeight: CGFloat { return 40 }
  static var meetingContainerViewHeight: CGFloat { return 30.0 }
  static var expandButtonSize: CGFloat { return 24.0 }
}

enum CalendarCollectionViewState { case expanded, collapsed }

final class MeetingRoomsViewController<T: MeetingRoomsViewModelImpl>: ViewController<T>,
  UIScrollViewDelegate,
  CalendarCollectionViewDelegate {
  private lazy var timeTableView = UITableView()
  private lazy var meetingRooms = MeetingRoom.allCases
  private lazy var meetingRoomsScrollViewContainer = UIView()
  private lazy var meetingRoomsScrollView = UIScrollView()
  private lazy var meetingRoomViews = [MeetingRoomView(), MeetingRoomView(), MeetingRoomView()]
  private lazy var meetingRoomsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout().apply { $0.scrollDirection = .horizontal })
  private lazy var meetingRoomsCollectionViewDataSource = MeetingRoomsCollectionViewDataSource(collectionView: meetingRoomsCollectionView, timeTableView: timeTableView)
  private lazy var timeDataSource: TimeDataSource = TimeDataSource(tableView: timeTableView)
  private lazy var buttonsContainerView = UIView()
  private lazy var backButton = UIButton()
  private lazy var editButton = UIButton()
  private lazy var monthNameLabel = UILabel()
  private lazy var expandButton = UIButton()
  private lazy var calendarCollectionView = CalendarCollectionView()
  private var isEdit = false
  private var currentPage = 0
  private var calendarCollectionViewHeightConstraint: Constraint?
  private var currentTimeInterspace: TimeInterspace?
  
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
    configureBindings()
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
    
    viewModel.orientationDidChanged(UIDevice.current.orientation, collectionViewWidth: meetingRoomsCollectionView.bounds.width)
    
    let calendar = Calendar.utc
    let startDate = Date().previousMonth(with: calendar).startOfMonth(with: calendar)
    let endDate = Date().nextMonth(with: calendar).endOfMonth(with: calendar)
    calendarCollectionView.configure(startDate: startDate, endDate: endDate)
  }
  
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    
    coordinator.animate(alongsideTransition: { [weak self] _ in
      guard let self = self else { return }
      
      self.calendarCollectionView.reloadData()
      self.updateMeetingRoomsFrame()
      self.meetingRoomsScrollView.bounds.origin.x = CGFloat(self.currentPage) * self.meetingRoomsScrollView.bounds.width
      self.meetingRoomsCollectionViewDataSource.viewWillTransition()
      self.viewModel.orientationDidChanged(UIDevice.current.orientation, collectionViewWidth: self.meetingRoomsCollectionView.bounds.width)
      }, completion: nil)
  }
  
  private func configureUI() {
    view.backgroundColor = Colors.mainBackgroundColor
    
    backButton.setTitleColor(Colors.mainTextColor, for: .normal)
    backButton.addTarget(self, action: #selector(didSelectBackButton), for: .touchUpInside)
    let image = R.image.arrowBack()?.withRenderingMode(.alwaysTemplate)
    backButton.imageView?.tintColor = Colors.imageColor
    backButton.setImage(image, for: .normal)
    
    editButton.setTitleColor(Colors.mainTextColor, for: .normal)
    editButton.setTitle(Strings.MeetingRooms.edit, for: .normal)
    editButton.addTarget(self, action: #selector(didSelectEditButton), for: .touchUpInside)
    
    expandButton.setImage(R.image.expand(), for: .normal)
    expandButton.addTarget(self, action: #selector(didSelectExpandButton), for: .touchUpInside)
    
    meetingRoomsScrollViewContainer.backgroundColor = Colors.Colleagues.lightBlue
    meetingRoomsScrollView.isPagingEnabled = true
    meetingRoomsScrollView.showsHorizontalScrollIndicator = false
    meetingRoomsScrollView.delegate = self
    
    calendarCollectionView.delegate = self
    
    monthNameLabel.text = Date().monthName()
  }
  
  private func configureConstraints() {
    [buttonsContainerView,
     calendarCollectionView,
     meetingRoomsScrollViewContainer,
     timeTableView,
     meetingRoomsCollectionView].forEach(self.view.addSubview(_:))
    
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
      maker.height.equalTo(Constants.meetingContainerViewHeight)
    }
    
    timeTableView.snp.makeConstraints { maker in
      maker.top.equalTo(meetingRoomsScrollViewContainer.snp.bottom)
      maker.left.bottom.equalTo(self.view.safeAreaLayoutGuide)
      maker.width.equalTo(Constants.timeTableViewWidth)
    }
    
    meetingRoomsCollectionView.snp.makeConstraints { maker in
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
      maker.size.equalTo(Constants.expandButtonSize)
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
    meetingRoomsCollectionViewDataSource.configure(with: dataSource.count - 1)
    timeDataSource.updateDataSource(with: dataSource)
  }
  
  private func configureMeetinRoomsScrollView() {
    meetingRoomsScrollView.contentSize = CGSize(
      width: meetingRoomsScrollView.frame.width * CGFloat(meetingRooms.count),
      height: meetingRoomsScrollView.frame.height
    )
    
    for index in 0..<meetingRooms.count {
      let meetingView = meetingRoomViews[index]
      meetingView.configure(with: meetingRooms[index].description)
      
      meetingView.frame = CGRect(
        x: meetingRoomsScrollView.frame.width * CGFloat(index),
        y: 0,
        width: meetingRoomsScrollView.frame.width,
        height: meetingRoomsScrollView.frame.height
      )
      
      meetingRoomsScrollView.addSubview(meetingView)
    }
  }
  
  private func updateMeetingRoomsFrame() {
    meetingRoomsScrollView.contentSize = CGSize(
      width: meetingRoomsScrollView.frame.width * CGFloat(meetingRooms.count),
      height: meetingRoomsScrollView.frame.height
    )
    
    for (index, view) in meetingRoomViews.enumerated() {
      view.frame = CGRect(
        x: meetingRoomsScrollView.frame.width * CGFloat(index),
        y: 0,
        width: meetingRoomsScrollView.frame.width,
        height: meetingRoomsScrollView.frame.height
      )
    }
  }
  
  private func configureBindings() {
    viewModel.onRoomsUpdate = { [weak self] (room, roomsData) in
      self?.meetingRoomsCollectionViewDataSource.updateDataSource(with: room, roomsData: roomsData)
    }
    
    viewModel.onChangeDate = { [weak self] in
      self?.meetingRoomsCollectionViewDataSource.clearDataSource()
    }
    
    viewModel.onChangeMeetingRoom = { [weak self] room in
      self?.meetingRoomsCollectionViewDataSource.clearDataSource(with: room)
    }
    
    calendarCollectionView.onSelectDate = { [weak self] date in
      self?.viewModel.changeDate(with: date)
    }
    
    meetingRoomsCollectionViewDataSource.didScroll = { [weak self] contentOffset in
      guard let self = self else { return }
      let offset = contentOffset.x * self.meetingRoomsScrollView.contentSize.width / self.meetingRoomsCollectionView.contentSize.width
      self.meetingRoomsScrollView.bounds.origin.x = offset
    }
    
    meetingRoomsCollectionViewDataSource.didChangeCurrentPage = { [weak self] page in
      guard let self = self else { return }
      self.currentPage = page
      self.viewModel.changeRoom(with: self.meetingRooms[page])
    }
  }
  
  @objc func didSelectEditButton() {
    isEdit.toggle()
    
    meetingRoomsCollectionView.isScrollEnabled = !isEdit
    meetingRoomsScrollView.isScrollEnabled = !isEdit
    calendarCollectionView.setEditing(isEdit)
    
    UIView.transition(with: editButton, duration: 0.2, options: .transitionFlipFromLeft, animations: { [weak self] in
      self?.editButton.setTitle(self?.isEdit ?? false ? Strings.MeetingRooms.done : Strings.MeetingRooms.edit, for: .normal)
    }, completion: nil)
    
    if let cell = meetingRoomsCollectionView.cellForItem(at: IndexPath(item: currentPage, section: 0)) as? MeetingRoomCollectionViewCell {
      if isEdit {
        cell.edit()
      } else {
        cell.book()
        
        guard cell.tableViewSelectedIndexPaths.count > 0 else { return }
        
        var timeInterspaces = [TimeInterspace]()
        let date = calendarCollectionView.selectedDate.utc
        let indexPaths = cell.tableViewSelectedIndexPaths.sorted()
        let firstIndexPath = cell.tableViewSelectedIndexPaths.first!
        var previousRow = firstIndexPath.row
        var timeInterspace = TimeInterspace(startTime: createDateWithRow(row: firstIndexPath.row, date: date))
        for indexPath in indexPaths {
          if indexPath.row - previousRow > 1 {
            timeInterspace.endTime = createDateWithRow(row: previousRow + 1, date: date)
            timeInterspaces.append(timeInterspace)
            timeInterspace = TimeInterspace(startTime: createDateWithRow(row: indexPath.row, date: date))
          }
          
          previousRow = indexPath.row
        }
        
        timeInterspace.endTime = createDateWithRow(row: indexPaths.last!.row + 1, date: date)
        timeInterspaces.append(timeInterspace)
        currentTimeInterspace = timeInterspaces.first!
        let addMeetingRooms = createBookMeetingRoomView(timeInterspace: timeInterspaces.first!)
        Toast.current.hide {
          Toast.current.show(addMeetingRooms)
        }
      }
    }
  }
  
  private func createDateWithRow(row: Int, date: Date) -> Date {
    return Date(timeInterval: TimeInterval((Double(row) * 0.5 + 9) * TimeInterval.hour), since: date)
  }
  
  private func createBookMeetingRoomView(timeInterspace: TimeInterspace) -> BookMeetingRoomViewToast {
    let v = BookMeetingRoomViewToast()
    v.update(timeInterspace: timeInterspace,
             onAddUser: { [weak self] in
              guard let self = self else { return }
              Toast.current.hide {
                let colleaguesVC = Router.getColleaguesViewController(with: .selectParticipant, users: self.viewModel.users)
                colleaguesVC.onPop = { [weak self] user in
                  guard let self = self, let currentTimeInterspace = self.currentTimeInterspace else { return }
                  _ = user.map { self.viewModel.participants.insert($0) }
                  Toast.current.show(self.createBookMeetingRoomView(timeInterspace: currentTimeInterspace))
                }
                self.navigationController?.pushViewController(colleaguesVC, animated: true)
              }
    },
             participants: Array(self.viewModel.participants),
             onRemoveUser: { [weak self] user in
              if let index = self?.viewModel.participants.firstIndex(of: user) {
                self?.viewModel.participants.remove(at: index)
              }
    },
             onBook: { [weak self] in
              guard let self = self else { return }
              
              if let cell = self.meetingRoomsCollectionView.cellForItem(at: IndexPath(item: self.currentPage, section: 0)) as? MeetingRoomCollectionViewCell {
                cell.finishBooking()
              }
              
              Toast.current.hide()
    },
             onCancel: { [weak self] in
              guard let self = self else { return }
              
              if let cell = self.meetingRoomsCollectionView.cellForItem(at: IndexPath(item: self.currentPage, section: 0)) as? MeetingRoomCollectionViewCell {
                cell.finishBooking()
              }
              
              Toast.current.hide()
    })
    return v
  }
  
  @objc func didSelectExpandButton() {
    toggleState()
  }
  
  @objc func didSelectBackButton() {
    navigationController?.popViewController(animated: true)
  }
  
  private func handleStateDidChange() {
    setExpandButtonImageForState(state, animated: true)
    updateHeaderHeight(state, animated: true)
    calendarCollectionView.setState(state)
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
    
    meetingRoomsCollectionView.collectionViewLayout.invalidateLayout()
    if animated {
      let animator = UIViewPropertyAnimator(duration: 0.25, curve: UIView.AnimationCurve.easeInOut, animations: { [weak self] in
        self?.view.layoutIfNeeded()
      })
      animator.startAnimation()
    } else {
      view.layoutIfNeeded()
    }
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let offset = scrollView.contentOffset.x * meetingRoomsCollectionView.contentSize.width / scrollView.contentSize.width
    meetingRoomsCollectionView.setContentOffset(CGPoint(x: offset, y: 0), animated: false)
  }
  
  //MARK: - CalendarCollectionViewDelegate
  func calendarCollectionView(_ calendarCollectionView: CalendarCollectionView, didScrollToMonthWithName monthName: String?) {
    monthNameLabel.text = monthName
  }
}
