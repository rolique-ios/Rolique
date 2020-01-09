//
//  CashTrackerViewModel.swift
//  Rolique
//
//  Created by Bohdan Savych on 12/5/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import Foundation
import Networking

protocol CashTrackerViewModel: ViewModel {
  var hrBalance: Balance? { get }
  var omBalance: Balance? {get }
  
  var onHrBalanceChange: Completion? { get set }
  var onOmBalanceChange: Completion? { get set }
  var didGetAllBalances: Completion? { get set }
  var onError: ((String) -> Void)? { get set }
  
  func select(cashOwner: CashOwner, paymentMethodType: PaymentMethodType)
  func getBalances()
}

final class CashTrackerViewModelImpl: BaseViewModel, CashTrackerViewModel {
  var onHrBalanceChange: Completion?
  var onOmBalanceChange: Completion?
  var didGetAllBalances: Completion?
  var onError: ((String) -> Void)?

  var hrBalance: Balance? {
    didSet {
      onHrBalanceChange?()
    }
  }
  var omBalance: Balance? {
    didSet {
      onOmBalanceChange?()
    }
  }

  override func viewDidLoad() {
    getBalances()
  }
  
  func select(cashOwner: CashOwner, paymentMethodType: PaymentMethodType) {
    let balance = (cashOwner == .hrManager ? hrBalance : omBalance) ?? Balance(cash: 0, card: 0)
    let vc = Router.getCashHistoryViewController(balance: balance, cashOwner: cashOwner, paymentMethodType: paymentMethodType)
    self.shouldPush?(vc, true)
  }
  
  func getBalances() {
    let group = DispatchGroup()
    
    group.enter()
    Net.Worker.request(GetBalance(cashOwner: CashOwner.hrManager.apiName),
                       onSuccess: { [weak self] balanceJson in
                        group.leave()
                        DispatchQueue.main.async {
                          self?.hrBalance = balanceJson.build()
                        }
      },
                       onError: { [weak self] error in
                        group.leave()
                        DispatchQueue.main.async {
                          self?.onError?(error.localizedDescription)
                        }
    })
    
    group.enter()
    Net.Worker.request(GetBalance(cashOwner: CashOwner.officeManager.apiName),
                       onSuccess: { [weak self] balanceJson in
                        group.leave()
                        DispatchQueue.main.async {
                          self?.omBalance = balanceJson.build()
                        }
                        
      },
                       onError: { [weak self] error in
                        group.leave()
                        DispatchQueue.main.async {
                          self?.onError?(error.localizedDescription)
                        }
                        
    })
    
    group.notify(queue: DispatchQueue.main) { [weak self] in
      self?.didGetAllBalances?()
    }
  }
}
