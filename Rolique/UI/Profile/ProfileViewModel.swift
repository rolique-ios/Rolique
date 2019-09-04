//
//  ProfileViewModel.swift
//  UI
//
//  Created by Bohdan Savych on 8/5/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import Foundation
import Utils

protocol ProfileViewModel: ViewModel {
  var onUserSuccess: ((User) -> Void)? { get set }
  var onLogOut: (() -> Void)? { get set }
  var onError: ((String) -> Void)? { get set }
  var onClearCache: ((String) -> Void)? { get set }
  
  func getUser()
  func logOut()
  func clearCache()
  func getClearCacheTitle() -> String
}

final class ProfileViewModelImpl: BaseViewModel, ProfileViewModel {
  private let userService: UserService
  
  init(userService: UserService) {
    self.userService = userService
  }
  
  var onUserSuccess: ((User) -> Void)?
  var onLogOut: (() -> Void)?
  var onError: ((String) -> Void)?
  var onClearCache: ((String) -> Void)?
  
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
      onUserSuccess?(user)
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
    onClearCache?(getClearCacheTitle())
  }
  
  func getClearCacheTitle() -> String {
    return " "
      + Strings.Profile.clearCache
      + "(\(ByteCountFormatters.fileSizeFormatter.string(fromByteCount: Int64(ImageManager.shared.findImagesDirectorySize()))))"
      + " "
  }
}
