//
//  ColleaguesDetailViewModel.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 9/18/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import Foundation
import Utils

protocol ProfileDetailViewModel: ViewModel {
  var user: User { get }
  var onLogOut: (() -> Void)? { get set }
  var onClearCache: (() -> Void)? { get set }
  
  func logOut()
  func clearCache()
}

final class ProfileDetailViewModelImpl: BaseViewModel, ProfileDetailViewModel {
  let user: User
  
  init(user: User) {
    self.user = user
  }
  
  var onLogOut: (() -> Void)?
  var onClearCache: (() -> Void)?
  
  func logOut() {
    UserDefaultsManager.shared.userId = nil
    onLogOut?()
  }
  
  func clearCache() {
    ImageManager.shared.clearImagesFolder()
    onClearCache?()
  }
}
