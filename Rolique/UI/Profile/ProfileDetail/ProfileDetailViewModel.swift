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
  var onLogOut: Completion? { get set }
  var onClearCache: Completion? { get set }
  
  func logOut()
  func clearCache()
}

final class ProfileDetailViewModelImpl: BaseViewModel, ProfileDetailViewModel {
  private let userService: UserService
  private let coreDataMananger: CoreDataManager<User>
  var user: User
  
  init(userService: UserService, coreDataMananger: CoreDataManager<User>, user: User) {
    self.userService = userService
    self.coreDataMananger = coreDataMananger
    self.user = user
  }
  
  var onLogOut: Completion?
  var onClearCache: Completion?
  
  func logOut() {
    UserDefaultsManager.shared.userId = nil
    coreDataMananger.clearCoreData()
    ImageManager.shared.clearImagesFolder()
    onLogOut?()
  }
  
  func clearCache() {
    ImageManager.shared.clearImagesFolder()
    onClearCache?()
  }
}
