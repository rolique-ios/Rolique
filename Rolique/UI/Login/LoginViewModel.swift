//
//  LoginViewModel.swift
//  UI
//
//  Created by Bohdan Savych on 8/5/19.
//  Copyright © 2019 Bohdan Savych. All rights reserved.
//

import Foundation

public protocol LoginViewModel: ViewModel {
  var onError: (() -> String)? { get set }
}

public final class LoginViewModelImpl: BaseViewModel, LoginViewModel {
  
}


