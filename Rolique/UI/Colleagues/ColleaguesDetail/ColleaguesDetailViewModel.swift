//
//  ColleaguesDetailViewModel.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 9/18/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import Foundation
import Utils

protocol ColleaguesDetailViewModel: ViewModel {
  var user: User { get }
  
  func openSlack()
}

final class ColleaguesDetailViewModelImpl: BaseViewModel, ColleaguesDetailViewModel {
  let user: User
  init(user: User) {
    self.user = user
  }
  
  func openSlack() {
    let urlString = "slack://user?team=\(UserDefaultsManager.shared.teamId ?? "no-team-id")&id=\(user.id)"
    guard let url = URL(string: urlString) ,UIApplication.shared.canOpenURL(url) else { return }
    UIApplication.shared.open(url, options: [:], completionHandler: nil)
  }
}
