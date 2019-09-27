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
  var user: User? { get }
  var onSuccess: Completion? { get set }
  var onError: ((String) -> Void)? { get set }
  var onLogOut: Completion? { get set }
  var onClearCache: Completion? { get set }
  
  func getUser()
  func logOut()
  func clearCache()
}

final class ProfileDetailViewModelImpl: BaseViewModel, ProfileDetailViewModel {
  private let userService: UserService
  var user: User?
  
  init(userService: UserService, user: User?) {
    self.user = user
    self.userService = userService
  }
  
  var onSuccess: Completion?
  var onError: ((String) -> Void)?
  var onLogOut: Completion?
  var onClearCache: Completion?
  
  override func viewDidLoad() {
    if user == nil {
      getUser()
    }
  }
  
  func getUser() {
    userService.getUserWithId(UserDefaultsManager.shared.userId ?? "",
                              onLocal: { [weak self] result in
                                self?.handleUserResponse(result: result)
      },
                              onFetch: { [weak self] result in
                                self?.handleUserResponse(result: result)
    })
  }
  
  private func handleUserResponse(result: Result<User, Error>) {
    switch result {
    case .success(let user):
      self.user = user
      onSuccess?()
    case .failure(let error):
      onError?(error.localizedDescription)
    }
  }
  
  func logOut() {
    UserDefaultsManager.shared.userId = nil
    onLogOut?()
  }
  
  func clearCache() {
    ImageManager.shared.clearImagesFolder()
    onClearCache?()
  }
}
