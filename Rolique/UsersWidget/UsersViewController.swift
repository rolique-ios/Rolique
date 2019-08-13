//
//  UsersViewController.swift
//  UsersTodayExtension
//
//  Created by Bohdan Savych on 8/3/19.
//  Copyright © 2019 Bohdan Savych. All rights reserved.
//

import UIKit
import NotificationCenter

private struct Constants {
  static var widgetRowHeight: CGFloat { return 110 }
  static var preferableColumnsCount: Int { return 5 }
  static var columnsCount = 5
  static var maxRows = 3
  static var minColumnWidth: CGFloat { return 70 }
}

open class UsersViewController: UIViewController, NCWidgetProviding {
  private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
  private var users: [AnyUserable] {
    return UsersStorage.shared.users
  }
  private lazy var isFetched = false
  
  override open func viewDidLoad() {
    super.viewDidLoad()
    
    configureConstraints()
    configureUI()
    configureCollectionView()
  }
  
  public func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
    if isFetched { completionHandler(.noData); return; }
    loadData { [weak self] users in
      guard let self = self else { return }
      DispatchQueue.main.async {
        if users == self.users {
          completionHandler(.noData)
        } else {
          if users.count > Constants.preferableColumnsCount * Constants.maxRows {
            UsersStorage.shared.users = Array(users[0..<Constants.preferableColumnsCount * Constants.maxRows])
          } else {
            UsersStorage.shared.users = users
          }
          
          self.collectionView.reloadData()
          completionHandler(.newData)
        }
        
        self.isFetched = true
      }
    }
  }
  
  public func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
    preferredContentSize = activeDisplayMode == .expanded ? CGSize(width: 0.0, height: CGFloat(maxRows()) * Constants.widgetRowHeight) : maxSize
    collectionView.reloadData()
  }
  
  // MARK: - Override point
  open func loadData(usersCompletion: @escaping (([AnyUserable]) -> Void)) {

  }
  
  open func didTapOnElement(at index: Int) {
    
  }
  
  deinit {
    print("☠️\(String(describing: self))☠️")
  }
  
  open override func didReceiveMemoryWarning() {
    ImageCacher.shared.cache.removeAllObjects()
    Constants.maxRows = max(1, Constants.maxRows - 1)
    collectionView.reloadData()
  }
}

// MARK: - UICollectionViewDelegate
extension UsersViewController: UICollectionViewDelegate {
  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    didTapOnElement(at: indexPath.row)
  }
}


// MARK: - UICollectionViewDataSource
extension UsersViewController: UICollectionViewDataSource {
  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return users.count
  }
  
  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: UserCollectionViewCell.self), for: indexPath) as! UserCollectionViewCell
    let user = users[indexPath.row]
    cell.configure(url: user.thumbnailURL, name: user.name, imageCornerRadius: calculateImageHeight() / 2)
    return cell
  }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension UsersViewController: UICollectionViewDelegateFlowLayout {
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: collectionView.bounds.width / CGFloat(Constants.columnsCount), height: Constants.widgetRowHeight)
  }
  
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return .zero
  }
  
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 0
  }
  
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 0
  }
}

// MARK: - Private
private extension UsersViewController {
  func configureUI() {
    collectionView.backgroundColor = .clear
    extensionContext?.widgetLargestAvailableDisplayMode = .expanded
    Constants.columnsCount = Constants.minColumnWidth > (UIScreen.main.bounds.width / CGFloat(Constants.preferableColumnsCount))
      ? Constants.preferableColumnsCount - 1
      : Constants.preferableColumnsCount
  }
  
  func configureConstraints() {
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(collectionView)
    collectionView.heightAnchor.constraint(equalToConstant: Constants.widgetRowHeight).isActive = true
    collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
  }
  
  func configureCollectionView() {
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.register(UINib(nibName: String(describing: UserCollectionViewCell.self), bundle: Bundle.init(for: UserCollectionViewCell.self)), forCellWithReuseIdentifier: String(describing: UserCollectionViewCell.self))
  }
  
  func maxRows() -> Int {
    return max(1, min(Constants.maxRows, self.users.count % Constants.columnsCount == 0 ? self.users.count / Constants.columnsCount : ((self.users.count / Constants.columnsCount) + 1)))
  }
  
  func calculateImageHeight() -> CGFloat {
    return (collectionView.bounds.width / CGFloat(Constants.columnsCount))
      - UserCollectionViewCell.Constants.imageHorizontal
      - UserCollectionViewCell.Constants.imageHorizontal
  }
}
