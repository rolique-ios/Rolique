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
  static var columns: Int { return 5 }
  static var maxRows: Int { return 3 }
}

open class UsersViewController: UIViewController, NCWidgetProviding {
  private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
  private lazy var users = [Userable]()
  
  override open func viewDidLoad() {
    super.viewDidLoad()
    
    configureConstraints()
    configureUI()
    configureCollectionView()
  }
  
  public func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
    completionHandler(.noData)
    loadData { [weak self] users in
      self?.users = users
      DispatchQueue.main.async {
        self?.collectionView.reloadData()
        completionHandler(.newData)
      }
    }
  }
  
  public func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
    preferredContentSize = activeDisplayMode == .expanded ? CGSize(width: 0.0, height: CGFloat(maxRows()) * Constants.widgetRowHeight) : maxSize
  }
  
  // MARK: - Override point
  open func loadData(usersCompletion: @escaping (([Userable]) -> Void)) {

  }
  
  open func didTap(on user: Userable, at index: Int) {
    
  }
}

// MARK: - UICollectionViewDelegate
extension UsersViewController: UICollectionViewDelegate {
  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let user = self.users[indexPath.row]
    didTap(on: user, at: indexPath.row)
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
    cell.configure(url: user.thumnailURL, name: user.name, imageCornerRadius: calculateImageHeight() / 2)
    return cell
  }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension UsersViewController: UICollectionViewDelegateFlowLayout {
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: collectionView.bounds.width / CGFloat(Constants.columns), height: collectionView.bounds.height)
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
    return max(1, min(Constants.maxRows, self.users.count % Constants.columns == 0 ? self.users.count / Constants.columns : ((self.users.count / Constants.columns) + 1)))
  }
  
  func calculateImageHeight() -> CGFloat {
    return (collectionView.bounds.width / CGFloat(Constants.columns))
      - UserCollectionViewCell.Constants.imageHorizontal
      - UserCollectionViewCell.Constants.imageHorizontal
  }
}
