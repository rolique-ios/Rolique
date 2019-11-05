//
//  UsersDataSource.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 11/4/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit
import Utils
import SnapKit

private struct Constants {
  static var defaultItemHeight: CGFloat { return 80.0 }
  static var stickyRowWidth: CGFloat { return 60.0 }
}

final class UsersDataSouce: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  private var usersCollectionView: UICollectionView
  private var users: [User]
  var didScroll: ((CGPoint) -> Void)?
  
  init(usersCollectionView: UICollectionView,
       users: [User]) {
    self.usersCollectionView = usersCollectionView
    self.users = users
    
    super.init()
    
    usersCollectionView.showsHorizontalScrollIndicator = false
    usersCollectionView.showsVerticalScrollIndicator = false
    usersCollectionView.backgroundColor = Colors.secondaryBackgroundColor
    usersCollectionView.setDelegateAndDatasource(self)
    usersCollectionView.register([ColleagueCollectionViewCell.self])
  }
  
  func update(users: [User]) {
    self.users = users
    self.usersCollectionView.reloadData()
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    didScroll?(scrollView.contentOffset)
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return users.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let colleagueCell = collectionView.dequeue(type: ColleagueCollectionViewCell.self, indexPath: indexPath)
    let user = users[indexPath.row]
    let firstName = user.slackProfile.realName.split(separator: " ")
    colleagueCell.configure(with: String(firstName[0]), image: user.optimalImage)
    return colleagueCell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: Constants.stickyRowWidth, height: Constants.defaultItemHeight)
  }
}
