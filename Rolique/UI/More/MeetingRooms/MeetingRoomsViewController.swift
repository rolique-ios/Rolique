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

final class MeetingRoomsViewController<T: MeetingRoomsViewModelImpl>: ViewController<T>,
  UICollectionViewDelegate,
  UICollectionViewDelegateFlowLayout,
  UICollectionViewDataSource,
  UINavigationControllerDelegate {
  private lazy var scrollView = UIScrollView()
  private lazy var timeTableView = UITableView()
  private lazy var meetingNames = ["Conf", "MR1", "MR2"]
  private lazy var flowLayout: UICollectionViewFlowLayout = {
    let flowLayout = UICollectionViewFlowLayout()
    flowLayout.scrollDirection = .horizontal
    return flowLayout
  }()
  private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
  private var timeDataSource: TimeDataSource?
  private var currentDayIndex = 0
  private var currentPage = 0
  private var tableViewNumberOfRows = 0
  private let collectionViewNumberOfRows = 9999
  private let timeDateFormatter: DateFormatter = {
    var dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone(identifier: "UTC")!
    dateFormatter.dateFormat = "HH:mm"
    return dateFormatter
  }()
  private let dateFormatter: DateFormatter = {
    var dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone(identifier: "UTC")!
    dateFormatter.dateFormat = "YYYY-MM-dd"
    return dateFormatter
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureUI()
    configureConstraints()
    configureDataSources()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    navigationController?.navigationBar.prefersLargeTitles = false
  }
  
  override func performOnceInViewDidAppear() {
    let hulf = collectionViewNumberOfRows / 2
    let middle = hulf - hulf % meetingNames.count
    self.collectionView.scrollToItem(at: IndexPath(item: middle, section: 0), at: .centeredHorizontally, animated: false)
    currentPage = middle
    currentDayIndex = middle
    navigationItem.title = Strings.Actions.today
  }
  
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    
    coordinator.animate(alongsideTransition: { [weak self] _ in
      self?.collectionView.performBatchUpdates({ [weak self] in
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
    
    navigationItem.rightBarButtonItem = editButton()
    
    timeTableView.showsVerticalScrollIndicator = false
    timeTableView.separatorStyle = .none
  }
  
  private func configureConstraints() {
    [timeTableView, collectionView].forEach(self.view.addSubview(_:))
    
    timeTableView.snp.makeConstraints { maker in
      maker.left.top.bottom.equalTo(self.view.safeAreaLayoutGuide)
      maker.width.equalTo(Constants.timeTableViewWidth)
    }
    
    collectionView.snp.makeConstraints { maker in
      maker.top.right.bottom.equalTo(self.view.safeAreaLayoutGuide)
      maker.left.equalTo(timeTableView.snp.right)
    }
  }
  
  private func configureDataSources() {
    let date = Date().utc
    var dataSource = [Date]()
    for value in stride(from: 9, to: 22, by: 0.5) {
      let date = Date(timeInterval: TimeInterval(value * TimeInterval.hour), since: date)
      dataSource.append(date)
    }
    tableViewNumberOfRows = dataSource.count
    
    timeDataSource = TimeDataSource(tableView: timeTableView, numberOfRows: dataSource.count, dataSource: dataSource)
  }
  
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    let page = floor(scrollView.contentOffset.x / scrollView.frame.width)
    currentPage = Int(page)
    let calendar = Calendar.utc
    let value = Int(currentPage / meetingNames.count - currentDayIndex / meetingNames.count)
    let date = calendar.date(byAdding: .day, value: value, to: Date().utc)!
    navigationItem.title = value == 0 ? Strings.Actions.today : dateFormatter.string(from: date)
  }
  
  @objc func didSelectEditButton() {
    if let cell = collectionView.cellForItem(at: IndexPath(item: currentPage, section: 0)) as? MeetingRoomCollectionViewCell {
      cell.edit()
      navigationItem.rightBarButtonItem = doneButton()
    }
  }
  
  @objc func didSelectDoneButton() {
    if let cell = collectionView.cellForItem(at: IndexPath(item: currentPage, section: 0)) as? MeetingRoomCollectionViewCell {
      cell.done()
      navigationItem.rightBarButtonItem = editButton()
    }
  }
  
  private func editButton() -> UIBarButtonItem {
    return UIBarButtonItem(title: Strings.MeetingRooms.edit, style: UIBarButtonItem.Style.done, target: self, action: #selector(didSelectEditButton))
  }
  
  private func doneButton() -> UIBarButtonItem {
    return UIBarButtonItem(title: Strings.MeetingRooms.done, style: UIBarButtonItem.Style.done, target: self, action: #selector(didSelectDoneButton))
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return collectionViewNumberOfRows
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeue(type: MeetingRoomCollectionViewCell.self, indexPath: indexPath)
    cell.configure(with: tableViewNumberOfRows - 1, meetingName: meetingNames[indexPath.row % meetingNames.count], contentOffsetY: timeTableView.contentOffset.y, index: indexPath.row)
    cell.tableViewDidScroll = { [weak self] contentOffsetY in
      self?.timeTableView.setContentOffset(CGPoint(x: 0, y: contentOffsetY), animated: false)
    }
    
    return cell
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
}
