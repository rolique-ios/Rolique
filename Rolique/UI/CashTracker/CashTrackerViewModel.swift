//
//  CashTrackerViewModel.swift
//  Rolique
//
//  Created by Bohdan Savych on 12/5/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import Foundation

protocol CashTrackerViewModel: ViewModel {
  func select(cashOwner: CashOwner, cashType: CashType)
}

final class CashTrackerViewModelImpl: BaseViewModel, CashTrackerViewModel {
  func select(cashOwner: CashOwner, cashType: CashType) {
    let vc = Router.getCashHistoryViewController()
    self.shouldPush?(vc, true)
  }
}
