//
//  ColleaguesViewModel.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 8/15/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import Foundation

protocol ColleaguesViewModel: ViewModel {
  var users: [User] { get }
  var onSuccess: (() -> Void)? { get set }
  
  func all()
  func onRemote()
  func onSickLeave()
}

final class ColleaguesViewModelImpl: BaseViewModel, ColleaguesViewModel {
  private let userManager: UserManager
  
  init(userManager: UserManager) {
    self.userManager = userManager
  }
  
  var onSuccess: (() -> Void)?
  var users = [User]()
  
  func all() {
    userManager.getAllUsers { [weak self] result in
      switch result {
      case .success(let users):
        self?.users = users
        self?.onSuccess?()
      case .failure(let error):
        print(error.localizedDescription)
      }
    }
  }
  
  func onRemote() {
    
  }
  
  func onSickLeave() {
    
  }
}
