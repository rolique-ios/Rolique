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
  static var startHour: Double { return 9 }
  static var endHour: Double { return 21 }
  static var step: Double { return 0.5 }
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
  private lazy var editButton = UIBarButtonItem(title: Strings.MeetingRooms.edit, style: .done, target: self, action: #selector(didTapOnEditButton(sender:)))
  private lazy var doneButton = UIBarButtonItem(title: Strings.MeetingRooms.done, style: .done, target: self, action: #selector(didTapOnEditButton(sender:)))
  private lazy var monthViewContainer = UIView()
  private lazy var monthNameLabel = UILabel()
  private lazy var expandButton = UIButton()
  private lazy var calendarCollectionView = CalendarCollectionView()
  private var isEdit = false
  private var currentPage = 0
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
    configureBindings()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    navigationController?.navigationBar.prefersLargeTitles = false
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
    setEmptyTitleBackButton()
    navigationItem.titleView = monthViewContainer
    navigationItem.rightBarButtonItem = editButton
    
    view.backgroundColor = Colors.mainBackgroundColor
    
    let image = R.image.expand()?.withRenderingMode(.alwaysTemplate)
    expandButton.tintColor = .systemOrange
    expandButton.setImage(image, for: .normal)
    expandButton.addTarget(self, action: #selector(didTapOnExpandButton), for: .touchUpInside)
    
    meetingRoomsScrollViewContainer.backgroundColor = Colors.Colleagues.lightBlue
    meetingRoomsScrollView.isPagingEnabled = true
    meetingRoomsScrollView.showsHorizontalScrollIndicator = false
    meetingRoomsScrollView.delegate = self
    
    calendarCollectionView.delegate = self
    
    monthNameLabel.text = Date().monthName()
    monthNameLabel.textColor = .white
    
    Toast.current.backgroundColor = Colors.mainBackgroundColor
  }
  
  private func configureConstraints() {
    [monthNameLabel, expandButton].forEach(monthViewContainer.addSubview)
    
    monthNameLabel.snp.makeConstraints { maker in
      maker.top.left.bottom.equalToSuperview()
    }
    
    expandButton.snp.makeConstraints { maker in
      maker.left.equalTo(monthNameLabel.snp.right)
      maker.centerY.right.equalToSuperview()
      maker.size.equalTo(Constants.expandButtonSize)
    }
    
    [calendarCollectionView,
     meetingRoomsScrollViewContainer,
     timeTableView,
     meetingRoomsCollectionView].forEach(self.view.addSubview(_:))
    
    calendarCollectionView.snp.makeConstraints { maker in
      maker.top.equalTo(self.view.safeAreaLayoutGuide)
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
    
    [meetingRoomsScrollView].forEach(meetingRoomsScrollViewContainer.addSubview(_:))
    
    meetingRoomsScrollView.snp.makeConstraints { maker in
      maker.edges.equalToSuperview()
    }
  }
  
  private func configureDataSources() {
    let date = Date().utc
    var dataSource = [Date]()
    for value in stride(from: Constants.startHour, through: Constants.endHour, by: Constants.step) {
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
    
    viewModel.onFinishBooking = { [weak self] in
      self?.finishBooking()
      self?.hideSpinner()
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
  
  @objc func didTapOnEditButton(sender: UIBarButtonItem) {
    isEdit.toggle()
    
    meetingRoomsCollectionView.isScrollEnabled = !isEdit
    meetingRoomsScrollView.isScrollEnabled = !isEdit
    calendarCollectionView.setEditing(isEdit)
    
    navigationItem.rightBarButtonItem = isEdit ? doneButton : editButton
    
    if let cell = meetingRoomsCollectionView.cellForItem(at: IndexPath(item: currentPage, section: 0)) as? MeetingRoomCollectionViewCell {
      if isEdit {
        cell.edit()
      } else {
        cell.book()
        book(cell)
      }
    }
  }
  
  private func book(_ cell: MeetingRoomCollectionViewCell) {
    guard cell.tableViewSelectedIndexPaths.count > 0 else { return }
    
    var timeInterspaces = [TimeInterspace]()
    let date = calendarCollectionView.selectedDate
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
    viewModel.setCurrentTimeInterspace(timeInterspaces.first!)
    
    let addMeetingRooms = createBookMeetingRoomView(timeInterspace: timeInterspaces.first!)
    Toast.current.hide {
      Toast.current.show(addMeetingRooms)
    }
    
    Toast.current.willBeClosedByUserInteraction = { [weak self] in
      cell.finishBooking()
      self?.viewModel.finishBooking()
    }
  }
  
  private func createDateWithRow(row: Int, date: Date) -> Date {
    return Date(timeInterval: TimeInterval((Double(row) * Constants.step + Constants.startHour) * TimeInterval.hour), since: date)
  }
  
  private func createBookMeetingRoomView(timeInterspace: TimeInterspace) -> BookMeetingRoomViewToast {
    let v = BookMeetingRoomViewToast()
    v.update(startTime: timeInterspace.startTime,
             endTime: timeInterspace.endTime,
             onAddUser: { [weak self] title in
              guard let self = self else { return }
              
              self.viewModel.changeTitle(title)
              
              Toast.current.hide {
                let colleaguesVC = Router.getColleaguesViewController(with: .selectParticipant, users: self.viewModel.users)
                colleaguesVC.onPop = { [weak self] user in
                  guard let self = self, let currentTimeInterspace = self.viewModel.currentTimeInterspace else { return }
                  _ = user.map { self.viewModel.addParticipant($0) }
                  Toast.current.show(self.createBookMeetingRoomView(timeInterspace: currentTimeInterspace))
                }
                self.navigationController?.pushViewController(colleaguesVC, animated: true)
              }
    },
             participants: Array(self.viewModel.participants),
             title: viewModel.title,
             onRemoveUser: { [weak self] user in
              self?.viewModel.removeParticipant(user)
              Toast.current.layoutVertically()
    },
             onBook: { [weak self] title in
              self?.viewModel.bookMeetingRoom(with: title)
              Toast.current.hide { [weak self] in
                self?.showSpinner(shouldBlockUI: true)
              }
    },
             onCancel: { [weak self] in
              self?.finishBooking()
              Toast.current.hide()
    })
    return v
  }
  
  private func finishBooking() {
    if let cell = meetingRoomsCollectionView.cellForItem(at: IndexPath(item: self.currentPage, section: 0)) as? MeetingRoomCollectionViewCell {
      cell.finishBooking()
    }
    viewModel.finishBooking()
  }
  
  @objc func didTapOnExpandButton() {
    toggleState()
  }
  
  @objc func didTapOnBackButton() {
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
