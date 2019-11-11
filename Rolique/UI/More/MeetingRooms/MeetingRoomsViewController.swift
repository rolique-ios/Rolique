//
//  MeetingRoomsViewController.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 11/8/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit
import Utils

private struct Constants {
  static var timeTableViewWidth: CGFloat { return 60.0 }
  static var meetingViewHeight: CGFloat { return 30.0 }
  static var cellHeight: CGFloat { return 30.0 }
}

final private class MeetingRoomView: UIView {
  private lazy var label = UILabel()
  
  convenience init(name: String) {
    self.init(frame: .zero)
    label.textColor = Colors.mainTextColor
    label.text = name
    label.textAlignment = .center
    label.font = .systemFont(ofSize: 20.0)
    configureConstraints()
  }
  
  func configureConstraints() {
    addSubview(label)
    
    label.snp.makeConstraints { maker in
      maker.edges.equalToSuperview()
    }
  }
}

final private class MeetingRoomData {
  let tableView: UITableView
  let meetingRoomView: MeetingRoomView
  var dataSource: MeetingRoomsDataSource?
  
  init(tableView: UITableView, meetingRoomView: MeetingRoomView) {
    self.tableView = tableView
    self.meetingRoomView = meetingRoomView
  }
}

final class MeetingRoomsViewController<T: MeetingRoomsViewModelImpl>: ViewController<T>, UIScrollViewDelegate {
  private lazy var scrollView = UIScrollView()
  private lazy var timeTableView = UITableView()
  private lazy var conferenceMeetingRoomData = MeetingRoomData(tableView: UITableView(), meetingRoomView: MeetingRoomView(name: "Conf"))
  private lazy var firstMeetingRoomData = MeetingRoomData(tableView: UITableView(), meetingRoomView: MeetingRoomView(name: "MR1"))
  private lazy var secondMeetingRoomData = MeetingRoomData(tableView: UITableView(), meetingRoomView: MeetingRoomView(name: "MR2"))
  private lazy var meetingRoomsData = [conferenceMeetingRoomData, firstMeetingRoomData, secondMeetingRoomData]
  private lazy var panGesture = UIPanGestureRecognizer(target: self, action: #selector(didTap(gesture:)))
  private var timeDataSource: TimeDataSource?
  private var currentPage = 0
  private var selectedRow = -1
  private var previousLocation: CGFloat = 0
  private var direction: Direction?
  private var numberOfRows = 0
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureUI()
    configureConstraints()
    configureDataSources()
    configureDataSourceBindings()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    navigationController?.navigationBar.prefersLargeTitles = false
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    configureScrollView()
  }
  
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    
    coordinator.animate(alongsideTransition: { _ in
      self.scrollView.subviews.forEach { $0.removeFromSuperview() }
      self.configureScrollView()
      self.scrollView.bounds.origin.x = CGFloat(self.currentPage) * self.scrollView.frame.width
    }, completion: nil)
  }
  
  private func configureUI() {
    view.backgroundColor = Colors.mainBackgroundColor
    
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.isPagingEnabled = true
    
    navigationItem.rightBarButtonItem = editButton()
    
    timeTableView.showsVerticalScrollIndicator = false
    timeTableView.separatorStyle = .none
    for data in meetingRoomsData {
      data.tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
      data.tableView.showsVerticalScrollIndicator = false
    }
  }
  
  private func configureConstraints() {
    [timeTableView, scrollView].forEach(self.view.addSubview(_:))
    
    timeTableView.snp.makeConstraints { maker in
      maker.left.top.bottom.equalTo(self.view.safeAreaLayoutGuide)
      maker.width.equalTo(Constants.timeTableViewWidth)
    }
    
    scrollView.snp.makeConstraints { maker in
      maker.top.right.bottom.equalTo(self.view.safeAreaLayoutGuide)
      maker.left.equalTo(timeTableView.snp.right)
    }
  }
  
  private let dateFormatter: DateFormatter = {
    var dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone(identifier: "UTC")!
    dateFormatter.dateFormat = "HH:mm"
    return dateFormatter
  }()
  
  private func configureDataSources() {
    let date = Date().utc
    var dataSource = [Date]()
    for value in stride(from: 9, to: 22, by: 0.5) {
      let date = Date(timeInterval: TimeInterval(value * TimeInterval.hour), since: date)
      dataSource.append(date)
    }
    numberOfRows = dataSource.count
    
    timeDataSource = TimeDataSource(tableView: timeTableView, numberOfRows: dataSource.count, dataSource: dataSource)
    conferenceMeetingRoomData.dataSource = MeetingRoomsDataSource(tableView: conferenceMeetingRoomData.tableView, numberOfRows: dataSource.count - 1)
    firstMeetingRoomData.dataSource = MeetingRoomsDataSource(tableView: firstMeetingRoomData.tableView, numberOfRows: dataSource.count - 1)
    secondMeetingRoomData.dataSource = MeetingRoomsDataSource(tableView: secondMeetingRoomData.tableView, numberOfRows: dataSource.count - 1)
  }
  
  private func configureDataSourceBindings() {
    timeDataSource?.didScroll = { [weak self] contentOffsetY in
      self?.conferenceMeetingRoomData.tableView.bounds.origin.y = contentOffsetY
      self?.firstMeetingRoomData.tableView.bounds.origin.y = contentOffsetY
      self?.secondMeetingRoomData.tableView.bounds.origin.y = contentOffsetY
    }
    
    conferenceMeetingRoomData.dataSource?.didScroll = { [weak self] contentOffsetY in
      self?.timeTableView.bounds.origin.y = contentOffsetY
      self?.firstMeetingRoomData.tableView.bounds.origin.y = contentOffsetY
      self?.secondMeetingRoomData.tableView.bounds.origin.y = contentOffsetY
    }
    
    firstMeetingRoomData.dataSource?.didScroll = { [weak self] contentOffsetY in
      self?.conferenceMeetingRoomData.tableView.bounds.origin.y = contentOffsetY
      self?.timeTableView.bounds.origin.y = contentOffsetY
      self?.secondMeetingRoomData.tableView.bounds.origin.y = contentOffsetY
    }
    
    secondMeetingRoomData.dataSource?.didScroll = { [weak self] contentOffsetY in
      self?.conferenceMeetingRoomData.tableView.bounds.origin.y = contentOffsetY
      self?.firstMeetingRoomData.tableView.bounds.origin.y = contentOffsetY
      self?.timeTableView.bounds.origin.y = contentOffsetY
    }
  }
  
  private func configureScrollView() {
    scrollView.contentSize = CGSize(
      width: scrollView.frame.width * CGFloat(meetingRoomsData.count),
      height: scrollView.frame.height
    )
    
    for index in 0..<meetingRoomsData.count {
      let meetingView = meetingRoomsData[index].meetingRoomView
      
      meetingView.frame = CGRect(
        x: scrollView.frame.width * CGFloat(index),
        y: 0,
        width: scrollView.frame.width,
        height: Constants.meetingViewHeight
      )
      
      let tableView = meetingRoomsData[index].tableView
      
      tableView.frame = CGRect(
        x: scrollView.frame.width * CGFloat(index),
        y: Constants.meetingViewHeight,
        width: scrollView.frame.width,
        height: scrollView.frame.height - Constants.meetingViewHeight
      )
      
      scrollView.addSubview(meetingView)
      scrollView.addSubview(tableView)
    }
    
    scrollView.delegate = self
  }
  
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    let page = floor(scrollView.contentOffset.x / scrollView.frame.width)
    let contentOffsetX = scrollView.frame.width * CGFloat(page)
    currentPage = Int(page)
    scrollView.setContentOffset(CGPoint(x: contentOffsetX, y: scrollView.contentOffset.y), animated: true)
  }
  
  @objc func didTap(gesture: UIPanGestureRecognizer) {
    let tableView = meetingRoomsData[currentPage].tableView
    switch gesture.state {
    case .possible, .began, .changed:
      let location = gesture.location(in: tableView).y
      
      if location - tableView.frame.height > tableView.contentOffset.y && location <= tableView.contentSize.height {
        tableView.contentOffset.y += (location - tableView.frame.height) - tableView.contentOffset.y
      }
      
      if location > 0 && location < tableView.contentOffset.y {
        tableView.contentOffset.y -= abs(location - tableView.contentOffset.y)
      }
      
      let row = Int(floor(location / Constants.cellHeight))
      
      var changeDirection: Bool
      if location < previousLocation {
        if direction ?? .toTop != Direction.toBottom {
          changeDirection = true
        } else {
          changeDirection = false
        }
        direction = .toBottom
      } else {
        if direction ?? .toBottom != Direction.toTop {
          changeDirection = true
        } else {
          changeDirection = false
        }
        direction = .toTop
      }
      previousLocation = location
      
      guard row != selectedRow || changeDirection else { return }
      
      let indexPath = IndexPath(row: row, section: 0)
      if let selectedRows = tableView.indexPathsForSelectedRows, selectedRows.contains(indexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
      } else if indexPath.row != numberOfRows - 1 {
        tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
      }
      selectedRow = row
    default:
      break
    }
  }
  
  @objc func didSelectEditButton() {
    meetingRoomsData[currentPage].tableView.allowsMultipleSelection = true
    meetingRoomsData[currentPage].tableView.addGestureRecognizer(panGesture)
    navigationItem.rightBarButtonItem = doneButton()
  }
  
  @objc func didSelectDoneButton() {
    selectedRow = -1
    previousLocation = 0
    meetingRoomsData[currentPage].tableView.allowsMultipleSelection = false
    meetingRoomsData[currentPage].tableView.removeGestureRecognizer(panGesture)
    navigationItem.rightBarButtonItem = editButton()
  }
  
  private func editButton() -> UIBarButtonItem {
    return UIBarButtonItem(title: Strings.MeetingRooms.edit, style: UIBarButtonItem.Style.done, target: self, action: #selector(didSelectEditButton))
  }
  
  private func doneButton() -> UIBarButtonItem {
    return UIBarButtonItem(title: Strings.MeetingRooms.done, style: UIBarButtonItem.Style.done, target: self, action: #selector(didSelectDoneButton))
  }
}
